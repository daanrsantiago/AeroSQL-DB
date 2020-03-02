import numpy as np
import matplotlib.pyplot as plt
import pymysql as sql
import AeroSQLDB_Utilities as uti
import time
import pandas
import os
import scipy.stats

## Conexão ao banco de dados

aerosqldb = sql.connect(host='aerosqlrestore.c4co31zewwzk.us-east-1.rds.amazonaws.com',
user='Reader',
password='',
db='AeroSQLDB')

cursor = aerosqldb.cursor()

def I_search(vet,val):
    try: 
        I = np.where(abs(np.array(vet)-np.array(val)) == np.array(min(abs(np.array(vet)-np.array(val)))))[0][0]
        return I 
    except:
        print('Error Finding Index in I_serach, returning None')
        return None


def generate_polar_properties(Polar_data, i_alpha_lin = -2, f_alpha_lin = 4):

    # Define os indices com os valores mais próximos de i_alpha_lin e f_alpha_lin no vetor de alphas calculados

    linear_range = [I_search(Polar_data['Alpha'],i_alpha_lin), I_search(Polar_data['Alpha'],f_alpha_lin)]

    Cl_alpha, Cl_0, r_value, p_value, std_err= scipy.stats.linregress(Polar_data['Alpha'][linear_range[0]:linear_range[1]], Polar_data['Cl'][linear_range[0]:linear_range[1]])

    Cl_max_init_flag = 0
    Cl_max = 0
    Alpha_stall = 0

    for i_alpha in range(linear_range[1],len(Polar_data['Alpha'])):

        Cl = Polar_data['Cl'][i_alpha]

        if Cl_max_init_flag == 0:
            Cl_max_init_flag = 1
            Cl_max_atual = Cl
        if Cl > Cl_max_atual:
            Cl_max_atual = Cl
        if Cl_max_atual - Cl >= 0.017:
            I_s_max_cen = I_search(Polar_data['Cl'],Cl_max_atual)
            A_s_max_cen = Polar_data['Alpha'][I_s_max_cen]
            I_s_max_inf = I_search(Polar_data['Alpha'], A_s_max_cen - 1.75)
            I_s_max_sup = I_search(Polar_data['Alpha'], A_s_max_cen + 1.75)
            Cl_max = max(Polar_data['Cl'][I_s_max_inf:I_s_max_sup])
            Alpha_stall = Polar_data['Alpha'][I_search(Polar_data['Cl'],Cl_max)]
            break


        
    Cd_min = min(Polar_data['Cd'])

    Cd_max = max(Polar_data['Cd'])

    Cl_Cd_max = max(np.array(Polar_data['Cl'])/np.array(Polar_data['Cd']))

    Cm_0 = Polar_data['Cm'][np.where(abs(Polar_data['Alpha']) == min(abs(Polar_data['Alpha'])))[0][0]]

    Alpha_0_Cl = np.roots([Cl_alpha, Cl_0])[0]

    try:
        Alpha_Cl_Cd_max = Polar_data['Alpha'][I_search(np.array(Polar_data['Cl'])/np.array(Polar_data['Cd']), Cl_Cd_max)]
    except:
        Alpha_Cl_Cd_max = 0

    Polar_Properties = {'Cl_max':Cl_max, 'Cl_0':Cl_0, 'Cl_alpha':Cl_alpha, 'Cd_min':Cd_min, 'Cd_max':Cd_max, 'Cl_Cd_max':Cl_Cd_max, 'Cm_0':Cm_0, 'Alpha_stall':Alpha_stall, 'Alpha_0_Cl':Alpha_0_Cl, 'Alpha_Cl_Cd_max':Alpha_Cl_Cd_max}
    
    return Polar_Properties

def ExtendPolar(PolProp, alpha_i = 0, alpha_f = 110, passo = 0.5, CL90 = 0.01, CD90 = 2, Polar_data = None,  i_alpha_lin = -9, f_alpha_lin = 14):
    if PolProp['Cl_max'] != 0:
        alpha_ext = np.arange(alpha_i,alpha_f,passo)


        if Polar_data != None:
            # Obtendo região linear novamente para teste
            PolProp2 = generate_polar_properties(Polar_data, i_alpha_lin, f_alpha_lin)

            # Região potencial da polar
            CL_pot = PolProp2['Cl_0'] + alpha_ext*PolProp2['Cl_alpha']

            # Valores necessários para a utilização do método de obtenção de polar de uma placa plana
            delta_1 = 57.6*CL90*np.sin(np.deg2rad(alpha_ext))
            delta_2 = PolProp2['Alpha_0_Cl']*np.cos(np.deg2rad(alpha_ext))
            Beta = alpha_ext-delta_1-delta_2
            A = 1+PolProp2['Cl_0']/np.sin(np.pi/4)*np.sin(np.deg2rad(alpha_ext))

            # Região não potencial da polar
            CL_plate = A*CD90*np.sin(np.deg2rad(Beta))*np.cos(np.deg2rad(Beta))
            CD_plate = CD90*np.sin(np.deg2rad(alpha_ext))**2

        else:
            # Região potencial da polar
            CL_pot = PolProp['Cl_0'] + alpha_ext*PolProp['Cl_alpha']

            # Valores necessários para a utilização do método de obtenção de polar de uma placa plana
            delta_1 = 57.6*CL90*np.sin(np.deg2rad(alpha_ext))
            delta_2 = PolProp['Alpha_0_Cl']*np.cos(np.deg2rad(alpha_ext))
            Beta = alpha_ext-delta_1-delta_2
            A = 1+PolProp['Cl_0']/np.sin(np.pi/4)*np.sin(np.deg2rad(alpha_ext))

            # Região não potencial da polar
            CL_plate = A*CD90*np.sin(np.deg2rad(Beta))*np.cos(np.deg2rad(Beta))
            CD_plate = CD90*np.sin(np.deg2rad(alpha_ext))**2


        alpha_1 = PolProp['Alpha_stall']
        CL1 = PolProp['Cl_max']
        alpha_2 = alpha_1 + 15
        CL2 = CL_plate[I_search(alpha_ext,alpha_2)] + 0.03

        I_alpha_1 = I_search(alpha_ext,alpha_1)
        I_alpha_2 =  I_search(alpha_ext,alpha_2)
        f1 = (CL1 - CL_plate[I_alpha_1])/(CL_pot[I_alpha_1] - CL_plate[I_alpha_1])
        f2 = (CL2 - CL_plate[I_alpha_2])/(CL_pot[I_alpha_2] - CL_plate[I_alpha_2])
        G = ((1/f1-1)/(1/f2-1))**(1/4)
        alpha_M = (alpha_1-G*alpha_2)/(1-G)
        k = (1/f2-1)*1/(alpha_2-alpha_M)**4

        delta_alpha = alpha_M-alpha_ext
        f = 1/(1+k*delta_alpha**4)

        Cl_ext = f*CL_pot + (1-f)*CL_plate


        Polar_ext = {'Alpha':alpha_ext, 'Cl':Cl_ext, 'Cd': CD_plate, 'Cl_pot': CL_pot, 'Cl_plate':CL_plate} 

        

        return Polar_ext
    else:
        print('Cl max do Run não disponível em PolarProperties')
        return None



def FitExtendedPolar(Polar, Polar_ext, PolProp, dist_stall = 2):

    if PolProp['Cl_max'] != 0:
        # Escolhendo o ponto de união entre as curvas e encontrando quais os indices das duas curvas que chegam mais perto deste ponto
        I_alpha_glue_pol = I_search(Polar['Alpha'],PolProp['Alpha_stall']+dist_stall)
        alpha_glue_pol = Polar['Alpha'][I_alpha_glue_pol]
        I_aux_pol_ext = [I_search(Polar_ext['Alpha'],30), 1]
        I_aux_pol_ext[1] = I_search(Polar_ext['Cl'][1:I_aux_pol_ext[0]],max(Polar_ext['Cl'][1:I_aux_pol_ext[0]]))
        I_alpha_glue_pol_ext = I_aux_pol_ext[1] + I_search(Polar_ext['Cl'][I_aux_pol_ext[1]:I_aux_pol_ext[0]], Polar['Cl'][I_alpha_glue_pol])
        alpha_glue_pol_ext = Polar_ext['Alpha'][I_alpha_glue_pol_ext]

        Polar_ext['Cl'][I_alpha_glue_pol_ext] = Polar['Cl'][I_alpha_glue_pol]

        b_Cl = alpha_glue_pol/alpha_glue_pol_ext - 1
        b_Cd = Polar['Cd'][I_alpha_glue_pol]/Polar_ext['Cd'][I_alpha_glue_pol_ext] - 1

        I_c_pol_ext = I_search(Polar_ext['Alpha'],45)
        c = 45 - alpha_glue_pol_ext
        delta_alpha = Polar_ext['Alpha'] - alpha_glue_pol_ext

        f_Cl = 1 + b_Cl*(1-(delta_alpha/c))
        f_Cd = 1 + b_Cd*(1-(delta_alpha/c))

        alpha_glued = Polar_ext['Alpha'][I_alpha_glue_pol_ext:I_c_pol_ext]*f_Cl[I_alpha_glue_pol_ext:I_c_pol_ext]

        Cd_glued = Polar_ext['Cd'][I_alpha_glue_pol_ext:I_c_pol_ext]*f_Cd[I_alpha_glue_pol_ext:I_c_pol_ext]

        alpha_new = np.concatenate((alpha_glued, Polar_ext['Alpha'][I_c_pol_ext:-1]))

        Cd_new =  np.concatenate((Cd_glued, Polar_ext['Cd'][I_c_pol_ext:-1]))

        Polar_ext_glued = {'Alpha': np.concatenate((Polar['Alpha'][1:I_alpha_glue_pol], alpha_new)), 'Cl': np.concatenate((Polar['Cl'][1:I_alpha_glue_pol],Polar_ext['Cl'][I_alpha_glue_pol_ext:-1])), 'Cd': np.concatenate((Polar['Cd'][1:I_alpha_glue_pol], Cd_new)) }

        return Polar_ext_glued
    else:
        print('Cl max do Run não disponível em PolarProperties')
        return None


def to_do_extapolated_run(cursor):

    line_to_do_extrapolated_run = "SELECT * FROM Runs WHERE `Status` = 'ToDo' AND `Source` = 'Bjorn Montgomerie Extapolation Method' LIMIT 1 FOR UPDATE;"
    cursor.execute(line_to_do_extrapolated_run)

    result_to_do_run = cursor.fetchone()

    line_update_to_do_run = "UPDATE  Runs  SET  `Status`  = 'Doing', AdditionalData = '{}' WHERE  RunID  = {}".format(os.getenv('computername'),result_to_do_run[0])
    cursor.execute(line_update_to_do_run)
    cursor.connection.commit()

    to_do_run_data = {'RunID':result_to_do_run[0],'AirfoilID':result_to_do_run[1],'Ncrit':result_to_do_run[2],'Mach':result_to_do_run[3],'Reynolds':result_to_do_run[4]}

    return to_do_run_data


def call_extrapolated_to_do_run(cursor):
    # Obtemos uma Polar a ser preenchida

    # !!!!!!!!!!!!!!!!!!!!! Corrigir as PolarProperties Faltantes !!!!!!!!!!!!!!!!!!!!!!!

    to_do_run_data = to_do_extapolated_run(cursor)    # !!!!!!!!!!!!!!!!!!!!! Criar função que preenche o banco de dados com esses to_do's !!!!!!!!!!!!!!!!!!

    # A partir dos dados do to_do_run_data obtemos a Polar e a PolarProperties correspondentes

    Polar = uti.PolarByID(cursor, RunID)

    PolarProperties = uti.PolarPropertiesByRunID(cursor, RunID)

    # Obtemos as polares extendidas 

    Polar_ext = ExtendPolar(PolarProperties)

    Polar_ext_fited = FitExtendedPolar(Polar, Polar_ext, PolarProperties)

    # Inserimos os dados no banco de dados

    line_insert_Polar = "INSERT INTO Polars ( RunId , AirfoilID , Alpha , Cl , Cd) VALUES "

    for i_alpha in range(len(Polar_ext_fited['Alpha'])):

        # !!!!!!!!!!!!! Mudar os valores !!!!!!!!!!!!!
        if i_alpha != len(Polar_ext_fited['Alpha'])-1:
            line_insert_Polar = line_insert_Polar+"({},{},{},{},{},{}),".format(to_do_run_data['RunID'],to_do_run_data['AirfoilID'],Polar_data_total['alpha'][i_alpha],Polar_data_total['CL'][i_alpha],Polar_data_total['CD'][i_alpha],Polar_data_total['CM'][i_alpha])
        else:
            line_insert_Polar = line_insert_Polar+"({},{},{},{},{},{});".format(to_do_run_data['RunID'],to_do_run_data['AirfoilID'],Polar_data_total['alpha'][i_alpha],Polar_data_total['CL'][i_alpha],Polar_data_total['CD'][i_alpha],Polar_data_total['CM'][i_alpha])

    cursor.execute(line_insert_Polar)

    return None


# Naca 4415 Re = 0.25 10^6
# RunID = 214752

# Naca 4415 Re = 0.5 10^6
RunID = 214787

PolProp = uti.PolarPropertiesByRunID(cursor, RunID)
Polar = uti.PolarByID(cursor, RunID, dtype='NpArray')
Polar_ext = ExtendPolar(PolProp, Polar_data=Polar)
Polar_ext_glued = FitExtendedPolar(Polar, Polar_ext, PolProp,dist_stall=2)

Polar_Cl_Naca4415_05_Re = pandas.read_csv('Naca4415_Experimental_Cl_Re_0.5.csv',sep=';',names=['Alpha','Cl','Cd','Cm'],decimal=',')
Polar_Cd_Naca4415_05_Re = pandas.read_csv('4415 CD Re500.csv',sep=';',names=['Alpha','Cd'],decimal=',')
Polar_Cl_Naca4415_05_Re['Cd'] = np.interp(Polar_Cl_Naca4415_05_Re['Alpha'], Polar_Cd_Naca4415_05_Re['Alpha'], Polar_Cd_Naca4415_05_Re['Cd'])
PolProp_Experimental = generate_polar_properties(Polar_Cl_Naca4415_05_Re)
Polar_Experimental_ext = ExtendPolar(PolProp_Experimental)
Polar_Experimental_ext_glued = FitExtendedPolar(Polar_Cl_Naca4415_05_Re,Polar_Experimental_ext,PolProp_Experimental,dist_stall=2)


# plt.plot(Polar_Experimental_ext_glued['Alpha'], Polar_Experimental_ext_glued['Cl'])
plt.plot(Polar_Cl_Naca4415_05_Re['Alpha'], Polar_Cl_Naca4415_05_Re['Cl'])
# plt.plot(Polar_Experimental_ext['Alpha'],Polar_Experimental_ext['Cl'])
# plt.plot(Polar['Alpha'],Polar['Cl'])
# plt.plot(Polar_ext['Alpha'], Polar_ext['Cl'])
plt.plot(Polar_ext_glued['Alpha'], Polar_ext_glued['Cl'])
# plt.plot(Polar_ext['Alpha'], Polar_ext['Cl_pot'])
# plt.plot(Polar_ext['Alpha'], Polar_ext['Cl_plate'])
plt.title(r'Naca 4415 $Re = 0.5*10^{6}$')
# plt.title(r'Naca 4415 $Re = 0.5*10^{6}$')
# plt.legend(["C. Ostowari","Xfoil RunID = 214787"])
plt.legend(["C. Ostowari","Xfoil + Bjorn Montgomerie Modificado"])
plt.ylabel('Cl [-]')
plt.xlabel(r'$\alpha$ [º]')
# plt.axis([-20, 180, -1.5, 2])
plt.minorticks_on()
plt.grid(b=True, which= 'both')

plt.figure()
plt.plot(Polar_Cd_Naca4415_05_Re['Alpha'], Polar_Cd_Naca4415_05_Re['Cd'])
plt.plot(Polar_ext_glued['Alpha'],Polar_ext_glued['Cd'])
plt.title(r'Naca 4415 $Re = 0.5*10^{6}$')
plt.ylabel('Cd [-]')
plt.xlabel(r'$\alpha$ [º]')
plt.legend(["C. Ostowari","Xfoil + Bjorn Montgomerie Modificado"])
plt.minorticks_on()
plt.grid(b=True, which= 'both')

plt.figure()
plt.plot(Polar_Cd_Naca4415_05_Re['Alpha'], Polar_Cd_Naca4415_05_Re['Cd'])
plt.plot(Polar_Experimental_ext_glued['Alpha'],Polar_Experimental_ext_glued['Cd'])
plt.title(r'Naca 4415 $Re = 0.5*10^{6}$')
plt.ylabel('Cd [-]')
plt.xlabel(r'$\alpha$ [º]')
plt.legend(["C. Ostowari","C. Ostowari + Bjorn Montgomerie Modificado"], loc=2)
plt.minorticks_on()
plt.grid(b=True, which= 'both')

plt.show()

# while True:
#     call_extrapolated_to_do_run(cursor)




# for RunID in range(1,50):
#     PolProp = uti.PolarPropertiesByRunID(cursor, RunID)
#     Polar = uti.PolarByID(cursor, RunID)
#     Polar_ext = ExtendPolar(PolProp)

#     Polar_ext_glued = FitExtendedPolar(Polar, Polar_ext, PolProp,dist_stall=2)

#     try:
        # plt.plot(Polar_ext_glued['Alpha'], Polar_ext_glued['Cl'])
        # plt.plot(Polar['Alpha'], Polar['Cl'])
        # # plt.plot(Polar_ext['Alpha'], Polar_ext['Cl'])
        # plt.minorticks_on()
        # plt.title('RunID = {}'.format(RunID))
        # plt.grid(b=True, which= 'both')

#         plt.figure()
#         plt.plot(Polar_ext_glued['Alpha'], Polar_ext_glued['Cd'])
#         plt.plot(Polar['Alpha'], Polar['Cd'])
#         plt.minorticks_on()
#         plt.title('RunID = {}'.format(RunID))
#         plt.grid(b=True, which= 'both')

#         plt.show()
#     except:
#         pass

