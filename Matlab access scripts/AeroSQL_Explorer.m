clear
clc

global AeroSQL_explorer Airfoils dir_exp delimiter form_exp

%% Diretório para armazenamento dos arquivos exportados padrão

dir_exp = pwd;

%% Formato e delimitador padrão para exportação

delimiter = ";";
form_exp = "csv";

%% Conexão com o banco de dados

conn = database('AeroSQLDB_MySQL_Reader','Reader','');

%% Obtendo Tabela Airfoils

Airfoils = fetch(conn,"SELECT * FROM Airfoils;");


%% Criando UI

% Janela Principal
AeroSQL_explorer.main_figure = uifigure();
AeroSQL_explorer.main_figure.Name = 'AeroSQL Database Explorer';
AeroSQL_explorer.main_figure.Position = [0 0 1100 730];

% Listbox com perfis disponíveis
AeroSQL_explorer.Perfis_listbox = uilistbox(AeroSQL_explorer.main_figure,'Items',Airfoils.Name,'ItemsData',1:length(Airfoils.Name));
AeroSQL_explorer.Perfis_listbox.Position = [20 100 330 AeroSQL_explorer.main_figure.Position(4)-140];
AeroSQL_explorer.Perfis_listbox.Tag = "perfis disponiveis";
AeroSQL_explorer.Perfis_listbox.ValueChangedFcn = @(listbox,event) muda_lista(listbox,event);

% Label indicando o que se trata a listbox
AeroSQL_explorer.label_Perfis_disp = uilabel(AeroSQL_explorer.main_figure,'Text','Perfis Disponíveis','Position',[20 AeroSQL_explorer.Perfis_listbox.Position(2)+AeroSQL_explorer.Perfis_listbox.Position(4)-5 100 25]);


% ---------------------------------------------------------------------- Menu ---------------------------------------------------------------------------------

AeroSQL_explorer.menu_opcoes_principal = uimenu(AeroSQL_explorer.main_figure,'Text',"&Opções");

% menu opções de exportação
AeroSQL_explorer.menu_opcoes_exp = uimenu(AeroSQL_explorer.menu_opcoes_principal, 'Text',"&Opções de Exportação");

AeroSQL_explorer.menu_opcoes_exp_dir_exp = uimenu(AeroSQL_explorer.menu_opcoes_exp, 'Text',"&Diretório de Exportação");
AeroSQL_explorer.menu_opcoes_exp_dir_exp.MenuSelectedFcn = @(menu, events) Seleciona_Menu(menu);

AeroSQL_explorer.menu_opcoes_exp_formato_arquivo =  uimenu(AeroSQL_explorer.menu_opcoes_exp, 'Text',"&Formato dos arquivos");
AeroSQL_explorer.menu_opcoes_exp_formato_arquivo.MenuSelectedFcn = @(menu, events) Seleciona_Menu(menu);

% menu Exportar
AeroSQL_explorer.menu_exportar = uimenu(AeroSQL_explorer.menu_opcoes_principal,'Text',"&Exportar");

AeroSQL_explorer.menu_exportar_geometria = uimenu(AeroSQL_explorer.menu_exportar, 'Text',"&Geometria");
AeroSQL_explorer.menu_exportar_geometria.MenuSelectedFcn = @(menu, events) Seleciona_Menu(menu);

AeroSQL_explorer.menu_exportar_Polar = uimenu(AeroSQL_explorer.menu_exportar, 'Text',"&Polar");
AeroSQL_explorer.menu_exportar_Polar_atual = uimenu(AeroSQL_explorer.menu_exportar_Polar, 'Text', "Polar Atual");
AeroSQL_explorer.menu_exportar_Polar_atual.MenuSelectedFcn = @(menu, events) Seleciona_Menu(menu);

AeroSQL_explorer.menu_exportar_Polar_todas = uimenu(AeroSQL_explorer.menu_exportar_Polar, 'Text', "Todas as Polares do Perfil Atual");
AeroSQL_explorer.menu_exportar_Polar_todas.MenuSelectedFcn = @(menu, events) Seleciona_Menu(menu);

% ---------------------------------------------------------------------- Tabs ---------------------------------------------------------------------------------

% TabGroup Para disponibilizar informações do perfil
AeroSQL_explorer.Perfis_tabgroup = uitabgroup(AeroSQL_explorer.main_figure);
AeroSQL_explorer.Perfis_tabgroup.Position([3 4]) = [700 AeroSQL_explorer.main_figure.Position(4)-20];
AeroSQL_explorer.Perfis_tabgroup.Position([1 2]) = [AeroSQL_explorer.main_figure.Position(3)-AeroSQL_explorer.Perfis_tabgroup.Position(3)-20 10];

% Tabs que vivem neste TabGroup
AeroSQL_explorer.tab_geometria = uitab(AeroSQL_explorer.Perfis_tabgroup,'Title','Geometria');
AeroSQL_explorer.tab_coeficientes = uitab(AeroSQL_explorer.Perfis_tabgroup,'Title','Coeficientes');

% ---------------------------------------------------------------------- Axes ---------------------------------------------------------------------------------

% Axes do Tab Geometria
AeroSQL_explorer.axes_geometria = uiaxes(AeroSQL_explorer.tab_geometria);
AeroSQL_explorer.axes_geometria.Position = [10 10 680 AeroSQL_explorer.main_figure.Position(4)-70];
grid(AeroSQL_explorer.axes_geometria,'minor')
axis(AeroSQL_explorer.axes_geometria,'equal')

% Axes do Tab Coeficientes
AeroSQL_explorer.axes_coeficientes = uiaxes(AeroSQL_explorer.tab_coeficientes);
AeroSQL_explorer.axes_coeficientes.Position = [10 10 680 AeroSQL_explorer.main_figure.Position(4)-60];
grid(AeroSQL_explorer.axes_coeficientes,'minor')

% ----------------------------------------------------------------- Dropdowns ---------------------------------------------------------------------------------

AeroSQL_explorer.dropdown_Source = uidropdown(AeroSQL_explorer.tab_coeficientes);
AeroSQL_explorer.dropdown_Source.Position = [AeroSQL_explorer.tab_coeficientes.Position(3)-500 AeroSQL_explorer.tab_coeficientes.Position(4)-70 80 25];
AeroSQL_explorer.dropdown_Source.Tag = "Source";
AeroSQL_explorer.dropdown_Source.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);

AeroSQL_explorer.dropdown_n_crit = uidropdown(AeroSQL_explorer.tab_coeficientes);
AeroSQL_explorer.dropdown_n_crit.Position = [AeroSQL_explorer.dropdown_Source.Position(1)+AeroSQL_explorer.dropdown_Source.Position(3)+10 AeroSQL_explorer.tab_coeficientes.Position(4)-70 80 25];
AeroSQL_explorer.dropdown_n_crit.Tag = "n_crit";
AeroSQL_explorer.dropdown_n_crit.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);

AeroSQL_explorer.dropdown_Mach = uidropdown(AeroSQL_explorer.tab_coeficientes);
AeroSQL_explorer.dropdown_Mach.Position = [AeroSQL_explorer.dropdown_n_crit.Position(1)+AeroSQL_explorer.dropdown_n_crit.Position(3)+10 AeroSQL_explorer.tab_coeficientes.Position(4)-70 80 25];
AeroSQL_explorer.dropdown_Mach.Tag = "Mach";
AeroSQL_explorer.dropdown_Mach.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);

AeroSQL_explorer.dropdown_Reynolds = uidropdown(AeroSQL_explorer.tab_coeficientes);
AeroSQL_explorer.dropdown_Reynolds.Position = [AeroSQL_explorer.dropdown_Mach.Position(1)+AeroSQL_explorer.dropdown_Mach.Position(3)+10 AeroSQL_explorer.tab_coeficientes.Position(4)-70 80 25];
AeroSQL_explorer.dropdown_Reynolds.Tag = "Reynolds";
AeroSQL_explorer.dropdown_Reynolds.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);

AeroSQL_explorer.dropdown_coeficiente = uidropdown(AeroSQL_explorer.tab_coeficientes,'Items',["Cl","Cd","Cm"],'ItemsData',["Cl","Cd","Cm"]);
AeroSQL_explorer.dropdown_coeficiente.Position = [AeroSQL_explorer.dropdown_Reynolds.Position(1)+AeroSQL_explorer.dropdown_Reynolds.Position(3)+10 AeroSQL_explorer.tab_coeficientes.Position(4)-70 80 25];
AeroSQL_explorer.dropdown_coeficiente.Tag = "Coeficiente";
AeroSQL_explorer.dropdown_coeficiente.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);

%% Funções

function muda_lista(listbox,event)

global AeroSQL_explorer Airfoils Polares geometria_perfil

conn = database('AeroSQLDB_MySQL_Reader','Reader','');

if listbox.Tag == "perfis disponiveis"
	
	AeroSQL_explorer.aux_Perfil = event.Value;
	
	%% Obtendo Geometria do perfil selecionado
	
	geometria_perfil = fetch(conn,sprintf("SELECT X,Y,Side FROM Geometries WHERE AirfoilID = %u;", Airfoils.AirfoilID(event.Value)));
	plot(AeroSQL_explorer.axes_geometria, geometria_perfil.X, geometria_perfil.Y)
	text(AeroSQL_explorer.axes_geometria,0.5,0.9,Airfoils.Name{listbox.Value},'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
	
	%% Obtendo Dados dos Runs
	
	% Tenta encontrar Polares para o aerofólio selecionado, se não encontra nada exibe erro
	
	try
		[Polares,~] = Estrutura_Polares(conn, Airfoils.AirfoilID(event.Value));
		
		AeroSQL_explorer.dropdown_Source.Items = Polares.Source.Value;
		AeroSQL_explorer.dropdown_Source.ItemsData = 1:length(Polares.Source.Value);
		AeroSQL_explorer.aux_Source = 1;
		
		AeroSQL_explorer.dropdown_n_crit.Items = string(Polares.Source.n_crit(1).Value);
		AeroSQL_explorer.dropdown_n_crit.ItemsData = 1:length(Polares.Source.n_crit(1).Value);
		AeroSQL_explorer.aux_n_crit = 1;
		
		AeroSQL_explorer.dropdown_Mach.Items = string(Polares.Source.n_crit(1).Mach(1).Value);
		AeroSQL_explorer.dropdown_Mach.ItemsData = 1:length(Polares.Source.n_crit(1).Mach(1).Value);
		AeroSQL_explorer.aux_Mach = 1;
		
		AeroSQL_explorer.dropdown_Reynolds.Items = string(Polares.Source.n_crit(1).Mach(1).Reynolds(1).Value);
		AeroSQL_explorer.dropdown_Reynolds.ItemsData = 1:length(Polares.Source.n_crit(1).Mach(1).Reynolds(1).Value);
		AeroSQL_explorer.aux_Reynolds = 1;
		
		AeroSQL_explorer.aux_Coeficiente = "Cl";
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(1).Mach(1).Reynolds(1).Polar(1).Value.Alpha,Polares.Source.n_crit(1).Mach(1).Reynolds(1).Polar(1).Value.Cl);
		text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name(listbox.Value),'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
		
		
		axis(AeroSQL_explorer.axes_coeficientes,[-25 30 -2 2.2]);
	catch
		
		errordlg('Não foram encontradas polares para este aerofólio')
		
	end	
end

end

function Seleciona_dropdown(dropdown,event)

global AeroSQL_explorer Polares Airfoils delimiter_dropdown inc_polar_properties_chkbox

if dropdown.Tag == "Source"
	
	I_n_crit = I_search(Polares.Source.n_crit(event.Value).Value, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Value(AeroSQL_explorer.dropdown_n_crit.Value));
	I_Mach = I_search(Polares.Source.n_crit(event.Value).Mach(I_n_crit).Value, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.dropdown_n_crit.Value).Value(AeroSQL_explorer.dropdown_Mach.Value));
	I_Reynolds = I_search(Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Value, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.dropdown_n_crit.Value).Reynolds(AeroSQL_explorer.dropdown_Mach.Value).Value(AeroSQL_explorer.dropdown_Reynolds.Value));
	
	AeroSQL_explorer.aux_Source = event.Value;
	AeroSQL_explorer.aux_n_crit = I_n_crit;
	AeroSQL_explorer.aux_Mach = I_Mach;
	AeroSQL_explorer.aux_Reynolds = I_Reynolds;
	
	AeroSQL_explorer.dropdown_n_crit.Items = string(Polares.Source.n_crit(event.Value).Value);
	AeroSQL_explorer.dropdown_n_crit.ItemsData = 1:length(Polares.Source.n_crit(event.Value).Value);
	AeroSQL_explorer.dropdown_n_crit.Value = I_n_crit;
	
	AeroSQL_explorer.dropdown_Mach.Items = string(Polares.Source.n_crit(event.Value).Mach(I_n_crit).Value);
	AeroSQL_explorer.dropdown_Mach.ItemsData = 1:length(Polares.Source.n_crit(event.Value).Mach(I_n_crit).Value);
	AeroSQL_explorer.dropdown_Mach.Value = I_Mach;
	
	AeroSQL_explorer.dropdown_Reynolds.Items = string(Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Value);
	AeroSQL_explorer.dropdown_Reynolds.ItemsData = 1:length(Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Value);
	AeroSQL_explorer.dropdown_Reynolds.Value = I_Reynolds;
	
	if AeroSQL_explorer.aux_Coeficiente == "Cl"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).Value.Alpha,Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).Value.Cl);
		if AeroSQL_explorer.dropdown_Source.Items(AeroSQL_explorer.aux_Source) == "Xfoil"
			alphas_lineares = linspace(-10,10,2);
			Cl_lineares = polyval([1 -Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl].*Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cl_alpha, alphas_lineares);
			hold(AeroSQL_explorer.axes_coeficientes,'on')
			plot(AeroSQL_explorer.axes_coeficientes,alphas_lineares, Cl_lineares,'--')
			hold(AeroSQL_explorer.axes_coeficientes,'off')
			legend(AeroSQL_explorer.axes_coeficientes,'curva original', 'aproximação linear','Location','southeast')
			text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl, 0, sprintf(" \\alpha_{0_Cl} = %.3f \\rightarrow ", Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl), 'HorizontalAlignment', 'right')
			text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_stall, Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cl_max, sprintf("\\leftarrow Cl_{max} = %.3f", Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cl_max))
			text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_stall, 0, sprintf("\\leftarrow \\alpha_{stall} = %.3f", Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_stall))
			text(AeroSQL_explorer.axes_coeficientes, 0.1, 0.75, sprintf(" dCl/d\\alpha = %.3f ", Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cl_alpha),'Units','normalized','FontSize',18)
			axis(AeroSQL_explorer.axes_coeficientes,[-25 30 -2 2.2]);
		end
	elseif AeroSQL_explorer.aux_Coeficiente == "Cd"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).Value.Alpha,Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).Value.Cd);
		axis(AeroSQL_explorer.axes_coeficientes,[-25 30 0 0.35])
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl, Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cd_min, sprintf("\\downarrow Cd_{min} = %.5f", Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cd_min),'verticalAlignment', 'bottom')
	elseif AeroSQL_explorer.aux_Coeficiente == "Cm"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).Value.Alpha,Polares.Source.n_crit(event.Value).Mach(I_n_crit).Reynolds(I_Mach).Polar(I_Reynolds).Value.Cm);
	end
	
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name(AeroSQL_explorer.aux_Perfil),'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
	
elseif dropdown.Tag == "n_crit"
	
	I_Mach = I_search(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Value, Polares.Source.n_crit(AeroSQL_explorer.dropdown_Source.Value).Mach(AeroSQL_explorer.aux_n_crit).Value(AeroSQL_explorer.dropdown_Mach.Value));
	I_Reynolds = I_search(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Value, Polares.Source.n_crit(AeroSQL_explorer.dropdown_Source.Value).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.dropdown_Mach.Value).Value(AeroSQL_explorer.dropdown_Reynolds.Value));
	
	AeroSQL_explorer.aux_n_crit = event.Value;
	
	AeroSQL_explorer.dropdown_Mach.Items = string(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Value);
	AeroSQL_explorer.dropdown_Mach.ItemsData = 1:length(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Value);
	AeroSQL_explorer.dropdown_Mach.Value = I_Mach;
	
	AeroSQL_explorer.dropdown_Reynolds.Items = string(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(1).Value);
	AeroSQL_explorer.dropdown_Reynolds.ItemsData = 1:length(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(1).Value);
	AeroSQL_explorer.dropdown_Reynolds.Value = I_Reynolds;
	
	if AeroSQL_explorer.aux_Coeficiente == "Cl"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).Value.Cl);
		alphas_lineares = linspace(-10,10,2);
		Cl_lineares = polyval([1 -Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl].*Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cl_alpha, alphas_lineares);
		hold(AeroSQL_explorer.axes_coeficientes,'on')
		plot(AeroSQL_explorer.axes_coeficientes,alphas_lineares, Cl_lineares,'--')
		hold(AeroSQL_explorer.axes_coeficientes,'off')
		legend(AeroSQL_explorer.axes_coeficientes,'curva original', 'aproximação linear','Location','southeast')
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl, 0, sprintf(" \\alpha_{0_Cl} = %.3f \\rightarrow ", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl), 'HorizontalAlignment', 'right')
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_stall, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cl_max, sprintf("\\leftarrow Cl_{max} = %.3f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cl_max))
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_stall, 0, sprintf("\\leftarrow \\alpha_{stall} = %.3f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_stall))
		text(AeroSQL_explorer.axes_coeficientes, 0.1, 0.75, sprintf(" dCl/d\\alpha = %.3f ", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cl_alpha),'Units','normalized','FontSize',18)
		axis(AeroSQL_explorer.axes_coeficientes,[-25 30 -2 2.2]);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cd"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).Value.Cd);
		axis(AeroSQL_explorer.axes_coeficientes,[-25 30 0 0.35])
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cd_min, sprintf("\\downarrow Cd_{min} = %.5f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).PolarProperties.Cd_min),'verticalAlignment', 'bottom')
	elseif AeroSQL_explorer.aux_Coeficiente == "Cm"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(event.Value).Reynolds(I_Mach).Polar(I_Reynolds).Value.Cm);
	end
	
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name(AeroSQL_explorer.aux_Perfil),'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
	
elseif dropdown.Tag == "Mach"
	
	I_Reynolds = I_search(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Value, Polares.Source.n_crit(AeroSQL_explorer.dropdown_Source.Value).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Value(AeroSQL_explorer.dropdown_Reynolds.Value));
	
	AeroSQL_explorer.aux_Mach = event.Value;
	
	AeroSQL_explorer.dropdown_Reynolds.Items = string(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Value);
	AeroSQL_explorer.dropdown_Reynolds.ItemsData = 1:length(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Value);
	AeroSQL_explorer.dropdown_Reynolds.Value = I_Reynolds;
	
	if AeroSQL_explorer.aux_Coeficiente == "Cl"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).Value.Cl);
		alphas_lineares = linspace(-10,10,2);
		Cl_lineares = polyval([1 -Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl].*Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Cl_alpha, alphas_lineares);
		hold(AeroSQL_explorer.axes_coeficientes,'on')
		plot(AeroSQL_explorer.axes_coeficientes,alphas_lineares, Cl_lineares,'--')
		hold(AeroSQL_explorer.axes_coeficientes,'off')
		legend(AeroSQL_explorer.axes_coeficientes,'curva original', 'aproximação linear','Location','southeast')
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl, 0, sprintf(" \\alpha_{0_Cl} = %.3f \\rightarrow ", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl), 'HorizontalAlignment', 'right')
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Alpha_stall, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Cl_max, sprintf("\\leftarrow Cl_{max} = %.3f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Cl_max))
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Alpha_stall, 0, sprintf("\\leftarrow \\alpha_{stall} = %.3f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Alpha_stall))
		text(AeroSQL_explorer.axes_coeficientes, 0.1, 0.75, sprintf(" dCl/d\\alpha = %.3f ", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Cl_alpha),'Units','normalized','FontSize',18)
		axis(AeroSQL_explorer.axes_coeficientes,[-25 30 -2 2.2]);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cd"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).Value.Cd);
		axis(AeroSQL_explorer.axes_coeficientes,[-25 30 0 0.35])
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Alpha_0_Cl, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Cd_min, sprintf("\\downarrow Cd_{min} = %.5f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).PolarProperties.Cd_min),'verticalAlignment', 'bottom')
	elseif AeroSQL_explorer.aux_Coeficiente == "Cm"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(event.Value).Polar(I_Reynolds).Value.Cm);
	end
	
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name(AeroSQL_explorer.aux_Perfil),'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
	
elseif dropdown.Tag == "Reynolds"
	
	AeroSQL_explorer.aux_Reynolds = event.Value;
	
	if AeroSQL_explorer.aux_Coeficiente == "Cl"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Cl);
		alphas_lineares = linspace(-10,10,2);
		Cl_lineares = polyval([1 -Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Alpha_0_Cl].*Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Cl_alpha, alphas_lineares);
		hold(AeroSQL_explorer.axes_coeficientes,'on')
		plot(AeroSQL_explorer.axes_coeficientes,alphas_lineares, Cl_lineares,'--')
		hold(AeroSQL_explorer.axes_coeficientes,'off')
		legend(AeroSQL_explorer.axes_coeficientes,'curva original', 'aproximação linear','Location','southeast')
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Alpha_0_Cl, 0, sprintf(" \\alpha_{0_Cl} = %.3f \\rightarrow ", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Alpha_0_Cl), 'HorizontalAlignment', 'right')
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Alpha_stall, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Cl_max, sprintf("\\leftarrow Cl_{max} = %.3f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Cl_max))
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Alpha_stall, 0, sprintf("\\leftarrow \\alpha_{stall} = %.3f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Alpha_stall))
		text(AeroSQL_explorer.axes_coeficientes, 0.1, 0.75, sprintf(" dCl/d\\alpha = %.3f ", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Cl_alpha),'Units','normalized','FontSize',18)
		axis(AeroSQL_explorer.axes_coeficientes,[-25 30 -2 2.2]);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cd"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Cd);
		axis(AeroSQL_explorer.axes_coeficientes,[-25 30 0 0.35])
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Alpha_0_Cl, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Cd_min, sprintf("\\downarrow Cd_{min} = %.5f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).PolarProperties.Cd_min),'verticalAlignment', 'bottom')
	elseif AeroSQL_explorer.aux_Coeficiente == "Cm"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(event.Value).Value.Cm);
	end
	
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name(AeroSQL_explorer.aux_Perfil),'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
	
elseif dropdown.Tag == "Coeficiente"
	
	AeroSQL_explorer.aux_Coeficiente = event.Value;
	
	if AeroSQL_explorer.aux_Coeficiente == "Cl"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Cl);
		alphas_lineares = linspace(-10,10,2);
		Cl_lineares = polyval([1 -Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Alpha_0_Cl].*Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Cl_alpha, alphas_lineares);
		hold(AeroSQL_explorer.axes_coeficientes,'on')
		plot(AeroSQL_explorer.axes_coeficientes,alphas_lineares, Cl_lineares,'--')
		hold(AeroSQL_explorer.axes_coeficientes,'off')
		legend(AeroSQL_explorer.axes_coeficientes,'curva original', 'aproximação linear','Location','southeast')
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Alpha_0_Cl, 0, sprintf(" \\alpha_{0_Cl} = %.3f \\rightarrow ", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Alpha_0_Cl), 'HorizontalAlignment', 'right')
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Alpha_stall, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Cl_max, sprintf("\\leftarrow Cl_{max} = %.3f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Cl_max))
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Alpha_stall, 0, sprintf("\\leftarrow \\alpha_{stall} = %.3f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Alpha_stall))
		text(AeroSQL_explorer.axes_coeficientes, 0.1, 0.75, sprintf(" dCl/d\\alpha = %.3f ", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Cl_alpha),'Units','normalized','FontSize',18)
		axis(AeroSQL_explorer.axes_coeficientes,[-25 30 -2 2.2]);
	elseif AeroSQL_explorer.aux_Coeficiente == "Cd"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Cd);
		axis(AeroSQL_explorer.axes_coeficientes,[-25 30 0 0.35])
		text(AeroSQL_explorer.axes_coeficientes, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Alpha_0_Cl, Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Cd_min, sprintf("\\downarrow Cd_{min} = %.5f", Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties.Cd_min),'verticalAlignment', 'bottom')
	elseif AeroSQL_explorer.aux_Coeficiente == "Cm"
		plot(AeroSQL_explorer.axes_coeficientes,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Alpha,Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value.Cm);
	end
	
	text(AeroSQL_explorer.axes_coeficientes,0.5,0.9,Airfoils.Name(AeroSQL_explorer.aux_Perfil),'Units','normalized','FontWeight','bold','FontSize',25,'HorizontalAlignment','Center')
	
elseif dropdown.Tag == "Fmt arquivo possiveis"
	
	if dropdown.Value == 2 || dropdown.Value == 3
		delimiter_dropdown.Enable = 'off';
	else
		delimiter_dropdown.Enable = 'on';
	end
	
	if dropdown.Value == 3
		inc_polar_properties_chkbox.Enable = 'on';
	else
		inc_polar_properties_chkbox.Enable = 'off';
	end
	
end

end

function Seleciona_Menu(menu)

global AeroSQL_explorer Airfoils dir_exp form_exp delimiter inc_side geometria_perfil form_aquivo_dlg_box delimiter_dropdown Polares inc_polar_properties_chkbox inc_pol_prop

if menu.Text == "&Diretório de Exportação"
	
	dir_exp = uigetdir(cd,"Selecione um diretório para salvar os dados");
	
elseif menu.Text == "&Formato dos arquivos"
	
	opc_possiveis = ["csv","xls","mat","dat"];
	delimiters_possiveis = [",",";","tab"];
	
	form_aquivo_dlg_box = uifigure('Name',"Informe o formato do arquivo de exportação desejado");
	form_aquivo_dlg_box.Position = [600 550 350 180];
	
	fmt_dropdown = uidropdown(form_aquivo_dlg_box,'Items',opc_possiveis,'ItemsData',1:length(opc_possiveis));
	fmt_dropdown.Position = [form_aquivo_dlg_box.Position(3)/2-120 130 100 25];
	fmt_dropdown.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);
	fmt_dropdown.Tag = "Fmt arquivo possiveis";
	
	delimiter_dropdown = uidropdown(form_aquivo_dlg_box,'Items',delimiters_possiveis,'ItemsData',1:length(delimiters_possiveis));
	delimiter_dropdown.Position = [fmt_dropdown.Position(1)+145 130 100 25];
	delimiter_dropdown.ValueChangedFcn = @(dropdown,event) Seleciona_dropdown(dropdown,event);
	delimiter_dropdown.Tag = "Delimiter possiveis";
	
	inc_side_chkbox = uicheckbox(form_aquivo_dlg_box,'Text',"Incluir coluna 'Side' no arquivo de geometria");
	inc_side_chkbox.Position = [form_aquivo_dlg_box.Position(3)/2-130 delimiter_dropdown.Position(2)-35 300 25];
	inc_side_chkbox.ValueChangedFcn = @(chkbox,event) Muda_checkbox(chkbox,event);
	
	inc_polar_properties_chkbox = uicheckbox(form_aquivo_dlg_box,'Text',"Incluir propriedades da polar no .mat");
	inc_polar_properties_chkbox.Position = [form_aquivo_dlg_box.Position(3)/2-130 inc_side_chkbox.Position(2)-35 300 25];
	inc_polar_properties_chkbox.ValueChangedFcn = @(chkbox,event) Muda_checkbox(chkbox,event);
	inc_polar_properties_chkbox.Enable = 'off';

	salvar = uibutton(form_aquivo_dlg_box,'Text','Salvar','Tag',"Salvar Fmt arquivo",'ButtonPushedFcn',@(btn,event) Aperta_Botao(btn, opc_possiveis(fmt_dropdown.Value), delimiters_possiveis( delimiter_dropdown.Value )));
	salvar.Position = [form_aquivo_dlg_box.Position(3)/2-125 20 110 25];
	
	cancelar = uibutton(form_aquivo_dlg_box,'Text','Cancelar','Tag',"Cancelar Fmt arquivo",'ButtonPushedFcn',@(btn,event) Aperta_Botao(btn));
	cancelar.Position = [salvar.Position(1)+145 salvar.Position(2) 110 25];
	

elseif menu.Text == "&Geometria"
	
	if form_exp == "csv" || form_exp == "dat"
		if inc_side == 1
			writetable(geometria_perfil,[dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'.',char(form_exp)],'Delimiter',char(delimiter))
		else
			writetable(geometria_perfil(:,1:2),[dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'.',char(form_exp)],'Delimiter',char(delimiter))
		end
	elseif form_exp == "xls"
		writetable(geometria_perfil,[dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'.',char(form_exp)])
	elseif form_exp == "mat"
		eval([Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'_geo',' = geometria_perfil;'])
		writetable(geometria_perfil,[dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'.',char(form_exp)])
	end
	
elseif menu.Text == "Polar Atual"
	
	Source = num2str(Polares.Source.Value(AeroSQL_explorer.aux_Source));
	n_crit = num2str(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Value(AeroSQL_explorer.aux_n_crit));
	Mach = num2str(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Value(AeroSQL_explorer.aux_Mach));
	Reynolds = num2str(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Value(AeroSQL_explorer.aux_Reynolds));
	
	if form_exp == "csv" || form_exp == "dat"
		writetable(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value(:,3:end),[dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'_',Source,'_',n_crit,'_',Mach,'_',Reynolds,'.',char(form_exp)],'Delimiter',char(delimiter));
	elseif form_exp == "xls"
		writetable(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value(:,3:end),[dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'_',Source,'_',n_crit,'_',Mach,'_',Reynolds,'.',char(form_exp)]);
	elseif form_exp == "mat"
		Polar = Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value(:,3:end);
		eval([Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'_',Source,'_',n_crit,'_',Mach,'_',Reynolds,'.Polar',' = Polar;'])
		if inc_pol_prop == true
			Polar_Properties = Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).PolarProperties(1,3:12);
			eval([Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'_',Source,'_',n_crit,'_',Mach,'_',Reynolds,'.PolarProperties',' = Polar_Properties;']);
		end
		save([dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'_',Source,'_',n_crit,'_',Mach,'_',Reynolds,'.',char(form_exp)],[Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'_',Source,'_',n_crit,'_',Mach,'_',Reynolds])
	end
		
elseif menu.Text == "Todas as Polares do Perfil Atual"

	if form_exp == "csv" || form_exp == "dat"
		mkdir([dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value}])
		for i_Source = 1:length(Polares.Source.Value)
			Source = num2str(Polares.Source.Value(i_Source));
			for i_n_crit = 1:length(Polares.Source.n_crit(i_Source).Value)
				n_crit = num2str(Polares.Source.n_crit(i_Source).Value(i_n_crit));
				for i_Mach = 1:length(Polares.Source.n_crit(i_Source).Mach(i_n_crit).Value)
					Mach = num2str(Polares.Source.n_crit(i_Source).Mach(i_n_crit).Value(i_Mach));
					for i_Re = 1:length(Polares.Source.n_crit(i_Source).Mach(i_n_crit).Reynolds(i_Mach).Value)
						Reynolds = num2str(Polares.Source.n_crit(i_Source).Mach(i_n_crit).Reynolds(i_Mach).Value(i_Re));
						writetable(Polares.Source.n_crit(i_Source).Mach(i_n_crit).Reynolds(i_Mach).Polar(i_Re).Value(:,3:end),[dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'_',Source,'_',n_crit,'_',Mach,'_',Reynolds,'.',char(form_exp)],'Delimiter',char(delimiter));
					end
				end
			end
		end
	elseif form_exp == "xls"
		mkdir([dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value}])
		for i_Source = 1:length(Polares.Source.Value)
			Source = num2str(Polares.Source.Value(i_Source));
			for i_n_crit = 1:length(Polares.Source.n_crit(i_Source).Value)
				n_crit = num2str(Polares.Source.n_crit(i_Source).Value(i_n_crit));
				for i_Mach = 1:length(Polares.Source.n_crit(i_Source).Mach(i_n_crit).Value)
					Mach = num2str(Polares.Source.n_crit(i_Source).Mach(i_n_crit).Value(i_Mach));
					for i_Re = 1:length(Polares.Source.n_crit(i_Source).Mach(i_n_crit).Reynolds(i_Mach).Value)
						Reynolds = num2str(Polares.Source.n_crit(i_Source).Mach(i_n_crit).Reynolds(i_Mach).Value(i_Re));
						writetable(Polares.Source.n_crit(AeroSQL_explorer.aux_Source).Mach(AeroSQL_explorer.aux_n_crit).Reynolds(AeroSQL_explorer.aux_Mach).Polar(AeroSQL_explorer.aux_Reynolds).Value(:,3:end),[dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'_',Source,'_',n_crit,'_',Mach,'_',Reynolds,'.',char(form_exp)]);
					end
				end
			end
		end		
	elseif form_exp == "mat"
		eval([Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},' = Polares;'])
		save([dir_exp,'\',Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value},'.',char(form_exp)],[Airfoils.File_name{AeroSQL_explorer.Perfis_listbox.Value}])
	end
	
end

end

function Aperta_Botao(btn,varargin)

global form_exp delimiter form_aquivo_dlg_box

if btn.Tag == "Salvar Fmt arquivo"
	
	form_exp = varargin{1};
	delimiter = varargin{2};
	close(form_aquivo_dlg_box)
	
elseif btn.Tag == "Cancelar Fmt arquivo"
	
	close(form_aquivo_dlg_box)
	
end

end

function Muda_checkbox(chkbox,event)

global inc_side inc_pol_prop

if chkbox.Text == "Incluir coluna 'Side' no arquivo de geometria"
	
	inc_side = event.Value;

elseif chkbox.Text == "Incluir propriedades da polar no .mat"
	
	inc_pol_prop = event.Value;
	
end

end

function [Polares,I_alpha_glued_polar] = Estrutura_Polares(conn,AirfoilID)

Runs = fetch(conn,sprintf("SELECT * FROM Runs WHERE AirfoilID = %u",AirfoilID));
Raw_Polares = fetch(conn,sprintf("SELECT * FROM Polars WHERE AirfoilID = %u",AirfoilID));
Raw_PolarProperties = fetch(conn,sprintf("SELECT * FROM polarproperties WHERE AirfoilID = %u",AirfoilID));

if isempty(Raw_Polares)
	
	error('Não foi encontrada nenhuma polar para este aerofólio')
	
end

u_Source = unique(Runs.Source);
u_Source = flip(u_Source);

for i_Source = 1:length(u_Source)
	Polares.Source.Value(i_Source) = string(u_Source{i_Source});
	Runs_Source = Runs(ismember(Runs.Source,u_Source{i_Source}),:);
	u_n_crit = unique(Runs_Source.Ncrit);
	
	for i_Ncrit = 1:length(u_n_crit)
		Polares.Source.n_crit(i_Source).Value(i_Ncrit) = u_n_crit(i_Ncrit);
		Runs_Ncrit = Runs_Source(ismember(Runs_Source.Ncrit,u_n_crit(i_Ncrit)),:);
		u_Mach = unique(Runs_Ncrit.Mach);
		
		for i_Mach = 1:length(u_Mach)
			Polares.Source.n_crit(i_Source).Mach(i_Ncrit).Value(i_Mach) = u_Mach(i_Mach);
			Runs_Mach = Runs_Ncrit(ismember(Runs_Ncrit.Mach,u_Mach(i_Mach)),:);
			[u_Reynolds,ia_u_Reynolds] = unique(Runs_Mach.Reynolds);
			
			for i_Re = 1:length(u_Reynolds)
				Polares.Source.n_crit(i_Source).Mach(i_Ncrit).Reynolds(i_Mach).Value(i_Re) = u_Reynolds(i_Re);
				
				Polares.Source.n_crit(i_Source).Mach(i_Ncrit).Reynolds(i_Mach).Polar(i_Re).Value = Raw_Polares(ismember(Raw_Polares.RunID,Runs_Mach.RunID(ia_u_Reynolds(i_Re))),:);
					
				Polares.Source.n_crit(i_Source).Mach(i_Ncrit).Reynolds(i_Mach).Polar(i_Re).PolarProperties = Raw_PolarProperties(ismember(Raw_PolarProperties.RunID,Runs_Mach.RunID(ia_u_Reynolds(i_Re))),:);
				
				if Polares.Source.Value(i_Source) == "Bjorn Montgomerie Extapolation Method"
					
					aux = Runs_Mach.AdditionalData(i_Re);
					aux = textscan(aux{1},'%s %s %s','Delimiter',';');
					aux = str2double(aux{1}{1}(23:end));
					if isnumeric(aux)
						I_alpha_glued_polar.Mach(i_Mach).Reynolds(i_Re) = aux;
					else
						I_alpha_glued_polar.Mach(i_Mach).Reynolds(i_Re) = [];
					end
					
				end
				Polares.Source.n_crit(i_Source).Mach(i_Ncrit).Reynolds(i_Mach).Polar(i_Re).Extendida = false;
			end
			
		end
		
	end
	
end

end

function I = I_search(Vetor, Valor)

[~,I] = min(abs(Vetor - Valor));

end

