function [Polar,varargout] = Aero_SQL_Polar_data(AirfoilNameID,Re,varargin)


p = inputParser;
addRequired(p,'AirfoilNameID',@(x) assert((isnumeric(x) && isscalar(x) && (x > 0)) || isstring(x),"it's required to give some Airfoil identification method by giving it's ID or name"));
addOptional(p,'AditionalOutput',false,@(x) any(validatestring(x,{'PolarProperties'})))
addParameter(p,'N_Crit',9,@(x) assert(isnumeric(x) && isscalar(x) && (x >= 0),'N_crit must be numeric, scalar and greater than or equal 0'));
addParameter(p,'Mach',0,@(x) assert(isnumeric(x) && isscalar(x) && (x >= 0),'Mach n�mber must be numeric, scalar and greater than 0'));
addParameter(p,'Source','Xfoil',@(x) assert(isstring(x),'Source name must be a sring'))
addParameter(p,'Creator_username','daanrsantiago',@(x) assert(isstring(x),'Creator_username must be a sring'))
addRequired(p,'Re',@(x) assert(isnumeric(x) && isscalar(x) && (x > 0),'Reynolds n�mber must be numeric, scalar and greater than 0'));
addParameter(p,'Output',"Polar",@(x) any(validatestring(x,{'Polar','Alpha','Cl','Cd','Cm'})));
parse(p,AirfoilNameID,Re,varargin{:});

%% Conex�o ao banco de dados

conn = database('AeroSQLDB_MySQL_Reader','Reader','');

%% Obtendo outputs

if isstring(AirfoilNameID)
	AirfoilData = fetch(conn,sprintf("SELECT * FROM Airfoils WHERE `Name` LIKE '%s%%' LIMIT 1;",p.Results.AirfoilNameID));
	AirfoilID = AirfoilData.AirfoilID;
else
	AirfoilID = p.Results.AirfoilNameID;
	AirfoilData = fetch(conn,sprintf("SELECT * FROM Airfoils WHERE AirfoilID = %u LIMIT 1;",AirfoilID));
end	


RunData = fetch(conn,sprintf("SELECT * FROM Runs WHERE AirfoilID = %u AND Ncrit >= %.3f AND Mach >= %.3f AND Reynolds >= %u AND Source = '%s' AND Creator_username LIKE '%s%%' LIMIT 1;",AirfoilID,p.Results.N_Crit,p.Results.Mach,p.Results.Re,p.Results.Source,p.Results.Creator_username));
RunID = RunData.RunID;

if p.Results.Output == "Polar"
	Polar = fetch(conn,sprintf("SELECT Alpha, Cl, Cd, Cm FROM Polars WHERE RunID = %u;",RunID));
elseif p.Results.Output == "Alpha"
	Polar = fetch(conn,sprintf("SELECT Alpha FROM Polars WHERE RunID = %u;",RunID));
	Polar = Polar.Alpha;
elseif p.Results.Output == "Cl"
	Polar = fetch(conn,sprintf("SELECT Cl FROM Polars WHERE RunID = %u;",RunID));
	Polar = Polar.Cl;
elseif p.Results.Output == "Cd"
	Polar = fetch(conn,sprintf("SELECT Cd FROM Polars WHERE RunID = %u;",RunID));
	Polar = Polar.Cd;
elseif p.Results.Output == "Cm"
	Polar = fetch(conn,sprintf("SELECT Cm FROM Polars WHERE RunID = %u;",RunID));
	Polar = Polar.Cm;
end

varargout{1} = RunData;
varargout{2} = AirfoilData;

if strcmp(p.Results.AditionalOutput,'PolarProperties')
	varargout{3} = fetch(conn,sprintf("SELECT * FROM PolarProperties WHERE RunID = %u LIMIT 1;",RunID));
end

end