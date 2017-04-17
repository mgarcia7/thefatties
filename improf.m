function [allBlobAreas] = improf(im)
TESTING = false;

% if TESTING
%     MYDIR = 'Data/Round1/Design2i/Day12/';
%     fname = {'R1D2S1d12I2wi.tif', 'R1D2S3d12I1wi.tif', 'R1D2S3d12I2wi.tif', 'R1D2S2d12I2wi.tif', 'R1D2S1d12I1wi.tif'};
%     im = imread(strcat(MYDIR,fname{1}));
% end

dim = size(im);
if numel(dim) == 3
    nred = im(:,:,3);
    nred = imadjust(nred);
    im = im(:, :, 1);
    
    LDcontent_threshold = graythresh(nred);
    LDcontent = im2bw(nred,LDcontent_threshold*0.4);
else
   LDcontent = im2bw(im,0); 
end

% % imshow(LDcontent)

% 3 = nile red (LD)
% 1 = phase
% 2 = DAPI (nucleus)
% Scales image intensity values & adjusts contrast of the image
im_gray = imadjust(im); 
im_gray = mat2gray(im_gray);

% Create binary image w/ calculated threshold
threshold = graythresh(im_gray);
bin_image = im2bw(im_gray,threshold);

% Filters image to get rid of random specks
bin_image = medfilt2(bin_image,[8 8]);

bin_image(~LDcontent) = 0;

% Fill the holes in image
bin_image =imfill(bin_image,'holes');

% if TESTING
%     figure
%     imshow(bin_image)
% end

%%
% Labels the image
[labeled_im,num_of_objects]=bwlabel(bin_image,8);

% Gets the blob properties
blobMeasurements = regionprops(labeled_im,'all');
allBlobAreas = [blobMeasurements.Area];
allBlobPerimeters = [blobMeasurements.Perimeter];
allBlobExtents = [blobMeasurements.Extent];
allBlobSolidity = [blobMeasurements.Solidity];
allBlobCircularities = (4*3.14.*allBlobAreas)./(allBlobPerimeters.^2); % Isoperimetric inequality

% Decides what is permissible based on various criteria
allowableArea = (allBlobAreas > 10) & (allBlobAreas < 100);
allowableExtent = (allBlobExtents >= 0.50);
allowableCircularity = (allBlobCircularities >= 0.8); 
allowableSolidity = (allBlobSolidity > 0.5);

BWcircles = ismember(labeled_im, find(allowableArea & (allowableCircularity | allowableExtent) & allowableSolidity ));

if TESTING
    h = figure(5);
    % Plots the blobs on top of the original image
    [nLabel,num] = bwlabel(BWcircles,8);

    labeled_im = imread('/Users/melissagarcia/Google Drive/the fatties/Selected Images for Confusion Matrix/Design 8/LABELED_R7d06-2017-0005_D8S2I1wi.tif');

    imshow(im_gray)
    hold on

    boundaries = bwboundaries(BWcircles);
    numberOfBoundaries = size(boundaries,1);
    vals = [510, 109, 162, 448, 418];
    for k = vals
        thisBoundary = boundaries{k};
        plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
    end
    
    [nLabel,num] = bwlabel(BWcircles,8);

    s = regionprops(nLabel, 'Area', 'Centroid', 'MajorAxisLength');
    diameters = cat(1,s.MajorAxisLength);

    for k = vals
       centroid = s(k).Centroid;
       text(centroid(1), centroid(2), sprintf('%d', k), 'Color', 'm');
    end


    hold off
    
else
    [labeled_im]=bwlabel(BWcircles,8);
    blobMeasurements = regionprops(labeled_im,'MajorAxisLength','Area');
    allBlobDiams = [blobMeasurements.MajorAxisLength];
    allBlobAreas = sum([blobMeasurements.Area]);
end

end