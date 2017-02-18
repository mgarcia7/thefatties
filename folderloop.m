ABSPATH = strcat(pwd,'/');
basePath = 'Data'; %Basepath of where the data is

addpath(ABSPATH);

allPaths = dir(basePath);  %Gets all content from directory
subFolders = [allPaths(:).isdir]; %Gets other subfolders
parentfoldersNames = {allPaths(subFolders).name}'; %Sort subfolder names
parentfoldersNames(ismember(parentfoldersNames,{'.','..'})) = []; %Deletes the default folders

experimental_data = cell(1,length(parentfoldersNames)); % Holds every round lol

for i=1:length(parentfoldersNames) % Go through Round folders
    round = parentfoldersNames{i};
    currentPath = strcat([ABSPATH basePath '/' round]);
    cd(currentPath);
    disp(currentPath)

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
        
        designPath = strcat([currentPath '/' design]); %Path for design
        cd(designPath);   
        disp(designPath)
        
        if design(end) == 'i'
            design_number = str2double(design(7:end-1));
        else
            design_number = str2double(design(7:end));
        end
        
        allPaths = dir(designPath);
        subFolders = [allPaths(:).isdir];
        dayfoldersNames = {allPaths(subFolders).name};
        dayfoldersNames(ismember(dayfoldersNames,{'.','..'})) = [];
        
        current_design_data = zeros(length(dayfoldersNames),2); % Holds the data for a particular design
        
        for k = 1:length(dayfoldersNames)
            day = char(dayfoldersNames(k));
            day_number = str2double(day(4:end)); 
            imagePath = strcat(designPath,'/',day,'/','*.tif');
            files = dir(imagePath); % List of images
            
            dayAreas = [];
            for n=1:length(files), %Loops through images
                im = imread(strcat(designPath,'/',day,'/',files(n).name)); %Reads in images
                disp(files(n).name);
                currentBlobAreas = improf(im);
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
    save(strcat(round,'_data'), 'round_data');
end

save('experimental_data','experimental_data');
