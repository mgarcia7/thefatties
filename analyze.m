function analyze
% SIMPLE_GUI2 Select data from a particular round, and then plot the ones
% you like ~

%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off','Position',[360,500,1000,600]);

% Load experimental data to the workspace
d = load('Data/experimental_data.mat');
experimental_data = d.experimental_data;

% Construct the components.

% Push button to save the plot
hsave    = uicontrol('Style','pushbutton',...
             'String','Save','Position',[700,20,100,25],...
             'Callback',@savebutton_Callback);
         
% Panel that is populated w checkboxes with the available data (need to
% make sure that something is not empty before displaying it as a choice)
hpanel = uipanel('parent',f,...
    'Title','Choose which designs to plot',... 
    'position',[.78 .45 .2 .5]);



% Pop up menu w the rounds to choose from
string_menu_options = cellstr(strcat('Round ',num2str([1:length(experimental_data)]','%d'))); % It says the brackets are unnecessary, but then it doesn't do the right thing so like it's lying
hpopup = uicontrol('Style','popupmenu',...
           'String',string_menu_options,...
           'Position',[300,50,100,25],...
           'Callback',@popup_menu_Callback);
       
% Axes in which to plot stuff
ha = axes('Position',[.05,.2,.7,.7]);
hold(ha);

align([hpanel,hsave,hpopup],'Center','None');

% Initialize the UI.
% Change units to normalized so components resize automatically.
f.Units = 'normalized';
ha.Units = 'normalized';
hpanel.Units = 'normalized';
hsave.Units = 'normalized';
hpopup.Units = 'normalized';

% Initialize variables here so that they are accessible to all nested
% functions
current_data = []; 
plts = [];
cbx = [];

% Assign the a name to appear in the window title.
f.Name = 'wut up fatties ~~~';

% Move the window to the center of the screen.
movegui(f,'center')

% Make the window visible.
f.Visible = 'on';

%  Pop-up menu callback. 
% Changes the round dataset that it's using, and populates the checkboxes
   function popup_menu_Callback(source,~) 
      % Determine the # of the selected dataset
      val = get(source,'Value');
      
      % Set current data to the selected data set.
      current_data = experimental_data{val};
      
      % Clears panel & plots
      delete(get(hpanel,'Children'))
      delete(allchild(ha))
      
      % Populate panel w checkboxes
      non_empty_cells_idx = find(~cellfun(@isempty,current_data));
      [ins,design] = ind2sub(size(current_data),non_empty_cells_idx);
      
      cbx = zeros(1,length(ins));
      plts = zeros(1,length(ins));
      for i = 1:length(cbx)
          dnum = design(i);
          if ins(i) == 1
              cbx_string = strcat('D',num2str(design(i)),'wo');
              cbx(i) = uicontrol('parent',hpanel,'style','checkbox','string',cbx_string, 'position', [10 130-((dnum-1)*15) 50 15], 'Callback',{@cbx_Callback,cbx_string,i});
          else
              cbx_string = strcat('D',num2str(design(i)),'wi');
              cbx(i) = uicontrol('parent',hpanel,'style','checkbox','string',cbx_string, 'position', [100 130-((dnum-1)*15) 50 15], 'Callback',{@cbx_Callback,cbx_string,i});
          end
          
      end
      
   end
    
  function cbx_Callback(source,eventdata,id,i)
      % Plots or unplots data based on whether a button is checked or not
      
      % WILL BREAK IF DESIGN NUMBER > 9 OR if 'o' or 'i' isn't the last
      % character
      dnum = str2double(id(2));
      if id(end) == 'o'
          ins_val = 1;
      else
          ins_val = 2;
      end
      
      if (get(source,'Value') == get(source,'Max')) % if button is checked
          design_data = current_data{ins_val,dnum};
          design_data = sortrows(design_data,1);
          plts(i) = plot(ha,design_data(:,1),design_data(:,2), '-x', 'DisplayName',id);
      else
          delete(plts(i));
      end
      
      legend(ha,'-DynamicLegend');
  end

  function savebutton_Callback(source,eventdata) 
    ax_old = ha;
    f_new = figure('Visible','off');
    ax_new = copyobj(ax_old,f_new);
    set(ax_new,'Position','default')
    print(f_new,strcat('plot',datestr(datetime('now'))),'-dpng')
  end

end