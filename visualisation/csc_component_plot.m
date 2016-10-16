function component_list = csc_component_plot(EEG)
% function to plot properties of a component and accept or reject them

% make the figure
handles = define_interface();

% check for EEG.icaact
if isempty(EEG.icaact)
    fprintf(1, 'recalculating EEG.icaact...\n')
    EEG.icaact = (EEG.icaweights * EEG.icasphere) ...
        * EEG.data(EEG.icachansind, :); 
end

% allocate the component list from scratch
number_components = size(EEG.icaact, 1);
handles.component_list = true(number_components, 1);

% set some specific properties from the data
set([handles.ax_erp_time, handles.ax_erp_image],...
    'xlim', [EEG.times(1), EEG.times(end)] / 1000);
   
% update the figure handles
guidata(handles.fig, handles)
setappdata(handles.fig, 'EEG', EEG);    
    
% initial plot
initial_plots(handles.fig);

% if an output is expected, wait for the figure to close
if nargout > 0
    uiwait(handles.fig);
    
    % get the handles structure
    handles = guidata(handles.fig);
    
    % get the output of the struct
    component_list = handles.component_list;

    % close the figure
    delete(handles.fig);    
end


function handles = define_interface()

% make a window
% ~~~~~~~~~~~~~
handles.fig = figure(...
    'name',         'csc component plotter',...
    'numberTitle',  'off',...
    'color',        [0.1, 0.1, 0.1],...
    'menuBar',      'none',...
    'units',        'normalized',...
    'outerPosition',[0 0.5 0.25 0.5]);

set(handles.fig, 'closeRequestFcn', {@fcn_close_window});

% make the axes
% ~~~~~~~~~~~~~
% topoplot_axes
handles.ax_topoplot = axes(...
    'parent',       handles.fig ,...
    'position',     [0.05 0.55, 0.4, 0.4] ,...
    'nextPlot',     'add' ,...
    'color',        [0.1, 0.1, 0.1] ,...
    'xcolor',       [0.1, 0.1, 0.1] ,...
    'ycolor',       [0.1, 0.1, 0.1] ,...
    'xtick',        [] ,...
    'ytick',        [] ,...
    'fontName',     'Century Gothic' ,...
    'fontSize',     8 );

% erp axes
handles.ax_erp_image = axes(...
    'parent',       handles.fig ,...
    'position',     [0.55 0.7, 0.4, 0.25] ,...
    'nextPlot',     'add' ,...
    'color',        [0.2, 0.2, 0.2] ,...
    'xcolor',       [0.9, 0.9, 0.9] ,...
    'ycolor',       [0.9, 0.9, 0.9] ,...
    'xtick',        [] ,...
    'ytick',        [] ,...
    'fontName',     'Century Gothic' ,...
    'fontSize',     8 );

handles.ax_erp_time = axes(...
    'parent',       handles.fig ,...
    'position',     [0.55 0.55, 0.4, 0.1] ,...
    'nextPlot',     'add' ,...
    'color',        [0.2, 0.2, 0.2] ,...
    'xcolor',       [0.9, 0.9, 0.9] ,...
    'ycolor',       [0.9, 0.9, 0.9] ,...
    'ytick',        [] ,...
    'fontName',     'Century Gothic' ,...
    'fontSize',     8 );

% spectra axes
handles.ax_spectra = axes(...
    'parent',       handles.fig ,...
    'position',     [0.05 0.05, 0.9, 0.3] ,...
    'nextPlot',     'add' ,...
    'color',        [0.2, 0.2, 0.2] ,...
    'xcolor',       [0.9, 0.9, 0.9] ,...
    'ycolor',       [0.9, 0.9, 0.9] ,...
    'ytick',        [] ,...
    'fontName',     'Century Gothic' ,...
    'fontSize',     8 );


% plot the spinner
% ~~~~~~~~~~~~~~~~
[handles.java.spinner, handles.spinner] = ...
    javacomponent(javax.swing.JSpinner);

set(handles.spinner,...
    'parent',   handles.fig,...      
    'units',    'normalized',...
    'position', [0.45 0.425 0.1 0.05]);
% Set the font and size (Found through >>handles.java.Slider.Font)
handles.java.spinner.setFont(javax.swing.plaf.FontUIResource('Century Gothic', 0, 25))
handles.java.spinner.getEditor().getTextField().setHorizontalAlignment(javax.swing.SwingConstants.CENTER)
handles.java.spinner.setValue(1);
set(handles.java.spinner, 'StateChangedCallback', {@cb_change_component, handles.fig});


% plot button
% ~~~~~~~~~~~
handles.ax_button = axes(...
    'parent',       handles.fig ,...
    'position',     [0.65 0.425, 0.05, 0.05] ,...
    'nextPlot',     'add' ,...
    'PlotBoxAspectRatio', [1, 1, 1] ,...
    'xlim',         [0, 1] ,...
    'ylim',         [0, 1] ,...
    'visible',      'off' ,...
    'fontName',     'Century Gothic' ,...
    'fontSize',     8 );

handles.button = rectangle(...
    'position', [0, 0, 1, 1],...
    'curvature', [1, 1] ,...
    'parent', handles.ax_button,...
    'faceColor', [0, 1, 0] ,...
    'edgeColor', [0.9, 0.9, 0.9] ,...
    'userData', 1 ,...
    'buttonDownFcn', {@cb_accept_reject});

% plot titles
% ~~~~~~~~~~~
handles.title_topo = uicontrol(...
    'style',    'text',...
    'string',   'topography',...
    'parent',   handles.fig,...
    'units',    'normalized',...
    'position', [0.05 0.95, 0.4, 0.025] ,...
    'backgroundColor', [0.1, 0.1, 0.1] ,...  
    'foregroundColor', [0.9, 0.9, 0.9] ,...
    'fontName', 'Century Gothic',...
    'fontSize', 11);

handles.title_image = uicontrol(...
    'style',    'text',...
    'string',   'trial activity',...
    'parent',   handles.fig,...
    'units',    'normalized',...
    'position', [0.55 0.95, 0.4, 0.025] ,...
    'backgroundColor', [0.1, 0.1, 0.1] ,...  
    'foregroundColor', [0.9, 0.9, 0.9] ,...
    'fontName', 'Century Gothic',...
    'fontSize', 11);

handles.title_erp = uicontrol(...
    'style',    'text',...
    'string',   'evoked potential',...
    'parent',   handles.fig,...
    'units',    'normalized',...
    'position', [0.55 0.65, 0.4, 0.025] ,...
    'backgroundColor', [0.1, 0.1, 0.1] ,...  
    'foregroundColor', [0.9, 0.9, 0.9] ,...
    'fontName', 'Century Gothic',...
    'fontSize', 11);

handles.title_erp = uicontrol(...
    'style',    'text',...
    'string',   'power spectra',...
    'parent',   handles.fig,...
    'units',    'normalized',...
    'position', [0.05 0.35, 0.9, 0.025] ,...
    'backgroundColor', [0.1, 0.1, 0.1] ,...  
    'foregroundColor', [0.9, 0.9, 0.9] ,...
    'fontName', 'Century Gothic',...
    'fontSize', 11);

handles.title_spectra = uicontrol(...
    'style',    'text',...
    'string',   'power spectra',...
    'parent',   handles.fig,...
    'units',    'normalized',...
    'position', [0.05 0.35, 0.9, 0.025] ,...
    'backgroundColor', [0.1, 0.1, 0.1] ,...  
    'foregroundColor', [0.9, 0.9, 0.9] ,...
    'fontName', 'Century Gothic',...
    'fontSize', 11);


function initial_plots(object)
% get the handles structure
handles = guidata(object);

% get the data
EEG = getappdata(handles.fig, 'EEG');

% component number
no_comp = 1;

% ---------------------------- %
% plot the image of all trials %
% ---------------------------- %
handles.plots.image = ...
    imagesc(EEG.times / 1000, 1 : EEG.trials, ...
    squeeze(EEG.icaact(no_comp, :, :))', ...
    'parent', handles.ax_erp_image);

% ------------------------- %
% plot the evoked potential %
% ------------------------- %
handles.plots.erp_time = ...
    plot(handles.ax_erp_time,...
    EEG.times / 1000, mean(EEG.icaact(no_comp, : , :), 3)',...
    'color', [0.9, 0.9, 0.9] ,...
    'lineWidth', 2);

% --------------------- %
% get the power spectra %
% --------------------- %
% define frequency range of interest
freq_range = 1 : 0.25 : 35;

% calculate the power spectra density using p_welch
[fft_data, frequencies] = pwelch(...
    reshape(EEG.icaact(no_comp, :, :), EEG.pnts * EEG.trials, []),...
    [], [] ,...
    freq_range ,...
    EEG.srate );

% normalise the fft by 1/f
fft_data = fft_data.* frequencies;

% plot the spectra
handles.plots.spectra = ...
    plot(handles.ax_spectra ,...
    frequencies, fft_data ,...
    'color', [0.9, 0.9, 0.9] ,...
    'lineWidth', 2);

% ------------------- %
% plot the topography %
% ------------------- %
handles.plots.topo = ...
    csc_Topoplot(EEG.icawinv(:, no_comp), EEG.chanlocs ,...
    'axes', handles.ax_topoplot ,...
    'plotChannels', false);

% update the handles
guidata(handles.fig, handles)


function cb_change_component(~, ~, object)
% get the handles structure
handles = guidata(object);

% get the data
EEG = getappdata(handles.fig, 'EEG');

% check the current value
current_component = handles.java.spinner.getValue();
max_component = size(EEG.icaact, 1);

if current_component > max_component
    handles.java.spinner.setValue(max_component);
    return;
elseif current_component < 1
    handles.java.spinner.setValue(1);
    return;
end

% update the plots
update_plots(handles.fig)


function update_plots(object)
% get the handles structure
handles = guidata(object);

% get the data
EEG = getappdata(handles.fig, 'EEG');

% get the current value
current_component = handles.java.spinner.getValue();

% update the button
if handles.component_list(current_component)
    % turn button green
    set(handles.button, 'faceColor', [0, 1, 0]);
else
    % turn button red
    set(handles.button, 'faceColor', [1, 0, 0]);
end

% re-set the image of all trials %
set(handles.plots.image, ...
    'cData', squeeze(EEG.icaact(current_component, :, :))');

% re-set the evoked potential %
set(handles.plots.erp_time, ...
    'ydata', mean(EEG.icaact(current_component, : , :), 3));

% re-set the power spectra %
freq_range = 1 : 0.25 : 35;

% calculate the power spectra density using p_welch
[fft_data, frequencies] = pwelch(...
    reshape(EEG.icaact(current_component, :, :), EEG.pnts * EEG.trials, []),...
    [], [] ,...
    freq_range ,...
    EEG.srate );

% normalise the fft by 1/f
fft_data = fft_data.* frequencies;

% plot the spectra
set(handles.plots.spectra, ...
    'ydata', fft_data);

% ------------------- %
% plot the topography %
% ------------------- %
handles.plots.topo = ...
    csc_Topoplot(EEG.icawinv(:, current_component), EEG.chanlocs ,...
    'axes', handles.ax_topoplot ,...
    'plotChannels', false);

guidata(handles.fig, handles)


function cb_accept_reject(object, ~)
% get the handles structure
handles = guidata(object);

% component number
current_component = handles.java.spinner.getValue();

% change the current value;
if handles.component_list(current_component)
    handles.component_list(current_component) = false;
    % turn button red
    set(object, 'faceColor', [1, 0, 0]);
else
    handles.component_list(current_component) = true;
    % turn button green
    set(object, 'faceColor', [0, 1, 0]);
end

% update the handles
guidata(handles.fig, handles)


function fcn_close_window(object, ~)
% just resume the ui if the figure is closed
handles = guidata(object);

% get current figure status
current_status = get(handles.fig, 'waitstatus');

if isempty(current_status)
    % close the figure
    delete(handles.fig);
    return;
end

switch current_status
    case 'waiting'
        uiresume;
    otherwise
        % close the figure
        delete(handles.fig);
end