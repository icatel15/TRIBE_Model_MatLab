classdef TribeFrontEnd < handle
    %TRIBEFRONTEND Interactive front end for the TRIBE thermal recovery model.
    % Provides a graphical interface for configuration editing, model execution,
    % output visualization, and sensitivity analysis.
    %
    % Usage:
    %   app = TribeFrontEnd();    % Launch the application
    %   delete(app);              % Close the application

    properties (Access = public)
        UIFigure            matlab.ui.Figure
    end

    properties (Access = private)
        % Helper classes
        ConfigEditor        tribe.ui.ConfigEditor
        ModelRunner         tribe.ui.ModelRunner
        SensitivityRunner   tribe.ui.SensitivityRunner
        OptimizationRunner  tribe.ui.OptimizationRunner

        % Layout containers
        MainGrid            matlab.ui.container.GridLayout
        LeftPanel           matlab.ui.container.Panel
        RightPanel          matlab.ui.container.Panel

        % Left panel components - Mode selection
        ModeButtonGroup     matlab.ui.container.ButtonGroup
        GuidedButton        matlab.ui.control.RadioButton
        AdvancedButton      matlab.ui.control.RadioButton

        % Left panel components - Guided mode
        GuidedPanel         matlab.ui.container.Panel
        ChipsetDropdown     matlab.ui.control.DropDown
        CoolingDropdown     matlab.ui.control.DropDown
        ProcessDropdown     matlab.ui.control.DropDown
        ITCapacitySpinner   matlab.ui.control.Spinner
        ComputeRateSpinner  matlab.ui.control.Spinner
        ElectricitySpinner  matlab.ui.control.Spinner
        HeatPumpCheckbox    matlab.ui.control.CheckBox
        HPTempSpinner       matlab.ui.control.Spinner

        % Left panel components - Advanced mode
        AdvancedPanel       matlab.ui.container.Panel
        ConfigTree          matlab.ui.container.Tree
        ConfigTreeNodes     struct

        % Left panel components - Run controls
        RunPanel            matlab.ui.container.Panel
        RunButton           matlab.ui.control.Button
        StatusLabel         matlab.ui.control.Label
        ResetButton         matlab.ui.control.Button
        LoadButton          matlab.ui.control.Button
        SaveButton          matlab.ui.control.Button

        % Right panel - Tab group
        OutputTabGroup      matlab.ui.container.TabGroup
        DashboardTab        matlab.ui.container.Tab
        DetailsTab          matlab.ui.container.Tab
        SensitivityTab      matlab.ui.container.Tab
        ScenariosTab        matlab.ui.container.Tab

        % Dashboard components
        KPIGrid             matlab.ui.container.GridLayout
        KPITiles            struct
        ChartGrid           matlab.ui.container.GridLayout
        CapexAxes           matlab.ui.control.UIAxes
        OpexAxes            matlab.ui.control.UIAxes
        RevenueAxes         matlab.ui.control.UIAxes
        PaybackAxes         matlab.ui.control.UIAxes

        % Details tab components
        DetailsSectionDropdown  matlab.ui.control.DropDown
        DetailsTable        matlab.ui.control.Table

        % Sensitivity tab components
        SensitivityTypeDropdown     matlab.ui.control.DropDown
        SensitivityParam1Dropdown   matlab.ui.control.DropDown
        SensitivityParam2Dropdown   matlab.ui.control.DropDown
        SensitivityMetricDropdown   matlab.ui.control.DropDown
        SensitivityStartSpinner     matlab.ui.control.Spinner
        SensitivityEndSpinner       matlab.ui.control.Spinner
        SensitivityStepsSpinner     matlab.ui.control.Spinner
        RunSensitivityButton        matlab.ui.control.Button
        SensitivityAxes             matlab.ui.control.UIAxes
        SensitivityParam2Label      matlab.ui.control.Label
        SensitivityParam2Panel      matlab.ui.container.Panel

        % Optimization tab components
        OptimizationTab             matlab.ui.container.Tab
        OptObjectiveDropdown        matlab.ui.control.DropDown
        OptYearsSpinner             matlab.ui.control.Spinner
        OptTopNSpinner              matlab.ui.control.Spinner
        RunOptButton                matlab.ui.control.Button
        CancelOptButton             matlab.ui.control.Button
        OptStageLabel               matlab.ui.control.Label
        OptProgressLabel            matlab.ui.control.Label
        OptStatusLabel              matlab.ui.control.Label
        Stage1Table                 matlab.ui.control.Table
        Stage2Table                 matlab.ui.control.Table
        LoadOptConfigButton         matlab.ui.control.Button
        ExportOptResultsButton      matlab.ui.control.Button

        % Scenarios tab components
        ScenarioListBox     matlab.ui.control.ListBox
        AddScenarioButton   matlab.ui.control.Button
        LoadScenarioButton  matlab.ui.control.Button
        DeleteScenarioButton matlab.ui.control.Button
        CompareButton       matlab.ui.control.Button
        ScenarioNameField   matlab.ui.control.EditField

        % Data storage
        ScenarioLibrary     struct
        LastResults         struct
    end

    methods (Access = public)
        function app = TribeFrontEnd()
            %TRIBEFRONTEND Constructor - creates and shows the app.
            app.ScenarioLibrary = struct('name', {}, 'config', {}, 'results', {}, 'timestamp', {});
            app.LastResults = [];

            createComponents(app);
            registerCallbacks(app);
            initializeApp(app);

            if nargout == 0
                clear app
            end
        end

        function delete(app)
            %DELETE Destructor - clean up the app.
            delete(app.UIFigure);
        end
    end

    methods (Access = private)
        function createComponents(app)
            %CREATECOMPONENTS Create all UI components.

            % Create main figure
            app.UIFigure = uifigure('Visible', 'off');
            screenSize = get(0, 'ScreenSize');
            figWidth = min(1400, screenSize(3) - 100);
            figHeight = min(900, screenSize(4) - 120);
            app.UIFigure.Position = [screenSize(1) + 50, screenSize(2) + 50, figWidth, figHeight];
            app.UIFigure.Name = 'TRIBE Model Front End';
            app.UIFigure.Resize = 'on';
            app.UIFigure.AutoResizeChildren = 'off';

            % Main grid layout (2 columns)
            app.MainGrid = uigridlayout(app.UIFigure, [1 2]);
            app.MainGrid.ColumnWidth = {350, '1x'};
            app.MainGrid.Padding = [10 10 10 10];
            app.MainGrid.ColumnSpacing = 10;

            % Create panels
            createLeftPanel(app);
            createRightPanel(app);

            % Make visible
            app.UIFigure.SizeChangedFcn = @(src, event) resizeLayout(app);
            resizeLayout(app);

            app.UIFigure.Visible = 'on';
        end

        function resizeLayout(app)
            %RESIZELAYOUT Adjust layout for current figure size.
            figWidth = app.UIFigure.Position(3);
            leftWidth = max(280, min(420, figWidth * 0.28));
            app.MainGrid.ColumnWidth = {leftWidth, '1x'};

            bgWidth = app.ModeButtonGroup.Position(3);
            bgHeight = app.ModeButtonGroup.Position(4);
            padding = 10;
            gap = 10;
            buttonHeight = 22;
            usableWidth = max(0, bgWidth - (2 * padding + gap));
            buttonWidth = max(1, floor(usableWidth / 2));
            yPos = max(4, floor((bgHeight - buttonHeight) / 2));

            app.GuidedButton.Position = [padding, yPos, buttonWidth, buttonHeight];
            app.AdvancedButton.Position = [padding + buttonWidth + gap, yPos, buttonWidth, buttonHeight];
        end

        function createLeftPanel(app)
            %CREATELEFTPANEL Create the left configuration panel.

            app.LeftPanel = uipanel(app.MainGrid);
            app.LeftPanel.Title = 'Configuration';
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            leftGrid = uigridlayout(app.LeftPanel, [4 1]);
            leftGrid.RowHeight = {'fit', '1x', '1x', 'fit'};
            leftGrid.Padding = [10 10 10 10];
            leftGrid.RowSpacing = 10;

            % Mode selection
            app.ModeButtonGroup = uibuttongroup(leftGrid);
            app.ModeButtonGroup.Title = '';
            app.ModeButtonGroup.Layout.Row = 1;
            app.ModeButtonGroup.Layout.Column = 1;

            app.GuidedButton = uiradiobutton(app.ModeButtonGroup);
            app.GuidedButton.Text = 'Guided Mode';
            app.GuidedButton.Value = true;
            app.GuidedButton.Position = [10 8 140 22];

            app.AdvancedButton = uiradiobutton(app.ModeButtonGroup);
            app.AdvancedButton.Text = 'Advanced Mode';
            app.AdvancedButton.Position = [170 8 150 22];

            % Guided panel
            createGuidedPanel(app, leftGrid);

            % Advanced panel
            createAdvancedPanel(app, leftGrid);

            % Run panel
            createRunPanel(app, leftGrid);

            % Initially show guided, hide advanced
            app.AdvancedPanel.Visible = 'off';
        end

        function createGuidedPanel(app, parent)
            %CREATEGUIDEDPANEL Create the guided mode configuration panel.

            app.GuidedPanel = uipanel(parent);
            app.GuidedPanel.Title = 'Quick Setup';
            app.GuidedPanel.Layout.Row = 2;
            app.GuidedPanel.Layout.Column = 1;

            grid = uigridlayout(app.GuidedPanel, [9 2]);
            grid.RowHeight = repmat({'fit'}, 1, 9);
            grid.ColumnWidth = {'1x', '1x'};
            grid.Padding = [10 10 10 10];
            grid.RowSpacing = 8;

            % Chipset
            lbl = uilabel(grid); lbl.Text = 'Chipset:';
            lbl.Layout.Row = 1; lbl.Layout.Column = 1;
            app.ChipsetDropdown = uidropdown(grid);
            app.ChipsetDropdown.Layout.Row = 1;
            app.ChipsetDropdown.Layout.Column = 2;

            % Cooling method
            lbl = uilabel(grid); lbl.Text = 'Cooling Method:';
            lbl.Layout.Row = 2; lbl.Layout.Column = 1;
            app.CoolingDropdown = uidropdown(grid);
            app.CoolingDropdown.Layout.Row = 2;
            app.CoolingDropdown.Layout.Column = 2;

            % Process
            lbl = uilabel(grid); lbl.Text = 'Industrial Process:';
            lbl.Layout.Row = 3; lbl.Layout.Column = 1;
            app.ProcessDropdown = uidropdown(grid);
            app.ProcessDropdown.Layout.Row = 3;
            app.ProcessDropdown.Layout.Column = 2;

            % IT Capacity
            lbl = uilabel(grid); lbl.Text = 'IT Capacity (kW):';
            lbl.Layout.Row = 4; lbl.Layout.Column = 1;
            app.ITCapacitySpinner = uispinner(grid);
            app.ITCapacitySpinner.Limits = [50 1000];
            app.ITCapacitySpinner.Step = 25;
            app.ITCapacitySpinner.Layout.Row = 4;
            app.ITCapacitySpinner.Layout.Column = 2;

            % Compute rate
            lbl = uilabel(grid); lbl.Text = 'Compute Rate (GBP/kW/mo):';
            lbl.Layout.Row = 5; lbl.Layout.Column = 1;
            app.ComputeRateSpinner = uispinner(grid);
            app.ComputeRateSpinner.Limits = [50 500];
            app.ComputeRateSpinner.Step = 10;
            app.ComputeRateSpinner.Layout.Row = 5;
            app.ComputeRateSpinner.Layout.Column = 2;

            % Electricity price
            lbl = uilabel(grid); lbl.Text = 'Electricity (GBP/kWh):';
            lbl.Layout.Row = 6; lbl.Layout.Column = 1;
            app.ElectricitySpinner = uispinner(grid);
            app.ElectricitySpinner.Limits = [0.05 0.50];
            app.ElectricitySpinner.Step = 0.01;
            app.ElectricitySpinner.ValueDisplayFormat = '%.2f';
            app.ElectricitySpinner.Layout.Row = 6;
            app.ElectricitySpinner.Layout.Column = 2;

            % Heat pump checkbox
            app.HeatPumpCheckbox = uicheckbox(grid);
            app.HeatPumpCheckbox.Text = 'Enable Heat Pump';
            app.HeatPumpCheckbox.Layout.Row = 7;
            app.HeatPumpCheckbox.Layout.Column = [1 2];

            % HP output temperature
            lbl = uilabel(grid); lbl.Text = 'HP Output Temp (C):';
            lbl.Layout.Row = 8; lbl.Layout.Column = 1;
            app.HPTempSpinner = uispinner(grid);
            app.HPTempSpinner.Limits = [60 120];
            app.HPTempSpinner.Step = 5;
            app.HPTempSpinner.Layout.Row = 8;
            app.HPTempSpinner.Layout.Column = 2;
        end

        function createAdvancedPanel(app, parent)
            %CREATEADVANCEDPANEL Create the advanced mode configuration panel.

            app.AdvancedPanel = uipanel(parent);
            app.AdvancedPanel.Title = 'All Parameters';
            app.AdvancedPanel.Layout.Row = 3;
            app.AdvancedPanel.Layout.Column = 1;

            grid = uigridlayout(app.AdvancedPanel, [1 1]);
            grid.Padding = [5 5 5 5];

            app.ConfigTree = uitree(grid);
            app.ConfigTree.Layout.Row = 1;
            app.ConfigTree.Layout.Column = 1;
        end

        function createRunPanel(app, parent)
            %CREATERUNPANEL Create the run controls panel.

            app.RunPanel = uipanel(parent);
            app.RunPanel.Title = 'Actions';
            app.RunPanel.Layout.Row = 4;
            app.RunPanel.Layout.Column = 1;

            grid = uigridlayout(app.RunPanel, [3 3]);
            grid.RowHeight = {'fit', 'fit', 'fit'};
            grid.ColumnWidth = {'1x', '1x', '1x'};
            grid.Padding = [10 10 10 10];
            grid.RowSpacing = 8;

            % Run button (spans all columns)
            app.RunButton = uibutton(grid, 'push');
            app.RunButton.Text = 'RUN MODEL';
            app.RunButton.FontWeight = 'bold';
            app.RunButton.FontSize = 14;
            app.RunButton.BackgroundColor = [0.2 0.6 0.4];
            app.RunButton.FontColor = [1 1 1];
            app.RunButton.Layout.Row = 1;
            app.RunButton.Layout.Column = [1 3];

            % Status label
            app.StatusLabel = uilabel(grid);
            app.StatusLabel.Text = 'Status: Ready';
            app.StatusLabel.HorizontalAlignment = 'center';
            app.StatusLabel.Layout.Row = 2;
            app.StatusLabel.Layout.Column = [1 3];

            % Action buttons
            app.ResetButton = uibutton(grid, 'push');
            app.ResetButton.Text = 'Reset';
            app.ResetButton.Layout.Row = 3;
            app.ResetButton.Layout.Column = 1;

            app.LoadButton = uibutton(grid, 'push');
            app.LoadButton.Text = 'Load';
            app.LoadButton.Layout.Row = 3;
            app.LoadButton.Layout.Column = 2;

            app.SaveButton = uibutton(grid, 'push');
            app.SaveButton.Text = 'Save';
            app.SaveButton.Layout.Row = 3;
            app.SaveButton.Layout.Column = 3;
        end

        function createRightPanel(app)
            %CREATERIGHTPANEL Create the right output panel with tabs.

            app.RightPanel = uipanel(app.MainGrid);
            app.RightPanel.Title = 'Results';
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            rightGrid = uigridlayout(app.RightPanel, [1 1]);
            rightGrid.Padding = [5 5 5 5];

            app.OutputTabGroup = uitabgroup(rightGrid);
            app.OutputTabGroup.Layout.Row = 1;
            app.OutputTabGroup.Layout.Column = 1;

            % Create tabs
            createDashboardTab(app);
            createDetailsTab(app);
            createSensitivityTab(app);
            createOptimizationTab(app);
            createScenariosTab(app);
        end

        function createDashboardTab(app)
            %CREATEDASHBOARDTAB Create the dashboard tab with KPIs and charts.

            app.DashboardTab = uitab(app.OutputTabGroup);
            app.DashboardTab.Title = 'Dashboard';

            dashGrid = uigridlayout(app.DashboardTab, [2 1]);
            dashGrid.RowHeight = {'fit', '1x'};
            dashGrid.Padding = [10 10 10 10];
            dashGrid.RowSpacing = 15;

            % KPI tiles grid
            app.KPIGrid = uigridlayout(dashGrid, [1 6]);
            app.KPIGrid.Layout.Row = 1;
            app.KPIGrid.Layout.Column = 1;
            app.KPIGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.KPIGrid.Padding = [0 0 0 0];
            app.KPIGrid.ColumnSpacing = 10;

            % Create KPI tiles
            app.KPITiles = struct();
            kpiNames = {'payback', 'roi', 'margin', 'capex', 'profit', 'modules'};
            kpiLabels = {'Simple Payback', 'Unlevered ROI', 'Gross Margin', 'Total Capex', 'Gross Profit', 'Modules'};

            for i = 1:6
                tile = uipanel(app.KPIGrid);
                tile.Layout.Row = 1;
                tile.Layout.Column = i;
                tile.BackgroundColor = [0.95 0.95 0.97];

                tileGrid = uigridlayout(tile, [2 1]);
                tileGrid.RowHeight = {'1x', 25};
                tileGrid.Padding = [8 8 8 8];

                valueLabel = uilabel(tileGrid);
                valueLabel.Text = '-';
                valueLabel.FontSize = 20;
                valueLabel.FontWeight = 'bold';
                valueLabel.HorizontalAlignment = 'center';
                valueLabel.Layout.Row = 1;

                nameLabel = uilabel(tileGrid);
                nameLabel.Text = kpiLabels{i};
                nameLabel.FontSize = 10;
                nameLabel.HorizontalAlignment = 'center';
                nameLabel.FontColor = [0.5 0.5 0.55];
                nameLabel.Layout.Row = 2;

                app.KPITiles.(kpiNames{i}) = struct('panel', tile, 'value', valueLabel, 'name', nameLabel);
            end

            % Charts grid
            app.ChartGrid = uigridlayout(dashGrid, [2 2]);
            app.ChartGrid.Layout.Row = 2;
            app.ChartGrid.Layout.Column = 1;
            app.ChartGrid.RowHeight = {'1x', '1x'};
            app.ChartGrid.ColumnWidth = {'1x', '1x'};
            app.ChartGrid.Padding = [0 0 0 0];
            app.ChartGrid.RowSpacing = 10;
            app.ChartGrid.ColumnSpacing = 10;

            % Capex breakdown chart
            app.CapexAxes = uiaxes(app.ChartGrid);
            app.CapexAxes.Layout.Row = 1;
            app.CapexAxes.Layout.Column = 1;
            title(app.CapexAxes, 'Capex Breakdown');

            % Opex breakdown chart
            app.OpexAxes = uiaxes(app.ChartGrid);
            app.OpexAxes.Layout.Row = 1;
            app.OpexAxes.Layout.Column = 2;
            title(app.OpexAxes, 'Opex Breakdown');

            % Revenue streams chart
            app.RevenueAxes = uiaxes(app.ChartGrid);
            app.RevenueAxes.Layout.Row = 2;
            app.RevenueAxes.Layout.Column = 1;
            title(app.RevenueAxes, 'Revenue Streams');

            % Payback curve
            app.PaybackAxes = uiaxes(app.ChartGrid);
            app.PaybackAxes.Layout.Row = 2;
            app.PaybackAxes.Layout.Column = 2;
            title(app.PaybackAxes, 'Payback Curve');
        end

        function createDetailsTab(app)
            %CREATEDETAILSTAB Create the details tab with data table.

            app.DetailsTab = uitab(app.OutputTabGroup);
            app.DetailsTab.Title = 'Details';

            detailsGrid = uigridlayout(app.DetailsTab, [2 1]);
            detailsGrid.RowHeight = {'fit', '1x'};
            detailsGrid.Padding = [10 10 10 10];
            detailsGrid.RowSpacing = 10;

            % Section selector
            selectorPanel = uigridlayout(detailsGrid, [1 2]);
            selectorPanel.Layout.Row = 1;
            selectorPanel.ColumnWidth = {'fit', '1x'};
            selectorPanel.Padding = [0 0 0 0];

            lbl = uilabel(selectorPanel);
            lbl.Text = 'Section:';
            lbl.Layout.Column = 1;

            app.DetailsSectionDropdown = uidropdown(selectorPanel);
            app.DetailsSectionDropdown.Items = {'System P&L', 'System Flow', 'Buyer Profile', ...
                'System Capex', 'System Opex', 'Module Criteria', 'Module Capex', 'Module Opex', ...
                'Module Flow', 'Rack Profile'};
            app.DetailsSectionDropdown.ItemsData = {'spl', 'sflow', 'bp', 'scapex', 'sopex', ...
                'mc', 'mcapex', 'mopex', 'mflow', 'rp'};
            app.DetailsSectionDropdown.Value = 'spl';
            app.DetailsSectionDropdown.Layout.Column = 2;

            % Data table
            app.DetailsTable = uitable(detailsGrid);
            app.DetailsTable.Layout.Row = 2;
            app.DetailsTable.ColumnName = {'Field', 'Value', 'Type'};
            app.DetailsTable.ColumnWidth = {'auto', 'auto', 'auto'};
        end

        function createSensitivityTab(app)
            %CREATESENSITIVITYTAB Create the sensitivity analysis tab.

            app.SensitivityTab = uitab(app.OutputTabGroup);
            app.SensitivityTab.Title = 'Sensitivity';

            sensGrid = uigridlayout(app.SensitivityTab, [2 1]);
            sensGrid.RowHeight = {'fit', '1x'};
            sensGrid.Padding = [10 10 10 10];
            sensGrid.RowSpacing = 10;

            % Controls panel
            controlPanel = uipanel(sensGrid);
            controlPanel.Title = 'Analysis Settings';
            controlPanel.Layout.Row = 1;

            controlGrid = uigridlayout(controlPanel, [4 4]);
            controlGrid.RowHeight = repmat({'fit'}, 1, 4);
            controlGrid.ColumnWidth = {'fit', '1x', 'fit', '1x'};
            controlGrid.Padding = [10 10 10 10];
            controlGrid.RowSpacing = 8;

            % Analysis type
            lbl = uilabel(controlGrid); lbl.Text = 'Analysis Type:';
            lbl.Layout.Row = 1; lbl.Layout.Column = 1;
            app.SensitivityTypeDropdown = uidropdown(controlGrid);
            app.SensitivityTypeDropdown.Items = {'Tornado Chart', '1D Sweep', '2D Heatmap'};
            app.SensitivityTypeDropdown.ItemsData = {'tornado', 'sweep1d', 'sweep2d'};
            app.SensitivityTypeDropdown.Value = 'tornado';
            app.SensitivityTypeDropdown.Layout.Row = 1;
            app.SensitivityTypeDropdown.Layout.Column = 2;

            % Metric
            lbl = uilabel(controlGrid); lbl.Text = 'Output Metric:';
            lbl.Layout.Row = 1; lbl.Layout.Column = 3;
            app.SensitivityMetricDropdown = uidropdown(controlGrid);
            app.SensitivityMetricDropdown.Items = {'Simple Payback', 'Unlevered ROI', 'Gross Margin'};
            app.SensitivityMetricDropdown.ItemsData = {'simple_payback_years', 'unlevered_roi_pct', 'gross_margin_pct'};
            app.SensitivityMetricDropdown.Value = 'simple_payback_years';
            app.SensitivityMetricDropdown.Layout.Row = 1;
            app.SensitivityMetricDropdown.Layout.Column = 4;

            % Parameter 1
            lbl = uilabel(controlGrid); lbl.Text = 'Parameter 1:';
            lbl.Layout.Row = 2; lbl.Layout.Column = 1;
            app.SensitivityParam1Dropdown = uidropdown(controlGrid);
            app.SensitivityParam1Dropdown.Layout.Row = 2;
            app.SensitivityParam1Dropdown.Layout.Column = 2;

            % Parameter 2 (for 2D sweep)
            app.SensitivityParam2Label = uilabel(controlGrid);
            app.SensitivityParam2Label.Text = 'Parameter 2:';
            app.SensitivityParam2Label.Layout.Row = 2;
            app.SensitivityParam2Label.Layout.Column = 3;
            app.SensitivityParam2Dropdown = uidropdown(controlGrid);
            app.SensitivityParam2Dropdown.Layout.Row = 2;
            app.SensitivityParam2Dropdown.Layout.Column = 4;

            % Range controls
            lbl = uilabel(controlGrid); lbl.Text = 'Start (factor):';
            lbl.Layout.Row = 3; lbl.Layout.Column = 1;
            app.SensitivityStartSpinner = uispinner(controlGrid);
            app.SensitivityStartSpinner.Value = 0.5;
            app.SensitivityStartSpinner.Limits = [0.1 2];
            app.SensitivityStartSpinner.Step = 0.1;
            app.SensitivityStartSpinner.ValueDisplayFormat = '%.1f';
            app.SensitivityStartSpinner.Layout.Row = 3;
            app.SensitivityStartSpinner.Layout.Column = 2;

            lbl = uilabel(controlGrid); lbl.Text = 'End (factor):';
            lbl.Layout.Row = 3; lbl.Layout.Column = 3;
            app.SensitivityEndSpinner = uispinner(controlGrid);
            app.SensitivityEndSpinner.Value = 1.5;
            app.SensitivityEndSpinner.Limits = [0.1 3];
            app.SensitivityEndSpinner.Step = 0.1;
            app.SensitivityEndSpinner.ValueDisplayFormat = '%.1f';
            app.SensitivityEndSpinner.Layout.Row = 3;
            app.SensitivityEndSpinner.Layout.Column = 4;

            % Steps and run button
            lbl = uilabel(controlGrid); lbl.Text = 'Steps:';
            lbl.Layout.Row = 4; lbl.Layout.Column = 1;
            app.SensitivityStepsSpinner = uispinner(controlGrid);
            app.SensitivityStepsSpinner.Value = 11;
            app.SensitivityStepsSpinner.Limits = [3 50];
            app.SensitivityStepsSpinner.Step = 2;
            app.SensitivityStepsSpinner.Layout.Row = 4;
            app.SensitivityStepsSpinner.Layout.Column = 2;

            app.RunSensitivityButton = uibutton(controlGrid, 'push');
            app.RunSensitivityButton.Text = 'Run Analysis';
            app.RunSensitivityButton.FontWeight = 'bold';
            app.RunSensitivityButton.BackgroundColor = [0.2 0.4 0.8];
            app.RunSensitivityButton.FontColor = [1 1 1];
            app.RunSensitivityButton.Layout.Row = 4;
            app.RunSensitivityButton.Layout.Column = [3 4];

            % Results axes
            app.SensitivityAxes = uiaxes(sensGrid);
            app.SensitivityAxes.Layout.Row = 2;
            title(app.SensitivityAxes, 'Sensitivity Results');

            % Initially hide param2 controls
            app.SensitivityParam2Label.Visible = 'off';
            app.SensitivityParam2Dropdown.Visible = 'off';
        end

        function createOptimizationTab(app)
            %CREATEOPTIMIZATIONTAB Create the optimization tab.

            app.OptimizationTab = uitab(app.OutputTabGroup);
            app.OptimizationTab.Title = 'Optimization';

            optGrid = uigridlayout(app.OptimizationTab, [3 1]);
            optGrid.RowHeight = {'fit', 'fit', '1x'};
            optGrid.Padding = [10 10 10 10];
            optGrid.RowSpacing = 15;

            % Settings panel
            settingsPanel = uipanel(optGrid);
            settingsPanel.Title = 'Optimization Settings';
            settingsPanel.Layout.Row = 1;

            settingsGrid = uigridlayout(settingsPanel, [2 6]);
            settingsGrid.ColumnWidth = {'fit', '1x', 'fit', '1x', 'fit', '1x'};
            settingsGrid.RowHeight = {'fit', 'fit'};
            settingsGrid.Padding = [10 10 10 10];
            settingsGrid.RowSpacing = 8;

            % Objective dropdown
            lbl = uilabel(settingsGrid); lbl.Text = 'Objective:';
            lbl.Layout.Row = 1; lbl.Layout.Column = 1;
            app.OptObjectiveDropdown = uidropdown(settingsGrid);
            app.OptObjectiveDropdown.Items = {'Maximize Annualized Profit', 'Maximize ROI', 'Minimize Payback'};
            app.OptObjectiveDropdown.ItemsData = {'profit', 'roi', 'payback'};
            app.OptObjectiveDropdown.Value = 'profit';
            app.OptObjectiveDropdown.Layout.Row = 1;
            app.OptObjectiveDropdown.Layout.Column = 2;

            % Annualization years
            lbl = uilabel(settingsGrid); lbl.Text = 'Annualization Years:';
            lbl.Layout.Row = 1; lbl.Layout.Column = 3;
            app.OptYearsSpinner = uispinner(settingsGrid);
            app.OptYearsSpinner.Value = 10;
            app.OptYearsSpinner.Limits = [1 30];
            app.OptYearsSpinner.Layout.Row = 1;
            app.OptYearsSpinner.Layout.Column = 4;

            % Top N configs for Stage 2
            lbl = uilabel(settingsGrid); lbl.Text = 'Top N for Stage 2:';
            lbl.Layout.Row = 1; lbl.Layout.Column = 5;
            app.OptTopNSpinner = uispinner(settingsGrid);
            app.OptTopNSpinner.Value = 20;
            app.OptTopNSpinner.Limits = [5 50];
            app.OptTopNSpinner.Layout.Row = 1;
            app.OptTopNSpinner.Layout.Column = 6;

            % Run/Cancel buttons
            app.RunOptButton = uibutton(settingsGrid, 'push');
            app.RunOptButton.Text = 'RUN OPTIMIZATION';
            app.RunOptButton.FontWeight = 'bold';
            app.RunOptButton.BackgroundColor = [0.6 0.2 0.6];
            app.RunOptButton.FontColor = [1 1 1];
            app.RunOptButton.Layout.Row = 2;
            app.RunOptButton.Layout.Column = [1 3];

            app.CancelOptButton = uibutton(settingsGrid, 'push');
            app.CancelOptButton.Text = 'Cancel';
            app.CancelOptButton.Enable = 'off';
            app.CancelOptButton.Layout.Row = 2;
            app.CancelOptButton.Layout.Column = [4 6];

            % Progress panel
            progressPanel = uipanel(optGrid);
            progressPanel.Title = 'Progress';
            progressPanel.Layout.Row = 2;

            progressGrid = uigridlayout(progressPanel, [1 6]);
            progressGrid.ColumnWidth = {'fit', '1x', 'fit', '1x', 'fit', '1x'};
            progressGrid.RowHeight = {'fit'};
            progressGrid.Padding = [10 10 10 10];

            lbl = uilabel(progressGrid); lbl.Text = 'Stage:';
            lbl.Layout.Column = 1;
            app.OptStageLabel = uilabel(progressGrid);
            app.OptStageLabel.Text = 'Not started';
            app.OptStageLabel.FontWeight = 'bold';
            app.OptStageLabel.Layout.Column = 2;

            lbl = uilabel(progressGrid); lbl.Text = 'Progress:';
            lbl.Layout.Column = 3;
            app.OptProgressLabel = uilabel(progressGrid);
            app.OptProgressLabel.Text = '-';
            app.OptProgressLabel.Layout.Column = 4;

            lbl = uilabel(progressGrid); lbl.Text = 'Status:';
            lbl.Layout.Column = 5;
            app.OptStatusLabel = uilabel(progressGrid);
            app.OptStatusLabel.Text = 'Ready';
            app.OptStatusLabel.Layout.Column = 6;

            % Results panel
            resultsPanel = uipanel(optGrid);
            resultsPanel.Title = 'Results';
            resultsPanel.Layout.Row = 3;

            resultsGrid = uigridlayout(resultsPanel, [2 2]);
            resultsGrid.RowHeight = {'1x', 'fit'};
            resultsGrid.ColumnWidth = {'1x', '1x'};
            resultsGrid.Padding = [10 10 10 10];
            resultsGrid.RowSpacing = 10;

            % Stage 1 results table
            stage1Panel = uipanel(resultsGrid);
            stage1Panel.Title = 'Stage 1: Top Discrete Configs';
            stage1Panel.Layout.Row = 1;
            stage1Panel.Layout.Column = 1;

            stage1Grid = uigridlayout(stage1Panel, [1 1]);
            stage1Grid.Padding = [5 5 5 5];
            app.Stage1Table = uitable(stage1Grid);
            app.Stage1Table.ColumnName = {'Rank', 'Chipset', 'Cooling', 'Process', 'Objective'};
            app.Stage1Table.ColumnWidth = {40, 'auto', 'auto', 'auto', 70};

            % Stage 2 results table
            stage2Panel = uipanel(resultsGrid);
            stage2Panel.Title = 'Stage 2: Optimized Configs';
            stage2Panel.Layout.Row = 1;
            stage2Panel.Layout.Column = 2;

            stage2Grid = uigridlayout(stage2Panel, [1 1]);
            stage2Grid.Padding = [5 5 5 5];
            app.Stage2Table = uitable(stage2Grid);
            app.Stage2Table.ColumnName = {'Rank', 'Chipset', 'Cooling', 'Process', 'Objective'};
            app.Stage2Table.ColumnWidth = {40, 'auto', 'auto', 'auto', 70};

            % Action buttons
            app.LoadOptConfigButton = uibutton(resultsGrid, 'push');
            app.LoadOptConfigButton.Text = 'Load Best Config';
            app.LoadOptConfigButton.Layout.Row = 2;
            app.LoadOptConfigButton.Layout.Column = 1;

            app.ExportOptResultsButton = uibutton(resultsGrid, 'push');
            app.ExportOptResultsButton.Text = 'Export Results';
            app.ExportOptResultsButton.Layout.Row = 2;
            app.ExportOptResultsButton.Layout.Column = 2;
        end

        function createScenariosTab(app)
            %CREATESCENARIOSTAB Create the scenarios management tab.

            app.ScenariosTab = uitab(app.OutputTabGroup);
            app.ScenariosTab.Title = 'Scenarios';

            scenGrid = uigridlayout(app.ScenariosTab, [1 2]);
            scenGrid.ColumnWidth = {'fit', '1x'};
            scenGrid.Padding = [10 10 10 10];
            scenGrid.ColumnSpacing = 15;

            % Left: scenario list and controls
            leftPanel = uipanel(scenGrid);
            leftPanel.Title = 'Saved Scenarios';
            leftPanel.Layout.Row = 1;
            leftPanel.Layout.Column = 1;

            leftGrid = uigridlayout(leftPanel, [4 2]);
            leftGrid.RowHeight = {'1x', 'fit', 'fit', 'fit'};
            leftGrid.ColumnWidth = {'1x', '1x'};
            leftGrid.Padding = [10 10 10 10];
            leftGrid.RowSpacing = 8;

            app.ScenarioListBox = uilistbox(leftGrid);
            app.ScenarioListBox.Items = {};
            app.ScenarioListBox.Layout.Row = 1;
            app.ScenarioListBox.Layout.Column = [1 2];

            app.ScenarioNameField = uieditfield(leftGrid, 'text');
            app.ScenarioNameField.Placeholder = 'Scenario name...';
            app.ScenarioNameField.Layout.Row = 2;
            app.ScenarioNameField.Layout.Column = [1 2];

            app.AddScenarioButton = uibutton(leftGrid, 'push');
            app.AddScenarioButton.Text = 'Add Current';
            app.AddScenarioButton.Layout.Row = 3;
            app.AddScenarioButton.Layout.Column = 1;

            app.LoadScenarioButton = uibutton(leftGrid, 'push');
            app.LoadScenarioButton.Text = 'Load';
            app.LoadScenarioButton.Layout.Row = 3;
            app.LoadScenarioButton.Layout.Column = 2;

            app.DeleteScenarioButton = uibutton(leftGrid, 'push');
            app.DeleteScenarioButton.Text = 'Delete';
            app.DeleteScenarioButton.Layout.Row = 4;
            app.DeleteScenarioButton.Layout.Column = 1;

            app.CompareButton = uibutton(leftGrid, 'push');
            app.CompareButton.Text = 'Compare';
            app.CompareButton.Layout.Row = 4;
            app.CompareButton.Layout.Column = 2;
        end

        function registerCallbacks(app)
            %REGISTERCALLBACKS Register all callback functions.

            % Mode selection
            app.ModeButtonGroup.SelectionChangedFcn = @(src, event) modeSelectionChanged(app, event);

            % Guided mode controls
            app.ChipsetDropdown.ValueChangedFcn = @(src, event) guidedValueChanged(app, 'chipset', event);
            app.CoolingDropdown.ValueChangedFcn = @(src, event) guidedValueChanged(app, 'cooling', event);
            app.ProcessDropdown.ValueChangedFcn = @(src, event) guidedValueChanged(app, 'process', event);
            app.ITCapacitySpinner.ValueChangedFcn = @(src, event) guidedValueChanged(app, 'it_capacity', event);
            app.ComputeRateSpinner.ValueChangedFcn = @(src, event) guidedValueChanged(app, 'compute_rate', event);
            app.ElectricitySpinner.ValueChangedFcn = @(src, event) guidedValueChanged(app, 'electricity', event);
            app.HeatPumpCheckbox.ValueChangedFcn = @(src, event) guidedValueChanged(app, 'heat_pump', event);
            app.HPTempSpinner.ValueChangedFcn = @(src, event) guidedValueChanged(app, 'hp_temp', event);

            % Run controls
            app.RunButton.ButtonPushedFcn = @(src, event) runButtonPushed(app);
            app.ResetButton.ButtonPushedFcn = @(src, event) resetButtonPushed(app);
            app.LoadButton.ButtonPushedFcn = @(src, event) loadButtonPushed(app);
            app.SaveButton.ButtonPushedFcn = @(src, event) saveButtonPushed(app);

            % Details tab
            app.DetailsSectionDropdown.ValueChangedFcn = @(src, event) detailsSectionChanged(app);

            % Sensitivity tab
            app.SensitivityTypeDropdown.ValueChangedFcn = @(src, event) sensitivityTypeChanged(app);
            app.RunSensitivityButton.ButtonPushedFcn = @(src, event) runSensitivityButtonPushed(app);

            % Optimization tab
            app.RunOptButton.ButtonPushedFcn = @(src, event) runOptimizationButtonPushed(app);
            app.CancelOptButton.ButtonPushedFcn = @(src, event) cancelOptimizationButtonPushed(app);
            app.LoadOptConfigButton.ButtonPushedFcn = @(src, event) loadOptConfigButtonPushed(app);
            app.ExportOptResultsButton.ButtonPushedFcn = @(src, event) exportOptResultsButtonPushed(app);

            % Scenarios tab
            app.AddScenarioButton.ButtonPushedFcn = @(src, event) addScenarioButtonPushed(app);
            app.LoadScenarioButton.ButtonPushedFcn = @(src, event) loadScenarioButtonPushed(app);
            app.DeleteScenarioButton.ButtonPushedFcn = @(src, event) deleteScenarioButtonPushed(app);
            app.CompareButton.ButtonPushedFcn = @(src, event) compareButtonPushed(app);
        end

        function initializeApp(app)
            %INITIALIZEAPP Initialize app with default values.

            % Initialize helper classes
            app.ConfigEditor = tribe.ui.ConfigEditor();
            app.ModelRunner = tribe.ui.ModelRunner();
            app.SensitivityRunner = tribe.ui.SensitivityRunner();
            app.OptimizationRunner = tribe.ui.OptimizationRunner();

            % Populate dropdowns
            populateDropdowns(app);

            % Update UI from config
            updateUIFromConfig(app);

            % Populate sensitivity parameter dropdowns
            populateSensitivityParams(app);
        end

        function populateDropdowns(app)
            %POPULATEDROPDOWNS Populate dropdown menus with options.

            % Chipsets
            chipsets = tribe.ui.ConfigInspector.getChoices('rack_profile.chipset');
            app.ChipsetDropdown.Items = cellstr(chipsets);

            % Cooling methods
            cooling = tribe.ui.ConfigInspector.getChoices('rack_profile.cooling_method');
            app.CoolingDropdown.Items = cellstr(cooling);

            % Processes
            processes = tribe.ui.ConfigInspector.getChoices('buyer_profile.process_id');
            app.ProcessDropdown.Items = cellstr(processes);
        end

        function populateSensitivityParams(app)
            %POPULATESENSITIVITYPARAMS Populate sensitivity parameter dropdowns.

            params = tribe.ui.ConfigInspector.getSweepableParameters();
            labels = cell(size(params));
            for i = 1:numel(params)
                parts = strsplit(params(i), '.');
                labels{i} = char(strrep(parts(end), '_', ' '));
            end

            app.SensitivityParam1Dropdown.Items = labels;
            app.SensitivityParam1Dropdown.ItemsData = cellstr(params);
            app.SensitivityParam1Dropdown.Value = 'module_criteria.compute_rate_gbp_per_kw_per_month';

            app.SensitivityParam2Dropdown.Items = labels;
            app.SensitivityParam2Dropdown.ItemsData = cellstr(params);
            app.SensitivityParam2Dropdown.Value = 'module_opex.electricity_rate_gbp_per_kwh';
        end

        function updateUIFromConfig(app)
            %UPDATEUIFROMCONFIG Update UI controls from current config.

            cfg = app.ConfigEditor.getConfig();

            % Update guided mode controls
            app.ChipsetDropdown.Value = char(cfg.rack_profile.chipset);
            app.CoolingDropdown.Value = char(cfg.rack_profile.cooling_method);
            app.ProcessDropdown.Value = char(cfg.buyer_profile.process_id);
            app.ITCapacitySpinner.Value = cfg.rack_profile.module_it_capacity_target_kw;
            app.ComputeRateSpinner.Value = cfg.module_criteria.compute_rate_gbp_per_kw_per_month;
            app.ElectricitySpinner.Value = cfg.rack_profile.electricity_price_gbp_per_kwh;
            app.HeatPumpCheckbox.Value = cfg.module_criteria.heat_pump_enabled == 1;
            app.HPTempSpinner.Value = cfg.module_criteria.heat_pump_output_temperature_c;

            % Update HP temp spinner visibility
            app.HPTempSpinner.Enable = app.HeatPumpCheckbox.Value;

            if strcmp(app.AdvancedPanel.Visible, 'on')
                populateConfigTree(app);
            end
        end

        function modeSelectionChanged(app, event)
            %MODESELECTIONCHANGED Handle mode toggle.

            if app.GuidedButton.Value
                app.GuidedPanel.Visible = 'on';
                app.AdvancedPanel.Visible = 'off';
            else
                app.GuidedPanel.Visible = 'off';
                app.AdvancedPanel.Visible = 'on';
                populateConfigTree(app);
            end
        end

        function populateConfigTree(app)
            %POPULATECONFIGTREE Populate the advanced config tree.

            % Clear existing nodes
            delete(app.ConfigTree.Children);

            cfg = app.ConfigEditor.getConfig();
            sections = fieldnames(cfg);

            for i = 1:numel(sections)
                sect = sections{i};
                sectNode = uitreenode(app.ConfigTree, 'Text', sect);

                if isstruct(cfg.(sect))
                    fields = fieldnames(cfg.(sect));
                    for j = 1:numel(fields)
                        fname = fields{j};
                        val = cfg.(sect).(fname);
                        if isnumeric(val)
                            valStr = num2str(val);
                        else
                            valStr = char(val);
                        end
                        uitreenode(sectNode, 'Text', sprintf('%s: %s', fname, valStr));
                    end
                end
            end

            expand(app.ConfigTree);
        end

        function guidedValueChanged(app, field, event)
            %GUIDEDVALUECHANGED Handle changes to guided mode controls.

            switch field
                case 'chipset'
                    app.ConfigEditor.setField('rack_profile.chipset', event.Value);
                case 'cooling'
                    app.ConfigEditor.setField('rack_profile.cooling_method', event.Value);
                case 'process'
                    app.ConfigEditor.setField('buyer_profile.process_id', event.Value);
                case 'it_capacity'
                    app.ConfigEditor.setField('rack_profile.module_it_capacity_target_kw', event.Value);
                case 'compute_rate'
                    app.ConfigEditor.setField('module_criteria.compute_rate_gbp_per_kw_per_month', event.Value);
                case 'electricity'
                    app.ConfigEditor.setField('rack_profile.electricity_price_gbp_per_kwh', event.Value);
                    app.ConfigEditor.setField('module_opex.electricity_rate_gbp_per_kwh', event.Value);
                case 'heat_pump'
                    app.ConfigEditor.setField('module_criteria.heat_pump_enabled', double(event.Value));
                    app.HPTempSpinner.Enable = event.Value;
                case 'hp_temp'
                    app.ConfigEditor.setField('module_criteria.heat_pump_output_temperature_c', event.Value);
            end
        end

        function runButtonPushed(app)
            %RUNBUTTONPUSHED Handle run button click.

            app.StatusLabel.Text = 'Status: Running...';
            app.StatusLabel.FontColor = [0.9 0.6 0.1];
            app.RunButton.Enable = 'off';
            drawnow;

            try
                cfg = app.ConfigEditor.getConfig();
                [results, success, errMsg] = app.ModelRunner.run(cfg);

                if success
                    app.LastResults = results;
                    app.StatusLabel.Text = 'Status: Complete';
                    app.StatusLabel.FontColor = [0.2 0.7 0.3];
                    updateOutputs(app, results);
                else
                    app.StatusLabel.Text = 'Status: Error';
                    app.StatusLabel.FontColor = [0.8 0.2 0.2];
                    uialert(app.UIFigure, errMsg, 'Model Error');
                end
            catch ME
                app.StatusLabel.Text = 'Status: Error';
                app.StatusLabel.FontColor = [0.8 0.2 0.2];
                uialert(app.UIFigure, ME.message, 'Error');
            end

            app.RunButton.Enable = 'on';
        end

        function updateOutputs(app, results)
            %UPDATEOUTPUTS Update all output displays.

            updateKPITiles(app, results);
            updateCharts(app, results);
            updateDetailsTable(app);
        end

        function updateKPITiles(app, results)
            %UPDATEKPITILES Update KPI tile values.

            spl = results.spl;
            bp = results.bp;

            % Payback
            app.KPITiles.payback.value.Text = sprintf('%.1f yrs', spl.simple_payback_years);

            % ROI
            app.KPITiles.roi.value.Text = sprintf('%.1f%%', spl.unlevered_roi_pct * 100);

            % Margin
            app.KPITiles.margin.value.Text = sprintf('%.1f%%', spl.gross_margin_pct * 100);

            % Capex
            capexStr = tribe.ui.OutputCatalog.formatValue('spl', 'total_system_capex_gbp', spl.total_system_capex_gbp);
            app.KPITiles.capex.value.Text = capexStr;

            % Profit
            profitStr = tribe.ui.OutputCatalog.formatValue('spl', 'gross_profit_gbp_per_yr', spl.gross_profit_gbp_per_yr);
            app.KPITiles.profit.value.Text = profitStr;

            % Modules
            app.KPITiles.modules.value.Text = sprintf('%d', bp.modules_required);
        end

        function updateCharts(app, results)
            %UPDATECHARTS Update all chart displays.

            % Clear axes
            cla(app.CapexAxes);
            cla(app.OpexAxes);
            cla(app.RevenueAxes);
            cla(app.PaybackAxes);

            % Capex breakdown
            scapex = results.scapex;
            capexData = [scapex.total_module_capex, scapex.shared_infrastructure_gbp, ...
                scapex.integration_commissioning];
            capexLabels = {'Modules', 'Infrastructure', 'Integration'};
            bar(app.CapexAxes, capexData);
            app.CapexAxes.XTickLabel = capexLabels;
            title(app.CapexAxes, 'Capex Breakdown');
            ylabel(app.CapexAxes, 'GBP');

            % Opex breakdown
            sopex = results.sopex;
            opexData = [sopex.total_module_opex, sopex.shared_overhead_gbp_per_yr, ...
                sopex.heat_rejection_opex_gbp_per_yr];
            opexLabels = {'Modules', 'Overhead', 'Heat Rejection'};
            bar(app.OpexAxes, opexData);
            app.OpexAxes.XTickLabel = opexLabels;
            title(app.OpexAxes, 'Opex Breakdown');
            ylabel(app.OpexAxes, 'GBP/yr');

            % Revenue streams
            spl = results.spl;
            revenueData = [spl.compute_revenue_gbp_per_yr, spl.heat_revenue_gbp_per_yr];
            revenueLabels = {'Compute', 'Heat'};
            bar(app.RevenueAxes, revenueData);
            app.RevenueAxes.XTickLabel = revenueLabels;
            title(app.RevenueAxes, 'Revenue Streams');
            ylabel(app.RevenueAxes, 'GBP/yr');

            % Payback curve
            years = 0:ceil(spl.simple_payback_years * 1.5);
            cumulative = -spl.total_system_capex_gbp + spl.gross_profit_gbp_per_yr * years;
            plot(app.PaybackAxes, years, cumulative, 'LineWidth', 2);
            hold(app.PaybackAxes, 'on');
            yline(app.PaybackAxes, 0, '--', 'Color', [0.5 0.5 0.5]);
            xline(app.PaybackAxes, spl.simple_payback_years, '--r', 'Payback');
            hold(app.PaybackAxes, 'off');
            title(app.PaybackAxes, 'Cumulative Cash Flow');
            xlabel(app.PaybackAxes, 'Years');
            ylabel(app.PaybackAxes, 'GBP');
        end

        function updateDetailsTable(app)
            %UPDATEDETAILSTABLE Update the details table.

            if isempty(app.LastResults)
                return;
            end

            section = app.DetailsSectionDropdown.Value;
            T = app.ModelRunner.getResultsTable(section);
            app.DetailsTable.Data = T;
        end

        function detailsSectionChanged(app)
            %DETAILSSECTIONCHANGED Handle section dropdown change.
            updateDetailsTable(app);
        end

        function resetButtonPushed(app)
            %RESETBUTTONPUSHED Handle reset button click.

            app.ConfigEditor.reset();
            updateUIFromConfig(app);
            app.StatusLabel.Text = 'Status: Reset to defaults';
        end

        function loadButtonPushed(app)
            %LOADBUTTONPUSHED Handle load button click.

            [file, path] = uigetfile({'*.json'; '*.mat'}, 'Load Configuration');
            if file ~= 0
                try
                    app.ConfigEditor.loadFromFile(fullfile(path, file));
                    updateUIFromConfig(app);
                    app.StatusLabel.Text = 'Status: Config loaded';
                catch ME
                    uialert(app.UIFigure, ME.message, 'Load Error');
                end
            end
        end

        function saveButtonPushed(app)
            %SAVEBUTTONPUSHED Handle save button click.

            [file, path] = uiputfile({'*.json'; '*.mat'}, 'Save Configuration');
            if file ~= 0
                try
                    app.ConfigEditor.saveToFile(fullfile(path, file));
                    app.StatusLabel.Text = 'Status: Config saved';
                catch ME
                    uialert(app.UIFigure, ME.message, 'Save Error');
                end
            end
        end

        function sensitivityTypeChanged(app)
            %SENSITIVITYTYPECHANGED Handle sensitivity type dropdown change.

            sensType = app.SensitivityTypeDropdown.Value;

            if strcmp(sensType, 'sweep2d')
                app.SensitivityParam2Label.Visible = 'on';
                app.SensitivityParam2Dropdown.Visible = 'on';
            else
                app.SensitivityParam2Label.Visible = 'off';
                app.SensitivityParam2Dropdown.Visible = 'off';
            end
        end

        function runSensitivityButtonPushed(app)
            %RUNSENSITIVITYBUTTONPUSHED Handle run sensitivity button click.

            app.RunSensitivityButton.Enable = 'off';
            app.RunSensitivityButton.Text = 'Running...';
            drawnow;

            try
                app.SensitivityRunner.setBaseConfig(app.ConfigEditor.getConfig());

                sensType = app.SensitivityTypeDropdown.Value;
                metric = app.SensitivityMetricDropdown.Value;
                param1 = app.SensitivityParam1Dropdown.Value;
                startFactor = app.SensitivityStartSpinner.Value;
                endFactor = app.SensitivityEndSpinner.Value;
                steps = app.SensitivityStepsSpinner.Value;

                baseValue = app.ConfigEditor.getField(param1);
                values = linspace(baseValue * startFactor, baseValue * endFactor, steps);
                values = applySweepConstraints(app, param1, baseValue, values);

                cla(app.SensitivityAxes);

                switch sensType
                    case 'tornado'
                        result = app.SensitivityRunner.runSensitivity();
                        plotTornado(app, result, metric);

                    case 'sweep1d'
                        result = app.SensitivityRunner.runSweep(param1, values);
                        plot1DSweep(app, result, param1, metric);

                    case 'sweep2d'
                        param2 = app.SensitivityParam2Dropdown.Value;
                        baseValue2 = app.ConfigEditor.getField(param2);
                        values2 = linspace(baseValue2 * startFactor, baseValue2 * endFactor, steps);
                        values2 = applySweepConstraints(app, param2, baseValue2, values2);
                        result = app.SensitivityRunner.run2DSweep(param1, values, param2, values2, metric);
                        plot2DHeatmap(app, result);
                end

            catch ME
                uialert(app.UIFigure, ME.message, 'Analysis Error');
            end

            app.RunSensitivityButton.Enable = 'on';
            app.RunSensitivityButton.Text = 'Run Analysis';
        end

        function plotTornado(app, result, metric)
            %PLOTTORNADO Plot tornado chart.

            tornado = result.tornado.(metric);
            n = height(tornado);

            % Calculate bar widths
            labels = tornado.parameter_label;
            lowDelta = tornado.low_delta;
            highDelta = tornado.high_delta;

            % Sort by total range
            ranges = highDelta - lowDelta;
            [~, sortIdx] = sort(abs(ranges), 'descend');

            barh(app.SensitivityAxes, 1:n, [lowDelta(sortIdx), highDelta(sortIdx) - lowDelta(sortIdx)], 'stacked');
            app.SensitivityAxes.YTick = 1:n;
            app.SensitivityAxes.YTickLabel = labels(sortIdx);
            title(app.SensitivityAxes, sprintf('Sensitivity: %s', strrep(metric, '_', ' ')));
            xlabel(app.SensitivityAxes, 'Change from base');
        end

        function plot1DSweep(app, result, param_name, metric)
            %PLOT1DSWEEP Plot 1D parameter sweep.

            x = result.param_value;
            y = result.(metric);

            plot(app.SensitivityAxes, x, y, '-o', 'LineWidth', 2, 'MarkerSize', 6);

            parts = strsplit(param_name, '.');
            xlabel(app.SensitivityAxes, strrep(char(parts(end)), '_', ' '));
            ylabel(app.SensitivityAxes, strrep(metric, '_', ' '));
            title(app.SensitivityAxes, 'Parameter Sweep');
            grid(app.SensitivityAxes, 'on');
        end

        function plot2DHeatmap(app, result)
            %PLOT2DHEATMAP Plot 2D parameter sweep as heatmap.

            imagesc(app.SensitivityAxes, result.param1_values, result.param2_values, result.Z);
            colorbar(app.SensitivityAxes);

            parts1 = strsplit(result.param1_name, '.');
            parts2 = strsplit(result.param2_name, '.');
            xlabel(app.SensitivityAxes, strrep(char(parts1(end)), '_', ' '));
            ylabel(app.SensitivityAxes, strrep(char(parts2(end)), '_', ' '));
            title(app.SensitivityAxes, sprintf('2D Sweep: %s', strrep(result.metric, '_', ' ')));
        end

        function values = applySweepConstraints(app, param_name, base_value, values) %#ok<INUSL>
            try
                meta = tribe.ui.ConfigInspector.getFieldMeta(param_name);
            catch
                return;
            end

            constraint = lower(string(meta.constraints));
            switch constraint
                case "fraction"
                    values = min(max(values, 0), 1);
                case "non_negative"
                    values(values < 0) = 0;
                case "positive"
                    if base_value <= 0
                        fallback = meta.default;
                        if isnumeric(fallback) && isscalar(fallback) && fallback > 0
                            values = linspace(fallback * 0.5, fallback * 1.5, numel(values));
                        end
                    end
                    values(values <= 0) = eps;
            end
        end

        function addScenarioButtonPushed(app)
            %ADDSCENARIOBUTTONPUSHED Handle add scenario button click.

            if isempty(app.LastResults)
                uialert(app.UIFigure, 'Run the model first to save a scenario.', 'No Results');
                return;
            end

            name = app.ScenarioNameField.Value;
            if (isstring(name) && strlength(name) == 0) || isempty(name)
                name = sprintf('Scenario_%s', datestr(now, 'yyyymmdd_HHMMSS'));
            else
                name = char(name);
            end
            name = makeUniqueScenarioName(app, name);

            scenario = struct();
            scenario.name = name;
            scenario.config = app.ConfigEditor.getConfig();
            scenario.results = app.LastResults;
            scenario.timestamp = datetime('now');

            app.ScenarioLibrary(end+1) = scenario;
            updateScenarioList(app);
            app.ScenarioListBox.Value = name;
            app.ScenarioNameField.Value = '';
        end

        function updateScenarioList(app)
            %UPDATESCENARIOLIST Update the scenario listbox.

            names = {app.ScenarioLibrary.name};
            app.ScenarioListBox.Items = names;
        end

        function uniqueName = makeUniqueScenarioName(app, name)
            names = {app.ScenarioLibrary.name};
            uniqueName = name;
            if isempty(names)
                return;
            end

            baseName = name;
            counter = 2;
            while any(strcmp(names, uniqueName))
                uniqueName = sprintf('%s (%d)', baseName, counter);
                counter = counter + 1;
            end
        end

        function loadScenarioButtonPushed(app)
            %LOADSCENARIOBUTTONPUSHED Handle load scenario button click.

            if isempty(app.ScenarioListBox.Value)
                return;
            end

            idx = find(strcmp({app.ScenarioLibrary.name}, app.ScenarioListBox.Value), 1);
            if ~isempty(idx)
                app.ConfigEditor.loadFromStruct(app.ScenarioLibrary(idx).config);
                updateUIFromConfig(app);
                app.LastResults = app.ScenarioLibrary(idx).results;
                updateOutputs(app, app.LastResults);
                app.StatusLabel.Text = sprintf('Status: Loaded "%s"', app.ScenarioLibrary(idx).name);
            end
        end

        function deleteScenarioButtonPushed(app)
            %DELETESCENARIOBUTTONPUSHED Handle delete scenario button click.

            if isempty(app.ScenarioListBox.Value)
                return;
            end

            idx = find(strcmp({app.ScenarioLibrary.name}, app.ScenarioListBox.Value), 1);
            if ~isempty(idx)
                app.ScenarioLibrary(idx) = [];
                updateScenarioList(app);
            end
        end

        function compareButtonPushed(app)
            %COMPAREBUTTONPUSHED Handle compare scenarios button click.

            if numel(app.ScenarioLibrary) < 2
                uialert(app.UIFigure, 'Add at least 2 scenarios to compare.', 'Not Enough Scenarios');
                return;
            end

            % Create comparison figure
            fig = uifigure('Name', 'Scenario Comparison', 'Position', [200 200 800 400]);
            grid = uigridlayout(fig, [1 1]);

            % Build comparison table
            n = numel(app.ScenarioLibrary);
            data = cell(n, 7);

            for i = 1:n
                scen = app.ScenarioLibrary(i);
                data{i, 1} = scen.name;
                data{i, 2} = char(scen.config.rack_profile.chipset);
                data{i, 3} = char(scen.config.buyer_profile.process_id);
                data{i, 4} = scen.results.bp.modules_required;
                data{i, 5} = scen.results.spl.simple_payback_years;
                data{i, 6} = scen.results.spl.unlevered_roi_pct * 100;
                data{i, 7} = scen.results.spl.gross_profit_gbp_per_yr;
            end

            T = cell2table(data, 'VariableNames', {'Name', 'Chipset', 'Process', ...
                'Modules', 'Payback (yrs)', 'ROI (%)', 'Profit (GBP/yr)'});

            tbl = uitable(grid);
            tbl.Data = T;
            tbl.ColumnWidth = {'auto'};
        end

        function runOptimizationButtonPushed(app)
            %RUNOPTIMIZATIONBUTTONPUSHED Handle run optimization button click.

            app.RunOptButton.Enable = 'off';
            app.CancelOptButton.Enable = 'on';
            app.OptStageLabel.Text = 'Starting...';
            app.OptStatusLabel.Text = 'Initializing';
            drawnow;

            % Set up optimization options
            opts = struct();
            opts.top_n = app.OptTopNSpinner.Value;
            opts.objective = app.OptObjectiveDropdown.Value;
            opts.annualization_years = app.OptYearsSpinner.Value;

            app.OptimizationRunner.setBaseConfig(app.ConfigEditor.getConfig());
            app.OptimizationRunner.setOptions(opts);

            % Create a timer to update progress
            progressTimer = timer('ExecutionMode', 'fixedSpacing', ...
                'Period', 0.5, ...
                'TimerFcn', @(~,~) updateOptimizationProgress(app));

            try
                start(progressTimer);
                results = app.OptimizationRunner.runOptimization();
                stop(progressTimer);
                delete(progressTimer);

                if results.completed
                    displayOptimizationResults(app, results);
                    app.OptStatusLabel.Text = 'Complete';
                    app.OptStageLabel.Text = 'Finished';
                else
                    app.OptStatusLabel.Text = 'Cancelled';
                end
            catch ME
                stop(progressTimer);
                delete(progressTimer);
                app.OptStatusLabel.Text = 'Error';
                uialert(app.UIFigure, ME.message, 'Optimization Error');
            end

            app.RunOptButton.Enable = 'on';
            app.CancelOptButton.Enable = 'off';
        end

        function updateOptimizationProgress(app)
            %UPDATEOPTIMIZATIONPROGRESS Update progress display from runner.

            [stage, progress, message] = app.OptimizationRunner.getProgress();

            if stage == 1
                app.OptStageLabel.Text = 'Stage 1: Grid Search';
            elseif stage == 2
                app.OptStageLabel.Text = 'Stage 2: Optimization';
            end

            app.OptProgressLabel.Text = sprintf('%.0f%%', progress * 100);
            app.OptStatusLabel.Text = message;
            drawnow limitrate;
        end

        function cancelOptimizationButtonPushed(app)
            %CANCELOPTIMIZATIONBUTTONPUSHED Handle cancel button click.

            app.OptimizationRunner.cancel();
            app.CancelOptButton.Enable = 'off';
            app.OptStatusLabel.Text = 'Cancelling...';
        end

        function displayOptimizationResults(app, results)
            %DISPLAYOPTIMIZATIONRESULTS Display optimization results in tables.

            % Stage 1 table
            stage1 = results.stage1_top_n;
            n1 = min(height(stage1), 20);
            stage1Data = cell(n1, 5);
            for i = 1:n1
                stage1Data{i, 1} = i;
                stage1Data{i, 2} = char(stage1.chipset(i));
                stage1Data{i, 3} = char(stage1.cooling_method(i));
                stage1Data{i, 4} = char(stage1.process_id(i));
                stage1Data{i, 5} = round(stage1.objective(i), 0);
            end
            app.Stage1Table.Data = stage1Data;

            % Stage 2 table
            stage2 = results.stage2_results;
            n2 = numel(stage2);
            stage2Data = cell(n2, 5);

            % Sort by objective
            objectives = zeros(n2, 1);
            for i = 1:n2
                objectives(i) = stage2{i}.objective;
            end
            if strcmp(app.OptObjectiveDropdown.Value, 'payback')
                [~, sortIdx] = sort(objectives, 'ascend');
            else
                [~, sortIdx] = sort(objectives, 'descend');
            end

            for i = 1:n2
                idx = sortIdx(i);
                stage2Data{i, 1} = i;
                stage2Data{i, 2} = char(stage2{idx}.chipset);
                stage2Data{i, 3} = char(stage2{idx}.cooling_method);
                stage2Data{i, 4} = char(stage2{idx}.process_id);
                stage2Data{i, 5} = round(stage2{idx}.objective, 0);
            end
            app.Stage2Table.Data = stage2Data;
        end

        function loadOptConfigButtonPushed(app)
            %LOADOPTCONFIGBUTTONPUSHED Load best configuration into editor.

            try
                bestConfig = app.OptimizationRunner.getBestConfig();
                app.ConfigEditor.loadFromStruct(bestConfig);
                updateUIFromConfig(app);

                % Run the model with best config
                runButtonPushed(app);

                app.StatusLabel.Text = 'Status: Loaded optimal config';
            catch ME
                uialert(app.UIFigure, ME.message, 'Load Error');
            end
        end

        function exportOptResultsButtonPushed(app)
            %EXPORTOPTRESULTSBUTTONPUSHED Export optimization results.

            [file, path] = uiputfile({'*.mat'; '*.csv'}, 'Export Results');
            if file ~= 0
                try
                    app.OptimizationRunner.exportResults(fullfile(path, file));
                    app.OptStatusLabel.Text = 'Exported';
                catch ME
                    uialert(app.UIFigure, ME.message, 'Export Error');
                end
            end
        end
    end
end
