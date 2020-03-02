import xfoil_module as xf
import chama_xfoil
import pymysql as sql
import numpy as np
import psutil
import time
import multiprocessing as mp
import os

from datetime import date



## Função que faz a busca de uma geomeria no banco de dados e escreve um arquivo de texto formatado

def cria_arquivo_coordenadas(aerosqldb,AirfoilID):

    AirfoilID = str(AirfoilID)

    try:
        with aerosqldb.cursor() as cursor:

            line_x =    "SELECT  X  FROM  Geometries  WHERE  AirfoilID  = {};".format(AirfoilID)
            line_y =    "SELECT  Y  FROM  Geometries  WHERE  AirfoilID  = {};".format(AirfoilID)

            cursor.execute(line_x)
            x_old =     cursor.fetchall()
            cursor.execute(line_y)
            y_old =     cursor.fetchall()

            x =     list(range(len(x_old)))
            y =     list(range(len(y_old)))

            for j in range(len(y_old)):
                x[j] =   float(x_old[j][0])
                y[j] =   float(y_old[j][0])


            filename = 'Airfoil_{}'.format(AirfoilID)

            xf.create_input(x,y,filename = filename, different_x_upper_lower=True)
    finally:
        
        return filename

## Função que mata o xfoil caso ele demore calcular a polar

def mata_xfoil(tempo_maximo = 50):
    time.sleep(5)
    xfoil_is_open = 1
    tempo_aberto = 0
    while xfoil_is_open == 1:
        xfoil_is_open = 0
        for process in psutil.process_iter():
            try:
            # Get process name & pid from process object.
                processName = process.name()
                processID = process.pid
                if processName == 'xfoil.exe':
                    xfoil_is_open = 1
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                    pass
        
        if xfoil_is_open == 1:
            tempo_aberto += 1
            time.sleep(1)
            print('{}s aberto de {}s máximo PID = {}'.format(tempo_aberto,tempo_maximo,processID))
        else:
            xfoil_is_open = 0
            print('xfoil não esta aberto')
        if tempo_aberto >= tempo_maximo:
            try:
                print('tempo limite de xfoil aberto ultrapassado')
                os.kill(processID)
            except:
                print('xfoil PID = {} não pode ser fechado tentando outro método'.format(processID))
                try:
                    os.system('TASKKILL /F /IM xfoil.exe')
                except:
                    print('xfoil PID = {} não pode ser fechado pelo outro método'.format(processID))
                else:
                    print('xfoil foi fechado')
            else:
                print('xfoil foi fechado')
    return None

## Função que acha o indice no vetor do valor mais próximo ao dado como entrada

def I_search(vet,val):
    return np.where(abs(vet-val) == min(abs(vet-val)))[0][0]



## Função que retorna um dicionario com os parametros de um run que ainda não foi rodado

def to_do_run(aerosqldb):

    try: 
        with aerosqldb.cursor() as cursor:

            line_select_to_do_run = "SELECT RunID , AirfoilID , Ncrit , Mach , Reynolds  FROM Runs WHERE  Status  = 'ToDo' AND  `Source`  = 'Xfoil' LIMIT 1 FOR UPDATE;"

            cursor.execute(line_select_to_do_run)
            result_to_do_run = cursor.fetchone()

            line_update_to_do_run = "UPDATE  Runs  SET  `Status`  = 'Doing', AdditionalData = '{}' WHERE  RunID  = {}".format(os.getenv('computername'),result_to_do_run[0])
            cursor.execute(line_update_to_do_run)
            cursor.connection.commit()

            to_do_run_parameters = {'RunID':result_to_do_run[0],'AirfoilID':result_to_do_run[1],'Ncrit':result_to_do_run[2],'Mach':result_to_do_run[3],'Reynolds':result_to_do_run[4]}

    finally:

        return to_do_run_parameters

## Função que retorna um dicionario com os parametros de um run a partir do RunID fornecido

# def run_parameters(aerosqldb,RunID = 1):

#     try: 
#         with aerosqldb.cursor() as cursor:

#             line_select_run = "SELECT RunID, AirfoilID , Ncrit , Mach , Reynolds  FROM Runs WHERE RunID = {} AND  `Source`  = 'Xfoil' LIMIT 1;".format(RunID)

#             cursor.execute(line_select_run)
#             results_run = cursor.fetchone()

#             run_parameters = {'RunID':results_run[0],'AirfoilID':results_run[1],'Ncrit':results_run[2],'Mach':results_run[3],'Reynolds':results_run[4]}

#     finally:

#         return run_parameters


## Função que a partir dos dados de uma Polar gera as informações que serão inseridas no PolarProperties como Cl_max, Cl_alpha e as retornam em um dicionario

def gera_polar_properties(Polar_data, i_alpha_lin = -2, f_alpha_lin = 4):

    # Define os indices com os valores mais próximos de i_alpha_lin e f_alpha_lin no vetor de alphas calculados

    linear_range = [I_search(Polar_data['alpha'],i_alpha_lin), I_search(Polar_data['alpha'],f_alpha_lin)]

    p_Cl_lin = np.polyfit(Polar_data['alpha'][linear_range[0]:linear_range[1]], Polar_data['CL'][linear_range[0]:linear_range[1]],1)

    Cl_alpha = p_Cl_lin[0]

    Cl_0 = p_Cl_lin[1]


    Cl_max_init_flag = 0
    Cl_max = 0
    Alpha_stall = 0

    for i_alpha in range(linear_range[1],len(Polar_data['alpha'])):

        Cl = Polar_data['CL'][i_alpha]

        if Cl_max_init_flag == 0:
            Cl_max_init_flag = 1
            Cl_max_atual = Cl
        if Cl > Cl_max_atual:
            Cl_max_atual = Cl
        if Cl_max_atual - Cl >= 0.017:
            I_s_max_cen = I_search(Polar_data['CL'],Cl_max_atual)
            A_s_max_cen = Polar_data['alpha'][I_s_max_cen]
            I_s_max_inf = I_search(Polar_data['alpha'], A_s_max_cen - 1.75)
            I_s_max_sup = I_search(Polar_data['alpha'], A_s_max_cen + 1.75)
            Cl_max = max(Polar_data['CL'][I_s_max_inf:I_s_max_sup])
            Alpha_stall = Polar_data['alpha'][I_search(Polar_data['CL'],Cl_max)]
            break


        
    Cd_min = min(Polar_data['CD'])

    Cd_max = max(Polar_data['CD'])

    Cl_Cd_max = max(np.array(Polar_data['CL'])/np.array(Polar_data['CD']))

    Cm_0 = Polar_data['CM'][np.where(abs(Polar_data['alpha']) == min(abs(Polar_data['alpha'])))[0][0]]

    Alpha_0_Cl = np.roots(p_Cl_lin)[0]

    Alpha_Cl_Cd_max = Polar_data['alpha'][np.where(np.array(Polar_data['CL'])/np.array(Polar_data['CD']) == Cl_Cd_max)[0][0]]

    Polar_Properties = {'Cl_max':Cl_max, 'Cl_0':Cl_0, 'Cl_alpha':Cl_alpha, 'Cd_min':Cd_min, 'Cd_max':Cd_max, 'Cl_Cd_max':Cl_Cd_max, 'Cm_0':Cm_0, 'Alpha_stall':Alpha_stall, 'Alpha_0_Cl':Alpha_0_Cl, 'Alpha_Cl_Cd_max':Alpha_Cl_Cd_max}
    
    return Polar_Properties



## Função que a partir das informações de um run não rodado, chama o xfoil e insere uma polar no banco de dados, informando ao banco quando começa e termina esse trabalho 

def call_xfoil_to_do_run(aerosqldb):

    line_failed_run = "UPDATE Runs SET `Status` = 'Failed', AdditionalData = '{}' WHERE  RunID  = {};"

    with aerosqldb.cursor() as cursor:  

        # Obtemos os dados de uma run com status = ToDo

        try:
            to_do_run_data = to_do_run(aerosqldb)
        except:
            print('Não foi possível obter o to_do_run_data')
            return None




        # Chamamos a função que cria o arquivo de coordenadas e armazenamos o nome desse arquivo

        try:
            filename = cria_arquivo_coordenadas(aerosqldb,to_do_run_data['AirfoilID'])
        except:
            try:
                cursor.execute(line_failed_run.format('aifoil_file_creation_failed',to_do_run_data['RunID']))

                cursor.connection.commit()
            except:
                print('O Status do Run {} não pode ser atualizado como Failed em airfoil_file_creation_failed'.format(to_do_run_data['RunID']))
            else:
                print('O Status do Run {} foi atualizado para Failed em airfoil_file_creation_failed'.format(to_do_run_data['RunID']))
            return None



        alphas_1 = np.concatenate((np.arange(0,14,0.25),np.arange(14 ,18.55,0.1)))

        alphas_2 = np.concatenate((np.arange(0,-10,-0.25),np.arange(-10,-14.5,-0.125),np.arange(-14.5,-18.01,-0.1)))

        # Chama o mata_foil em um processo separado para matar o processo do xfoil caso ele falhe

        mata_xfoil_obj =mp.Process(target=mata_xfoil)

        mata_xfoil_obj.start()



        # Chamada ao Xfoil a partir dos dados fornecidos pelo to_run_data para que ele gere a polar com alphas positivos

        try:
            chama_xfoil.roda_xfoil(Airfoil_file = filename,alphas = alphas_1, Reynolds = to_do_run_data['Reynolds'], Mach = float(to_do_run_data['Mach']), output = 'Polar',iter=300,Pane = True, nPane = 350)
        except:
            try:
                cursor.execute(line_failed_run.format('roda_xfoil_failed',to_do_run_data['RunID']))

                cursor.connection.commit()
            except:
                print('O Status do Run {} não pode ser atualizado como Failed em roda_xfoil_failed'.format(to_do_run_data['RunID']))
            else:
                print('O Status do Run {} foi atualizado para Failed em roda_xfoil_failed'.format(to_do_run_data['RunID']))
            return None


        # Termina o processo que roda o mataxfoil para que ele não mate a próxima run

        mata_xfoil_obj.terminate()

        print('xfoil fez a polar 1')
    
        # Chama o mata_foil em um processo separado para matar o processo do xfoil caso ele falhe

        mata_xfoil_obj =mp.Process(target=mata_xfoil)

        mata_xfoil_obj.start()


        # Chamada ao Xfoil a partir dos dados fornecidos pelo to_run_data para que ele gere a polar com alphas negativos

        try:
            chama_xfoil.roda_xfoil(Airfoil_file = filename,alphas = alphas_2, Reynolds = to_do_run_data['Reynolds'], Mach = float(to_do_run_data['Mach']), output = 'Polar',iter=300,Pane = True, nPane = 350)
        except:
            try:
                cursor.execute(line_failed_run.format('roda_xfoil_failed',to_do_run_data['RunID']))

                cursor.connection.commit()
            except:
                print('O Status do Run {} não pode ser atualizado como Failed em roda_xfoil_failed'.format(to_do_run_data['RunID']))
            else:
                print('O Status do Run {} foi atualizado para Failed em roda_xfoil_failed'.format(to_do_run_data['RunID']))
            return None


        # Termina o processo que roda o mataxfoil para que ele não mate a próxima run

        mata_xfoil_obj.terminate()

        print('xfoil fez a polar 2')

        # Obtem os dados das Runs a partir dos arquivos e junta eles em uma dict chamado Polar_data_total

        try:
            Polar_data_alpha_positivo = xf.output_reader(filename = "Polar_{}_0.0_18.5".format(filename),output = 'Polar')
        except:
            try:
                mata_xfoil_obj =mp.Process(target=mata_xfoil)
                mata_xfoil_obj.start()
                chama_xfoil.roda_xfoil(Airfoil_file = filename,alphas = alphas_1, Reynolds = to_do_run_data['Reynolds'], Mach = float(to_do_run_data['Mach']), output = 'Polar',iter=300,Pane = True, nPane = 350)
                mata_xfoil_obj.terminate()
                Polar_data_alpha_positivo = xf.output_reader(filename = "Polar_{}_0.0_18.5".format(filename),output = 'Polar')
            except:
                try:
                    cursor.execute(line_failed_run.format('Polar_file_not_found',to_do_run_data['RunID']))

                    cursor.connection.commit()
                except:
                    print('O Status do Run {} não pode ser atualizado como Failed em Polar_file_not_found'.format(to_do_run_data['RunID']))
                else:
                    print('O Status do Run {} foi atualizado para Failed em Polar_file_not_found'.format(to_do_run_data['RunID']))
                return None


        try:
            Polar_data_alpha_negativo = xf.output_reader(filename = "Polar_{}_0.0_-18.0".format(filename),output = 'Polar')
        except:
            try:
                mata_xfoil_obj =mp.Process(target=mata_xfoil)
                mata_xfoil_obj.start()
                chama_xfoil.roda_xfoil(Airfoil_file = filename,alphas = alphas_2, Reynolds = to_do_run_data['Reynolds'], Mach = float(to_do_run_data['Mach']), output = 'Polar',iter=300,Pane = True, nPane = 350)
                mata_xfoil_obj.terminate()
                Polar_data_alpha_positivo = xf.output_reader(filename = "Polar_{}_0.0_18.5".format(filename),output = 'Polar')
            except:
                try:
                    cursor.execute(line_failed_run.format('Polar_file_not_found',to_do_run_data['RunID']))

                    cursor.connection.commit()
                except:
                    print('O Status do Run {} não pode ser atualizado como Failed em Polar_file_not_found'.format(to_do_run_data['RunID']))
                else:
                    print('O Status do Run {} foi atualizado para Failed em Polar_file_not_found'.format(to_do_run_data['RunID']))
                return None


        try:
            Polar_data_total = {'alpha':np.array(Polar_data_alpha_negativo['alpha'][::-1]+Polar_data_alpha_positivo['alpha']),'CL':np.array(Polar_data_alpha_negativo['CL'][::-1]+Polar_data_alpha_positivo['CL']),'CD':np.array(Polar_data_alpha_negativo['CD'][::-1]+Polar_data_alpha_positivo['CD']),'CM':np.array(Polar_data_alpha_negativo['CM'][::-1]+Polar_data_alpha_positivo['CM'])}           
        except:
            try:
                cursor.execute(line_failed_run.format('Polar_data_total_creation_failed',to_do_run_data['RunID']))

                cursor.connection.commit()
            except:
                print('O Status do Run {} não pode ser atualizado como Failed em Polar_data_total_creation_failed'.format(to_do_run_data['RunID']))
            else:
                print('O Status do Run {} foi atualizado para Failed em Polar_data_total_creation_failed'.format(to_do_run_data['RunID']))
            return None



        # Se existe ao menos um valor de alpha nos arquivos de polares segue o processo e insere os dados no banco de dados
        # Caso o contrario insere no run o Status = 'Failed'

        if len(Polar_data_total['alpha']) != 0:

            line_insert_Polar = "INSERT INTO Polars ( RunId , AirfoilID , Alpha , Cl , Cd , Cm ) VALUES "
        
            for i_alpha in range(len(Polar_data_total['alpha'])):

                if i_alpha != len(Polar_data_total['alpha'])-1:
                    line_insert_Polar = line_insert_Polar+"({},{},{},{},{},{}),".format(to_do_run_data['RunID'],to_do_run_data['AirfoilID'],Polar_data_total['alpha'][i_alpha],Polar_data_total['CL'][i_alpha],Polar_data_total['CD'][i_alpha],Polar_data_total['CM'][i_alpha])
                else:
                    line_insert_Polar = line_insert_Polar+"({},{},{},{},{},{});".format(to_do_run_data['RunID'],to_do_run_data['AirfoilID'],Polar_data_total['alpha'][i_alpha],Polar_data_total['CL'][i_alpha],Polar_data_total['CD'][i_alpha],Polar_data_total['CM'][i_alpha])

            # Inserimos a Polar no Bando de dados

            try:
                cursor.execute(line_insert_Polar)

                cursor.connection.commit()
            except:
                print('A Polar da Run {} não pode ser inserida'.format(to_do_run_data['RunID']))

                try:
                    cursor.execute(line_failed_run.format('Polar_Not_Inserd',to_do_run_data['RunID']))

                    cursor.connection.commit()
                except:
                    print('O Status do Run {} não pode ser atualizado como Failed em Polar_Not_Inserd'.format(to_do_run_data['RunID']))
                else:
                    print('O Status do Run {} foi atualizado para Failed em Polar_Not_Inserd'.format(to_do_run_data['RunID']))
            else:
                print('A Polar da Run {} foi inserida'.format(to_do_run_data['RunID']))

                # Atualizamos a Run como Done

                try:
                    line_done_run = "UPDATE Runs SET `Status` = 'Done', AdditionalData = '{}' WHERE  RunID  = {};".format('N_Panels = {}; iter = {}'.format(350,300), to_do_run_data['RunID'])

                    cursor.execute(line_done_run)

                    cursor.connection.commit()
                except:
                    print('O Status do Run {} não pode ser atualizado como Done'.format(to_do_run_data['RunID']))
                else:
                    print('O Status do Run {} foi atualizado para Done'.format(to_do_run_data['RunID']))
    
                # Geramos as propriedades da Polar

                try:
                    Polar_properties = gera_polar_properties(Polar_data_total)
                except:
                    print('O Polar_properties do Run {} não pode gerado'.format(to_do_run_data['RunID']))
                else:
                    print('O Polar_properties do Run {} foi gerado'.format(to_do_run_data['RunID']))

                # Inserimos os dados do Polar_properties no banco de dados

                try:
                    line_insert_Polar_properties = "INSERT INTO  PolarProperties  ( RunID , AirfoilID , Cl_max , Cl_0 , Cl_alpha , Cd_min, Cd_max , Cl_Cd_max , Cm_0 , Alpha_stall , Alpha_0_Cl , Alpha_Cl_Cd_max ) VALUES ({},{},{},{},{},{},{},{},{},{},{},{});".format(to_do_run_data['RunID'],to_do_run_data['AirfoilID'],Polar_properties['Cl_max'],Polar_properties['Cl_0'],Polar_properties['Cl_alpha'],Polar_properties['Cd_min'],Polar_properties['Cd_max'],Polar_properties['Cl_Cd_max'],Polar_properties['Cm_0'],Polar_properties['Alpha_stall'],Polar_properties['Alpha_0_Cl'],Polar_properties['Alpha_Cl_Cd_max'])

                    cursor.execute(line_insert_Polar_properties)

                    cursor.connection.commit()
                except:
                    print('O Polar_properties do Run {} não pode ser inserido no Banco de dados'.format(to_do_run_data['RunID']))
                else:
                    print('O Polar_properties do Run {} foi inserido no Banco de dados'.format(to_do_run_data['RunID']))
                



        else:

            try:
                cursor.execute(line_failed_run.format('No_alpha_genereted',to_do_run_data['RunID']))

                cursor.connection.commit()
            except:
                print('O Status do Run {} não pode ser atualizado como Failed em No_alpha_genereted'.format(to_do_run_data['RunID']))
            else:
                print('O Status do Run {} foi atualizado para Failed em No_alpha_genereted'.format(to_do_run_data['RunID']))



        # O arquivo de geometria do aerofólio é deletado

        try:
            os.remove(filename)
        except:
            print('não foi possível remover o arquivo de geometria do Run {}'.format(to_do_run_data['RunID']))
        else:
            print('o arquivo de geometria do Run {} foi removido'.format(to_do_run_data['RunID']))



        try:
            os.remove("Polar_{}_0.0_18.5".format(filename))
            os.remove("Polar_{}_0.0_-18.0".format(filename))
        except:
            print('não foi possível remover os arquivos de polares do Run {}'.format(to_do_run_data['RunID']))
        else:
            print('arquivos de polares do Run {} foram removidos'.format(to_do_run_data['RunID']))


        return None




if __name__ == '__main__':

    aerosqldb = sql.connect(host='aerosqlrestore.c4co31zewwzk.us-east-1.rds.amazonaws.com',
    user='',
    password='',
    db='AeroSQLDB')


    while True:
        call_xfoil_to_do_run(aerosqldb)