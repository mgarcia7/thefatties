clear;clc;
close all
%NOTE I COMMENTED OUT ALL THE IMAGE SHOW TO MAKE SURE IT WAS WORKING
%Article Below
%https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4442582/#SD1
% Reads in sample, if it has three channels, takes only the first channel
%fname = 'R1D2S1d00I1wi.tif';

xaxis = [0,4,8,12,16];
avgImageBlobDiam = [];
avgImageBlobAreas = [];
avgDayBlobAreas = [];
avgDayBlobDiam = [];


basePath = 'Data/Round1/Design3/'; %Basepath of where the data is
allPaths = dir(basePath);  %Gets all content from directory
subFolders = [allPaths(:).isdir]; %Gets other subfolders
foldersNames = {allPaths(subFolders).name}'; %Sort subfolder names
foldersNames(ismember(foldersNames,{'.','..'})) = []; %Deletes the default folders
for i=1:length(foldersNames), %Loop through subfolders
    tmp = foldersNames{i};  %Folder Names
    currentPath =strcat([basePath tmp]); %Path for next subfolder
    cd(currentPath);   %Transfers to new directory
    files = dir('*.tif'); %List of images
    for j=1:length(files), %Loops through images
        im = imread(files(j).name); %Reads in images
        disp(files(j).name);
        if size(im,3) == 3
            im = im(:, :, 1);
        end
        %%
        % Converts image to a value btw 0 to 1
        %im_gray = double(im)/255;
        
        % Proportionally scales the image so that 0 = min val and 1 = max val
        im_gray = imadjust(im);
        %imshow(im_gray)
        
        %%
        % Creating a binary image using threshold found above
        threshold = graythresh(im_gray);
        bin_image = im2bw(im_gray,threshold*1.57);
        
        % Fill the holes in da image
        Filled_Image=imfill(bin_image,'holes');
        
        % Filtering
        % TODO: decide which filter and disk size, maybe try to find it
        % programmatically
        bin_image = medfilt2(Filled_Image,[8 8]);
        
        %figure
        %imshow(bin_image)
        
        %%
        % Labels the images
        [labeled_im,num_of_objects]=bwlabel(bin_image,8);
        
        % Gets the blob properties
        blobMeasurements = regionprops(labeled_im,'all');
        allBlobAreas = [blobMeasurements.Area];
        allBlobPerimeters = [blobMeasurements.Perimeter];
        allBlobExtents = [blobMeasurements.Extent];
        allBlobDiameters = [blobMeasurements.EquivDiameter];
        
        avgImageBlobAreas(j) = mean(allBlobAreas);
        avgImageBlobDiam(j) = mean(allBlobDiameters);
        
        
        allBlobCircularities = (4*3.14.*allBlobAreas)./(allBlobPerimeters.^2); % Isoperimetric inequality
        
        % Logical vector that has 1 or 0 depending on whether it meets the
        % threshold
        allowableArea = (allBlobAreas > 6);
        allowableExtent = (allBlobExtents >= 0.50);
        allowableCircularity = (allBlobCircularities >= 0.8);
        
        % Extracts the circular ones!!
        % TODO: Improve on this? Maybe use circularity instead of extent? Maybe
        % eccentricity??
        BWcircles = ismember(labeled_im, find(allowableArea & (allowableCircularity | allowableExtent)));
        
        %figure(2)
        % Plots the blobs on top of the original image
        %imshow(im_gray)
        hold on
        numberOfBlobs = size(find(allowableExtent),2);
        
        boundaries = bwboundaries(BWcircles);
        numberOfBoundaries = size(boundaries,1);
        for k = 1 : numberOfBoundaries
            thisBoundary = boundaries{k};
            %plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
        end
        hold off
    end
    
    %Averages the Image Averages to get the Day Average
    avgDayBlobAreas(i) = mean(avgImageBlobAreas)./10;
    avgDayBlobDiam(i) = mean(avgImageBlobDiam)./10;
    
%     [allBlobDiaMicro] = (avgImageBlobAreas)./10;
%     [allBlobAreaMicro] = (avgImageBlobAreas)./10;
%     avgDia = mean(allBlobDiaMicro);
%     avgArea = mean(allBlobAreaMicro);
    textFileName1 = 'Diameters.txt';
    textFileName2 = 'Areas.txt';
    fileID1 = fopen(textFileName1, 'w');
    fileID2 = fopen(textFileName2, 'w');
    fprintf(fileID1, 'Diameters from %s\n', tmp);
    fprintf(fileID2, 'Areas from %s\n', tmp);
    fprintf(fileID1, '%3.2f \n', (avgImageBlobDiam./10));
    fprintf(fileID2, '%3.2f \n', (avgImageBlobAreas./10));
    fprintf(fileID1, 'Average Diameter: %3.2f', avgDayBlobDiam(i));
    fprintf(fileID2, 'Average Area: %3.2f', avgDayBlobAreas(i));
    fclose(fileID1);
    fclose(fileID2);
    cd ..;
    cd ..;
    cd ..;
    cd ..;
   
end
%avgDayBlobAreas = avgDayBlobAreas./10;
%avgDayBlobDiam = avgDayBlobDiam./10;

%Plot data
figure(1)
scatter(xaxis, avgDayBlobDiam,'b','Linewidth', 3);
grid on;
x = xlabel('Time (Days)');
y = ylabel('Average Day Lipid Droplet Diameters (Microns)');
t = title('Round 1 Design 3 Diameters (Without Insulin)');
set(t,'Fontweight','bold','Fontsize', 23);
set(x,'Fontweight','bold','Fontsize', 23);
set(y,'Fontweight','bold','Fontsize', 23);
set(gca,'Fontweight','bold','Fontsize',20);
%saveas(gcf, 'Round 2 Day 2 Diameters (Without Insulin).jpg');

figure(2)
scatter(xaxis, avgDayBlobAreas,'b','Linewidth', 3);
grid on;
x = xlabel('Time (Days)');
y = ylabel('Average Day Lipid Droplet Area (Microns)');
t = title('Round 1 Design 3 Area (Without Insulin)');
set(t,'Fontweight','bold','Fontsize', 23);
set(x,'Fontweight','bold','Fontsize', 23);
set(y,'Fontweight','bold','Fontsize', 23);
set(gca,'Fontweight','bold','Fontsize',20);
%saveas(gcf, 'Round 2 Day 2 Areas (Without Insulin).jpg');
%% Get stats
%createconfusionmat(fname,BWcircles);