%This code will read in the images from the folder
contents = dir('Round1');
for k = 1:(numel(contents)-3)
    jpgFilename = sprintf('R1A%d.jpg', k);
    fullFileName = fullfile('Round1', jpgFilename);
    if exist(fullFileName, 'file')
        im = imread(fullFileName);
        if size(im,3) == 3
            im = im(:,:,2);
        end
        sprintf(jpgFilename)
        im_gray = double(im)/255;
        
        % Proportionally scales the image so that 0 = min val and 1 = max val
        im_gray = imadjust(im_gray);
        
        % Increase the difference between the dark outer ring and the lipid droplet
        threshold = graythresh(im_gray)*0.75;
        im_gray(im_gray <= threshold) = 0;
        %imshow(im_gray)
        
        %% Get the circles + create binary image
        Rmin = 5;
        Rmax = 30;
        
        [centers, radii] = imfindcircles(im_gray,[Rmin Rmax],'ObjectPolarity','bright');
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
        
        figure
        % Plots the blobs on top of the original image
        imshow(im_gray)
        hold on
        numberOfBlobs = size(find(allowableExtent),2);
        
        boundaries = bwboundaries(BWcircles);
        numberOfBoundaries = size(boundaries,1);
        for k = 1 : numberOfBoundaries
            thisBoundary = boundaries{k};
            plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
        end
        hold off
    else
        warningMessage = sprintf('Warning: image file does not exist:\n%s', fullFileName);
        uiwait(warndlg(warningMessage));
    end
end

%% Get stats
%[tn,fn,fp,tp] = createconfusionmat(fname,BWcircles);
