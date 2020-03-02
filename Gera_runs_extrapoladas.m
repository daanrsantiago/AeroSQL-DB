% Código que preenche a tabela Runs do AeroSQL DataBase com Runs a serem extrapoladas
clear
clc

%% Conexão com o Banco de dados

conn = database('AeroSQLDB_MySQL','','');

%% Obtendo Runs a terem suas polares extrapoladas

airfoils = fetch(conn,"SELECT * FROM Airfoils;");

for i_airfoil = 44:height(airfoils)
	
	
	Runs = fetch(conn,sprintf("SELECT Runs.* FROM Runs JOIN PolarProperties ON PolarProperties.RunID = Runs.RunID WHERE Runs.Mach <= 0.6 AND Runs.Reynolds >= 80000 AND PolarProperties.Cl_max != 0 AND Runs.AirfoilID = %u AND Runs.Source = 'Xfoil';",airfoils.AirfoilID(i_airfoil)));
	
	Runs_Extrapolation(:).AirfoilID = Runs.AirfoilID;
	Runs_Extrapolation(:).Ncrit = 9*ones(height(Runs),1);
	Runs_Extrapolation(:).Mach = Runs.Mach;
	Runs_Extrapolation(:).Reynolds = Runs.Reynolds(:);
	Runs_Extrapolation(:).Source = "Bjorn Montgomerie Extapolation Method" + strings(height(Runs),1);
	Runs_Extrapolation(:).Status = "ToDo" + strings(height(Runs),1);
	Runs_Extrapolation(:).AdditionalData = ("Based on Run;" + Runs.RunID) + strings(height(Runs),1);
	
	Table_Runs_Extrapolation = struct2table(Runs_Extrapolation);
	
	try
		sqlwrite(conn,'Runs',Table_Runs_Extrapolation);
	catch e
		e.identifier
	end
	
	i_airfoil
	
end