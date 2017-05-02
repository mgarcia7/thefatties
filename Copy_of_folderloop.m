ABSPATH = strcat(pwd,'/');
basePath = '/Users/melissagarcia/Google Drive/the fatties/Data'; %Basepath of where the data is

addpath(ABSPATH);


parentfolderNames = getFolders(basePath); 


% experimental_data{design_number}{insulin}
experimental_data = repmat({{[],[]}}, 1, 8);
    
%%
for i=1:length(parentfoldersNames) % Go through Round folders
    round = parentfoldersNames{i};
    currentPath = fullfile(basePath,round);
    cd(currentPath);
    disp(round)

    designfoldersNames = getFolders(currentPath); 
    
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
        

        dayfoldersNames = getFolders(designPath);
        current_design_data = zeros(length(dayfoldersNames),2); % Holds the data for a particular design
        
        init = dayfoldersNames{1};
        
        if numel(dayfoldersNames) >= 4
            final = dayfoldersNames{4};
        else
            final = dayfoldersNames{end};
        end
            
        
        samples = {'S1','S2','Sother'};
        
        initarea = [NaN, NaN, NaN];
        finalarea = [NaN, NaN, NaN];
        
        disp('Processing final folders')
        % Go through final folders
        tic;
        for s = 1:3 % Go through sample folders
            imdir = fullfile(designPath,final,samples(s),'*.tif');
            files = dir(imdir{1});
            for f = 1:numel(files) % Go through images in 1 sample
                disp(files(f).name)
                imfile = fullfile(designPath,final,samples(s),files(f).name);
                
                if ~isnan(finalarea(s))
                    finalarea(s) = finalarea(s) + getTotalAreaFOV(imread(imfile{1}));
                else
                    finalarea(s) = getTotalAreaFOV(imread(imfile{1}));
                end
            end
        end
        toc;
        
        disp('Processing init')
        tic;
        % Go through init folders
        for s = 1:3 % Go through sample folders
            imdir = fullfile(designPath,init,samples(s),'*.tif');
            files = dir(imdir{1});
            for f = 1:numel(files) % Go through images in 1 sample
                disp(files(f).name)
                imfile = fullfile(designPath,init,samples(s),files(f).name);
                
                if ~isnan(initarea(s))
                    initarea(s) = initarea(s) + getTotalAreaFOV(imread(imfile{1}));
                else
                    initarea(s) = getTotalAreaFOV(imread(imfile{1}));
                end
            end
        end
        toc;
        
        delta = (finalarea - initarea)./initarea;
        delta(isnan(delta)) = []; % Removes NaN

        experimental_data{design_number}{ins_val} = [experimental_data{design_number}{ins_val} delta];
        
    end
    
    cd(currentPath);
end

save('/Users/melissagarcia/Google Drive/the fatties/Data/experimental_data_DeltaAreaUntilDay12.mat','experimental_data');
