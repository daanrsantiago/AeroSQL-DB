function [varargout] = Aero_SQL_geometrie(AirfoilNameID,varargin)

p = inputParser;
addRequired(p,'AirfoilNameID',@(x) assert((isnumeric(x) && isscalar(x) && (x > 0)) || isstring(x),"it's required to give some Airfoil identification method by giving it's ID or name"));
addParameter(p,'Source','UIUC Airfoil Coordinates Database',@(x) assert(isstring(x),'Source name must be a sring'));
addParameter(p,'Creator_username','daanrsantiago',@(x) assert(isstring(x),'Creator_username must be a sring'))
addParameter(p,'Output',"unified surfaces",@(x) any(validatestring(x,{'unified surfaces','separate surfaces','Cl','Cd','Cm'})));
parse(p,AirfoilNameID,varargin{:});

conn = database('AeroSQLDB_Reader_servidor_daniel','Reader','');

if isstring(AirfoilNameID)
	AirfoilData = fetch(conn,sprintf("SELECT * FROM Airfoils WHERE `Name` LIKE '%s%%' LIMIT 1;",p.Results.AirfoilNameID));
	AirfoilID = AirfoilData.AirfoilID;
else
	AirfoilID = p.Results.AirfoilNameID;
	AirfoilData = fetch(conn,sprintf("SELECT * FROM Airfoils WHERE AirfoilID = %u LIMIT 1;",AirfoilID));
end	


geometrie_table = fetch(conn, sprintf('SELECT * FROM geometries	WHERE AirfoilID = %u;',AirfoilID));

I_Nans_perfil = ~isnan(geometrie_table.X);


if p.Results.Output == "unified surfaces"
	varargout{1} = [geometrie_table.X(I_Nans_perfil), geometrie_table.Y(I_Nans_perfil)];
end

if p.Results.Output == "separate surfaces"
	I_Bottom = strcmp(geometrie_table.Side,'Bottom');
	I_Top = ~I_Bottom;
	
	Y_Bottom = geometrie_table.Y(I_Bottom&I_Nans_perfil);
	Y_Top = geometrie_table.Y(I_Top&I_Nans_perfil);
	
	[X_Bottom_unicos, I_unicos_Bottom] = unique(geometrie_table.X(I_Bottom&I_Nans_perfil),'stable');
	Y_Bottom_unicos = Y_Bottom(I_unicos_Bottom);
	
	[X_Top_unicos, I_unicos_Top] = unique(geometrie_table.X(I_Top&I_Nans_perfil),'stable');
	Y_Top_unicos = Y_Top(I_unicos_Top);
	
	
	varargout{1} = [X_Bottom_unicos Y_Bottom_unicos];
	varargout{2} = [X_Top_unicos, Y_Top_unicos];
end

end