function [ parentfoldersNames ] = getFolders(basePath)

allPaths = dir(basePath);  %Gets all content from directory
subFolders = [allPaths(:).isdir]; %Gets other subfolders
parentfoldersNames = {allPaths(subFolders).name}'; %Sort subfolder names
parentfoldersNames(ismember(parentfoldersNames,{'.','..'})) = []; %Deletes the default folders

end

