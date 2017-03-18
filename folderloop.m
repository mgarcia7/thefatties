ABSPATH = strcat(pwd,'/');
basePath = 'Data'; %Basepath of where the data is

addpath(ABSPATH);

allPaths = dir(basePath);  %Gets all content from directory
subFolders = [allPaths(:).isdir]; %Gets other subfolders
parentfoldersNames = {allPaths(subFolders).name}'; %Sort subfolder names
parentfoldersNames(ismember(parentfoldersNames,{'.','..'})) = []; %Deletes the default folders

% If it exists, load the experimental_data file, if not, create a new one
try
    d = load(fullfile(ABSPATH,'Data','experimental_data.mat')); 
    experimental_data = d.experimental_data;
    disp('Successfully loaded Data/experimental_data.mat..')
catch
    experimental_data = cell(1,length(parentfoldersNames));
    disp('No Data/experimental_data.mat found..')
end
    
%%
for i=1:length(parentfoldersNames) % Go through Round folders
    round = parentfoldersNames{i};
    currentPath = fullfile(ABSPATH,basePath,round);
    cd(currentPath);
    
    
    allPaths = dir(currentPath);
    subFolders = [allPaths(:).isdir];
    designfoldersNames = {allPaths(subFolders).name};
    designfoldersNames(ismember(designfoldersNames,{'.','..'})) = [];

    round_data = cell(2,length(designfoldersNames)); % Holds the data for each round
    round_number = str2double(round(6:end));
        
    for j=1:length(designfoldersNames), % Go through Design folders
        design = designfoldersNames{j};  %Folder Names
        
        if design(1) == '.' %Skip hidden folders
            continue
        end
        
        designPath = fullfile(currentPath,design);  %Path for design
        cd(designPath);   
      
        
        if design(end) == 'i'
            design_number = str2double(design(7:end-1));
            ins_val = 2;
        else
            design_number = str2double(design(7:end));
            ins_val = 1;
        end
        
        allPaths = dir(designPath);
        subFolders = [allPaths(:).isdir];
        dayfoldersNames = {allPaths(subFolders).name};
        dayfoldersNames(ismember(dayfoldersNames,{'.','..'})) = [];
        
        current_design_data = zeros(length(dayfoldersNames),2); % Holds the data for a particular design
        
        for k = 1:length(dayfoldersNames)
            day = char(dayfoldersNames(k));
            day_number = str2double(day(4:end)); 
            disp(strcat('Processing ', round, ' ', design, ' ', day, ' data...'))
            
            
            % Check if this particular day has already been analyzed
            pot = (experimental_data{round_number}{ins_val,design_number}(:,1) == day_number);
            
            if sum(pot) > 0 % if the particular day is found in the matrix, then that  means it has already been analyzed and should not be analyzed again
                continue;
                disp('Data has already been processed..')
            end
            
            imagePath = fullfile(designPath,day,'*.tif'); 
            files = dir(imagePath); % List of images
            
            dayAreas = zeros(1,length(files));
            for n=1:length(files), %Loops through images
                im = imread(fullfile(designPath,day,files(n).name)); %Reads in images
                disp(strcat('Analyzing ', files(n).name, '...'))
                
                tic;
                [currentBlobAreas, currentBlobDiams] = improf(im);
                toc;
                dayAreas = [dayAreas currentBlobAreas]; 
            end

            [allBlobAreasMicro] = (dayAreas.*6.7)./10;
            avgArea = mean(allBlobAreasMicro);
            current_design_data(k,:) = [day_number avgArea];
        end
        
        % INSULIN = 2, W/O INSULIN = 1
        if design(end) == 'i'
            round_data{2,design_number} = current_design_data;
        else
            round_data{1,design_number} = current_design_data;
        end
        
    end
    
    cd(currentPath);
    experimental_data{round_number} = round_data;
end

save('experimental_data','experimental_data');
