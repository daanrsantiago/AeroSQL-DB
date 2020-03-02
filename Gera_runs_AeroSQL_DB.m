clear
clc

%% Conexão com Banco de Dados

conn = database('AeroSQLDB_MySQL','','');

%% Parâmetros a serem inseridos nos Runs

Machs = [0 0.3 0.6 0.7 0.75 0.8];

Reynolds = [2e4:15e3:1e5 1.25e5:25e3:2.5e5 3e5:50e3:8e5 9e5:1e5:1.5e6];

n_airfoils = fetch(conn,'SELECT count(*) FROM Airfoils;');

n_airfoils = n_airfoils.count____1;

n_Mach = length(Machs);

n_Reynolds = length(Reynolds);

%% Inserindo os Runs no Banco de daos

Runs.Ncrit = 9;
Runs.Source = "Xfoil";
Runs.Status = "ToDo";

for i_airfoil = 1:n_airfoils
	
	for i_Mach = 1:n_Mach
		
		for i_Re = 1:n_Reynolds
			
			
			Runs((i_Mach-1)*n_Reynolds + i_Re).Ncrit = 9;
			Runs((i_Mach-1)*n_Reynolds + i_Re).Source = "Xfoil";
			Runs((i_Mach-1)*n_Reynolds + i_Re).Status = "ToDo";
			Runs((i_Mach-1)*n_Reynolds + i_Re).AirfoilID = i_airfoil;
			Runs((i_Mach-1)*n_Reynolds + i_Re).Mach = Machs(i_Mach);
			Runs((i_Mach-1)*n_Reynolds + i_Re).Reynolds = Reynolds(i_Re);
			
		end
	end
	
	fprintf('%i\n',i_airfoil)
	Table_runs = struct2table(Runs);
	sqlwrite(conn,'Runs',Table_runs);
end

