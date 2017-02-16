close all

MYDIR = 'Data/Round1/Design2/Day12/';
fname = {'R1D2S1d12I2wi.tif', 'R1D2S3d12I1wi.tif', 'R1D2S3d12I2wi.tif', 'R1D2S2d12I2wi.tif', 'R1D2S1d12I1wi.tif'};

%im = imread(strcat(MYDIR,fname{3}));
im = comp;
%%
if size(im,3) == 3
    im = im(:, :, 1);
end

% Scales image intensity values & adjusts contrast of the image
im_gray = imadjust(im); 
im_gray = mat2gray(im_gray);

% Create binary image w/ calculated threshold
threshold = graythresh(im_gray);
bin_image = im2bw(im_gray,threshold*1.2);

% Fill the holes in image
Filled_Image=imfill(bin_image,'holes');

% Filters image to get rid of random specks
bin_image = medfilt2(bin_image,[8 8]);


figure
imshow(bin_image)

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
allowableArea = (allBlobAreas > 10) & (allBlobAreas < max(allBlobAreas));
allowableExtent = (allBlobExtents >= 0.50);
allowableCircularity = (allBlobCircularities >= 0.8); 
allowableSolidity = (allBlobSolidity > 0.5);

BWcircles = ismember(labeled_im, find(allowableArea & (allowableCircularity | allowableExtent) & allowableSolidity ));

%%
figure(5)
% Plots the blobs on top of the original image
imshow(im_gray)
hold on

boundaries = bwboundaries(BWcircles);
numberOfBoundaries = size(boundaries,1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end
hold off