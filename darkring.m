clear

%MYDIR = '/Users/melissagarcia/Google Drive/the fatties/Sample Images/Round 1/Day 0 TIF/';
%fname = 'R1D2S1d00I1wi.tif';


basePath = 'Data/Round1/Design2/'; %Basepath of where the data is
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
            im = im(:, :, 2);
        end
        % Reads in sample, if it has three channels, takes only the first channel
        % im = imread(strcat(MYDIR,fname));
        % if size(im,3) == 3
        %     im = im(:, :, 2);
        % end
        
        % Converts image to a value btw 0 to 1
        %im_gray = double(im)/255;
        
        % Proportionally scales the image so that 0 = min val and 1 = max val
        im_gray = imadjust(im);
        
        % Increase the difference between the dark outer ring and the lipid droplet
        threshold = graythresh(im_gray)*0.75;
        im_gray(im_gray <= threshold) = 0;
        %imshow(im_gray)
        
        %% Get the circles + create binary image
        Rmin = 5;
        Rmax = 30;
        
        [centers, radii] = imfindcircles(im_gray,[5 10],'ObjectPolarity','bright');
        [centers2, radii2] = imfindcircles(im_gray,[11 20],'ObjectPolarity','bright');
        [centers3, radii3] = imfindcircles(im_gray,[21 30],'ObjectPolarity','bright');
        
        centers = [centers; centers2; centers3];
        radii = [radii; radii2; radii3];
        
        xc = centers(:,1);
        yc = centers(:,2);
        [xDim,yDim] = size(im_gray);
        [xx,yy] = meshgrid(1:yDim,1:xDim);
        bin_image = false(xDim,yDim);
        for idx = 1:numel(radii)
            bin_image = bin_image | hypot(xx - xc(idx), yy - yc(idx)) <= radii(idx);
        end
        
        %% Label images and plot
        
        % Labels the images
        [labeled_im,num_of_objects]=bwlabel(bin_image,8);
        
        % Gets the blob properties
        blobMeasurements = regionprops(labeled_im,'all');
        allBlobAreas = [blobMeasurements.Area];
        allBlobPerimeters = [blobMeasurements.Perimeter];
        allBlobExtents = [blobMeasurements.Extent];
        
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
    avgDayBlobAreas(i) = mean(avgImageBlobAreas);
    avgDayBlobDiam(i) = mean(avgImageBlobDiam);
    
    %[avgBlobAreas] = (avgBlobAreas)./10;
    %[avgBlobDiam] = (avgBlobDiam)./10;
    [allBlobDiaMicro] = (allBlobDiameters)./10;
    [allBlobAreaMicro] = (allBlobAreas)./10;
    avgDia = mean(allBlobDiaMicro);
    avgArea = mean(allBlobAreaMicro);
    textFileName1 = 'Diameters.txt';
    textFileName2 = 'Areas.txt';
    fileID1 = fopen(textFileName1, 'w');
    fileID2 = fopen(textFileName2, 'w');
    fprintf(fileID1, 'Diameters from %s\n', tmp);
    fprintf(fileID2, 'Areas from %s\n', tmp);
    fprintf(fileID1, '%3.2f \n', allBlobDiaMicro);
    fprintf(fileID2, '%3.2f \n', allBlobAreaMicro);
    fprintf(fileID1, 'Average Diameter: %3.2f', avgDia);
    fprintf(fileID2, 'Average Area: %3.2f', avgArea);
    fclose(fileID1);
    fclose(fileID2);
    cd ..;
    cd ..;
    cd ..;
    cd ..;
    
end

avgDayBlobAreas = avgDayBlobAreas./10;
avgDayBlobDiam = avgDayBlobDiam./10;

%Plot data
figure(1)
scatter(0:4:16, avgDayBlobDiam,'b','Linewidth', 3);
grid on;
x = xlabel('Time (Days)');
y = ylabel('Average Day Lipid Droplet Diameters (Microns)');
t = title('Round 1 Design 5 Diameters');
set(t,'Fontweight','bold','Fontsize', 23);
set(x,'Fontweight','bold','Fontsize', 23);
set(y,'Fontweight','bold','Fontsize', 23);
set(gca,'Fontweight','bold','Fontsize',20);

figure(2)
scatter(0:4:16, avgDayBlobAreas,'b','Linewidth', 3);
grid on;
x = xlabel('Time (Days)');
y = ylabel('Average Day Lipid Droplet Area (Microns)');
t = title('Round 1 Design 5 Area');
set(t,'Fontweight','bold','Fontsize', 23);
set(x,'Fontweight','bold','Fontsize', 23);
set(y,'Fontweight','bold','Fontsize', 23);
set(gca,'Fontweight','bold','Fontsize',20);
%% Get stats
[tn,fn,fp,tp] = createconfusionmat(fname,BWcircles);