clc
close all
%https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4442582/#SD1
% Reads in sample, if it has three channels, takes only the first channel
fname = 'images/3D/3dsample1.jpg';
im = imread(fname);
if size(im,3) == 3
    im = im(:, :, 1);
end

% Converts image to a value btw 0 to 1
im_gray = double(im)/255; 

% Proportionally scales the image so that 0 = min val and 1 = max val
im_gray = imadjust(im_gray); 

% Creating a binary image using threshold found above
threshold = graythresh(im_gray);
high_threshold = threshold * 1.70;
low_threshold = threshold * 0.85;
bin_image = im2bw(im_gray,low_threshold);

% Fill the holes in da image
Filled_Image=imfill(bin_image,'holes');
%BW2 = bwareaopen(Filled_Image,75);

% Filtering
bin_image = medfilt2(Filled_Image,[10 10]);
imshowpair(bin_image,im_gray)

% Labels the images
[labeled_im,num_of_objects]=bwlabel(bin_image,8);
%%

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
BWcircularity = ismember(labeled_im, find(allowableArea & allowableCircularity));
BWextent = ismember(labeled_im, find(allowableArea & allowableExtent));
imshowpair(BWcircularity,BWextent)

figure(2)
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