import matplotlib.pyplot as plt
import numpy as np

## Definindo função que retorna dict com polar a partir de um RunID

def PolarByID(cursor, RunID, Plot = None, dtype = 'list'):
    line_PolarByID = "SELECT Alpha, Cl, Cd, Cm FROM Polars WHERE RunID = {};".format(RunID)
    
    cursor.execute(line_PolarByID)

    Polar_Raw = cursor.fetchall()

    Polar = {'Alpha':list(), 'Cl':list(), 'Cd':list(), 'Cm':list()}

    for i_alpha in range(len(Polar_Raw)):
        Polar['Alpha'].append(float(Polar_Raw[i_alpha][0]))
        Polar['Cl'].append(float(Polar_Raw[i_alpha][1]))
        Polar['Cd'].append(float(Polar_Raw[i_alpha][2]))
        Polar['Cm'].append(float(Polar_Raw[i_alpha][3]))


    if dtype == 'NpArray':
        Polar['Alpha'] = np.array(Polar['Alpha'])
        Polar['Cl'] = np.array(Polar['Cl'])
        Polar['Cd'] = np.array(Polar['Cd'])
        Polar['Cm'] = np.array(Polar['Cm'])
    elif dtype == 'list':
        pass
    else:
        raise('dtype not recognized')


    if Plot == True:
        Run = RunByID(cursor, RunID)
        Airfoil = AirfoilByID(cursor, Run['AirfoilID'])

        plt.plot(Polar['Alpha'], Polar['Cl'])
        plt.minorticks_on()
        plt.grid(b = True,which='both')
        plt.xlabel('Alpha [°]')
        plt.ylabel('Cl')
        plt.title('{}   Mach = {} Re = {}'.format(Airfoil['File_name'],Run['Mach'],Run['Reynolds']))

        plt.figure()
        plt.plot(Polar['Alpha'], Polar['Cd'])
        plt.minorticks_on()
        plt.grid(b = True,which='both')
        plt.xlabel('Alpha [°]')
        plt.ylabel('Cd')
        plt.title('{}   Mach = {} Re = {}'.format(Airfoil['File_name'],Run['Mach'],Run['Reynolds']))

        plt.figure()
        plt.plot(Polar['Alpha'], Polar['Cm'])
        plt.minorticks_on()
        plt.grid(b = True,which='both')
        plt.xlabel("Alpha [°]")
        plt.ylabel('Cm')
        plt.title('{}   Mach = {} Re = {}'.format(Airfoil['File_name'],Run['Mach'],Run['Reynolds']))

        plt.show()

    return Polar


def GeometrieByID(cursor, AirfoilID, Plot = None):
    line_GeometrieByID = "SELECT X, Y FROM Geometries WHERE AirfoilID = {}".format(AirfoilID)

    cursor.execute(line_GeometrieByID)

    Geometrie_Raw = cursor.fetchall()

    Geometrie = {'X':list(), 'Y':list()}

    for i_point in range(len(Geometrie_Raw)):
        Geometrie['X'].append(float(Geometrie_Raw[i_point][0]))
        Geometrie['Y'].append(float(Geometrie_Raw[i_point][1]))

    if Plot == True:
        Airfoil = AirfoilByID(cursor, AirfoilID)

        plt.plot(Geometrie['X'], Geometrie['Y'])
        plt.title('{}  Thickness = {} Camber = {}'.format(Airfoil['Name'], Airfoil['Thickness'], Airfoil['Camber']))
        plt.minorticks_on()
        plt.grid(b=True, which='both')
        plt.axis('equal')
        plt.xlabel('X')
        plt.ylabel('Y')

        plt.show()

    return Geometrie


def AirfoilByID(cursor, AirofoilID, Plot = None):
    line_AirfoilByID = "SELECT * FROM Airfoils WHERE AirfoilID = {}".format(AirofoilID)

    cursor.execute(line_AirfoilByID)

    Airfoil_Raw = cursor.fetchall()

    Airfoil = {'AirfoilID':Airfoil_Raw[0][0], 'File_name':Airfoil_Raw[0][1], 'Name':Airfoil_Raw[0][2], 'Thickness':float(Airfoil_Raw[0][3]), 'X_Thickness':float(Airfoil_Raw[0][4]), 'Camber':float(Airfoil_Raw[0][5]), 'X_Camber':float(Airfoil_Raw[0][6]), 'Source':Airfoil_Raw[0][7], 'Creator_username':Airfoil_Raw[0][8]}

    if Plot == True:
        GeometrieByID(cursor, AirofoilID, Plot = True)

    return Airfoil


def RunByID(cursor, RunID):
    
    line_RunByID = "SELECT * FROM Runs WHERE RunID = {}".format(RunID)

    cursor.execute(line_RunByID)

    Run_Raw = cursor.fetchall()

    Run = {'RunID':Run_Raw[0][0], 'AirfoilID':Run_Raw[0][1], 'N_points':Run_Raw[0][2], 'Alpha_min':float(Run_Raw[0][3]), 'Alpha_max':float(Run_Raw[0][4]), 'N_crit':float(Run_Raw[0][5]), 'Mach':float(Run_Raw[0][6]), 'Reynolds':Run_Raw[0][7], 'Source': Run_Raw[0][8], 'RunDate': Run_Raw[0][9], 'Creator_username': Run_Raw[0][10], 'AdditionalData': Run_Raw[0][11]}

    return Run


def RunsByAirfoilID(cursor, AirfoilID):
    line_RunsByAirfoilID = "SELECT * FROM Runs WHERE AirfoilID = {}".format(AirfoilID)

    cursor.execute(line_RunsByAirfoilID)

    Runs_Raw = cursor.fetchall()

    Runs = {'RunID':list(), 'AirfoilID':list(), 'N_points':list(), 'Alpha_min':list(), 'Alpha_max':list(), 'N_crit':list(), 'Mach':list(), 'Reynolds':list(), 'Source': list(), 'RunDate': list(), 'Creator_username': list(), 'AdditionalData': list()}

    for i_run in range(len(Runs_Raw)):
        Runs['RunID'].append(Runs_Raw[i_run][0])
        Runs['AirfoilID'].append(Runs_Raw[i_run][1])
        Runs['N_points'].append(Runs_Raw[i_run][2])
        Runs['Alpha_min'].append(float(Runs_Raw[i_run][3]))
        Runs['Alpha_max'].append(float(Runs_Raw[i_run][4]))
        Runs['N_crit'].append(float(Runs_Raw[i_run][5]))
        Runs['Mach'].append(float(Runs_Raw[i_run][6]))
        Runs['Reynolds'].append(Runs_Raw[i_run][7])
        Runs['Source'].append(Runs_Raw[i_run][8])
        Runs['RunDate'].append(Runs_Raw[i_run][9])
        Runs['Creator_username'].append(Runs_Raw[i_run][10])
        Runs['AdditionalData'].append(Runs_Raw[i_run][11])

    return Runs


def PolarPropertiesByRunID(cursor, RunID):
    line_PolarPropertiesByRunID = "SELECT * FROM PolarProperties WHERE RunID = {};".format(RunID)

    cursor.execute(line_PolarPropertiesByRunID)

    PolarProperties_Raw = cursor.fetchall()

    PolarProperties = {'RunID': PolarProperties_Raw[0][0], 'AirfoilID': PolarProperties_Raw[0][1], 'Cl_max': float(PolarProperties_Raw[0][2]), 'Cl_0': float(PolarProperties_Raw[0][3]), 'Cl_alpha': float(PolarProperties_Raw[0][4]), 'Cd_min': float(PolarProperties_Raw[0][5]), 'Cd_max': float(PolarProperties_Raw[0][6]), 'Cl_Cd_max': float(PolarProperties_Raw[0][7]), 'Cm_0': float(PolarProperties_Raw[0][8]), 'Alpha_stall': float(PolarProperties_Raw[0][9]), 'Alpha_0_Cl': float(PolarProperties_Raw[0][10]), 'Alpha_Cl_Cd_max': float(PolarProperties_Raw[0][11]), 'Creator_username': PolarProperties_Raw[0][12]}

    return PolarProperties


def AirfoilByName(cursor, Name, type='File_name', Limit=1, Plot = None):
    if type == 'Name':
        line_type = 'Name'
    else:
        line_type = 'File_name'

    line_AirofoilByName = "SELECT * FROM Airfoils WHERE {} LIKE '%{}%' LIMIT {};".format(line_type, Name, Limit)

    cursor.execute(line_AirofoilByName)

    Airfoil_Raw = cursor.fetchall()

    if Limit == 1:
        Airfoil = {'AirfoilID':Airfoil_Raw[0][0], 'File_name':Airfoil_Raw[0][1], 'Name':Airfoil_Raw[0][2], 'Thickness':float(Airfoil_Raw[0][3]), 'X_Thickness':float(Airfoil_Raw[0][4]), 'Camber':float(Airfoil_Raw[0][5]), 'X_Camber':float(Airfoil_Raw[0][6]), 'Source':Airfoil_Raw[0][7], 'Creator_username':Airfoil_Raw[0][8]}

        if Plot == True:
            GeometrieByID(cursor, Airfoil['AirfoilID'], Plot = True)

    elif Limit > 1:
        Airfoil = {'AirfoilID':list(), 'File_name':list(), 'Name':list(), 'Thickness':list(), 'X_Thickness':list(), 'Camber':list(), 'X_Camber':list(), 'Source':list(), 'Creator_username':list()}

        for i_airfoil in range(len(Airfoil_Raw)):
            Airfoil['AirfoilID'].append(Airfoil_Raw[i_airfoil][0])
            Airfoil['File_name'].append(Airfoil_Raw[i_airfoil][1])
            Airfoil['Name'].append(Airfoil_Raw[i_airfoil][2])
            Airfoil['Thickness'].append(Airfoil_Raw[i_airfoil][3])
            Airfoil['X_Thickness'].append(Airfoil_Raw[i_airfoil][4])
            Airfoil['Camber'].append(Airfoil_Raw[i_airfoil][5])
            Airfoil['X_Camber'].append(Airfoil_Raw[i_airfoil][6])
            Airfoil['Source'].append(Airfoil_Raw[i_airfoil][7])
            Airfoil['Creator_username'].append(Airfoil_Raw[i_airfoil][8])

    return Airfoil


def PolarByRunData(cursor, AirfoilID, Reynolds, Mach=0, Source='Xfoil', CreatorUsername = 'daanrsantiago', minRunDate = None, maxRunDate = None, Plot = None):
    if minRunDate != None:
        line_minRunDate = " AND RunDate >= '{}'".format(minRunDate)
    else:
        line_minRunDate = None

    if maxRunDate != None:
        line_maxRunDate = " AND RunDate >= '{}'".format(maxRunDate)
    else:
        line_maxRunDate = None

    line_PolarByRunData = "SELECT RunID FROM Runs WHERE AirfoilID = {} AND Reynolds = {} AND Mach = {} AND Source = {} AND Creator_username LIKE {}{}{} LIMIT 1;".format(AirfoilID, Reynolds, Mach, Source, CreatorUsername, line_minRunDate, line_maxRunDate)

    cursor.execute(line_PolarByRunData)

    RunID = cursor.fetchall()

    if Plot == True:
        Polar = PolarByID(cursor, RunID, Plot=True)
    else:
        Polar = PolarByID(cursor, RunID)

    return Polar

