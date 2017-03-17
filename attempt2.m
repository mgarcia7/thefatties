close all;

im = imread('newidealimage2.jpg');
[rows, cols, channels] = size(im);
if channels >1
    im = im(:, :, 2);
end
%%
% Converts image to a value btw 0 to 1
im_gray = double(im)/255;

% Proportionally scales the image so that 0 = min val and 1 = max val
im_gray = imadjust(im_gray);
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
bin_image = medfilt2(Filled_Image,[5 5]);

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
allBlobDiameters = [blobMeasurements.EquivDiameter];


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

fid=fopen('idealimageanalyzed.txt','wt');
fprintf(fid,'%d\n',allBlobDiameters);
fclose(fid);
