close all

% Reads in sample, if it has three channels, takes only the first channel
MYDIR = 'Data/Round1/Design2/Day12/';
fname = {'R1D2S1d12I2wi.tif', 'R1D2S3d12I1wi.tif', 'R1D2S3d12I2wi.tif', 'R1D2S2d12I2wi.tif', 'R1D2S1d12I1wi.tif'};

% Reads in sample, if it has three channels, takes only the first channel
im = imread(strcat(MYDIR,fname{1}));
if size(im,3) == 3
    im = im(:, :, 1);
end

% Scales image intensity values & adjusts contrast of the image
im_gray = imadjust(im); 
im_gray = mat2gray(im_gray);

im_gray = wiener2(im_gray,[5 5]);
imshow(im_gray)

%%

% Create binary image w/ calculated threshold
threshold = graythresh(im_gray);
bin_image = im2bw(im_gray,threshold);

% Fill the holes in image
Filled_Image=imfill(bin_image,'holes');

% Filtering
bin_image = medfilt2(bin_image,[8 8]);


figure
imshow(bin_image)
%%
% Labels the images
[labeled_im,num_of_objects]=bwlabel(bin_image,8);

% Gets the blob properties
blobMeasurements = regionprops(labeled_im,'all');
allBlobAreas = [blobMeasurements.Area];
allBlobPerimeters = [blobMeasurements.Perimeter];
allBlobExtents = [blobMeasurements.Extent];
allBlobSolidity = [blobMeasurements.Solidity];

allBlobCircularities = (4*3.14.*allBlobAreas)./(allBlobPerimeters.^2); % Isoperimetric inequality

% Logical vector that has 1 or 0 depending on whether it meets the
% threshold
allowableArea = (allBlobAreas > 10) & (allBlobAreas < max(allBlobAreas));
allowableExtent = (allBlobExtents >= 0.50);
allowableCircularity = (allBlobCircularities >= 0.8); 
allowableSolidity = (allBlobSolidity > 0.5);

% Extracts the circular ones!!
BWcircles = ismember(labeled_im, find(allowableArea & (allowableCircularity | allowableExtent) & allowableSolidity ));

%% INTENSITY PROFILES

measurements = regionprops(BWcircles,'all');
C = cat(1,measurements.Centroid);
rad = cat(1,measurements.MajorAxisLength)/2 + 7;

%imp = [];
allowableProfile = zeros(1,size(C,1));
for i = 1:size(C,1)
    xi = [C(i,1)-rad(i),C(i,1)+rad(i)];
    yi = [C(i,2)-rad(i),C(i,2)+rad(i)];
    c = improfile(im_gray,xi,yi,100);
    profile_gradient = gradient(c);
    
    [maxpks,maxloc] = findpeaks(profile_gradient,'MinPeakDistance',10,'SortStr','descend');
    [minpks,minloc] = findpeaks(-1*profile_gradient,'MinPeakDistance',10,'SortStr','descend');
    
    
    if maxpks(1) >= 0.12 && minpks(1) >= 0.12
        allowableProfile(i) = 1;
    end
    
end

BWcircles = ismember(bwlabel(BWcircles,8), find(allowableProfile));
%%

figure(5)
% Plots the blobs on top of the original image
imshow(im_gray)
hold on

boundaries = bwboundaries(NEWBWcircles);
numberOfBoundaries = size(boundaries,1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end
hold off