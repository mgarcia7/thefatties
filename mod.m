clc
close all
%https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4442582/#SD1
% Reads in sample, if it has three channels, takes only the first channel
fname = 'images/3D/3dsample4.jpg';
im = imread(fname);
if size(im,3) == 3
    im = im(:, :, 1);
end

% Converts image to a value btw 0 to 1
im_gray = double(im)/255; 

% Proportionally scales the image so that 0 = min val and 1 = max val
im_gray = imadjust(im_gray); 
%%
% Finds an appropriate threshold value by assuming that the lipid cell is
% <= 10% of the whole image
% TODO: Figure out a better way to get a threshold value b/c dis does not
% work lol
% [pixelCounts, grayLevels] = imhist(im_gray);
% 
% pval = 0.1;
% totalsum = sum(pixelCounts);
% numelements = numel(pixelCounts);
% currentsum = 0;
% dk = [];
% for i = numelements:-1:1
%     currentsum = currentsum + pixelCounts(i);
%     dk = [dk currentsum/totalsum];
%     if currentsum/totalsum >= pval
%         break
%     end
%     
% end


%disp(grayLevels(i))

% Creating a binary image using threshold found above
threshold = multithresh(im_gray);
bin_image = im2bw(im_gray,threshold+.15);

% Fill the holes in da image
Filled_Image=imfill(bin_image,'holes');
%BW2 = bwareaopen(Filled_Image,75);

% Filtering
% TODO: decide which filter and disk size, maybe try to find it
% programmatically
h = fspecial('disk',10);
%imshowpair(im_gray,medfilt2(Filled_Image,[5 5]),'montage');
%imshow(medfilt2(bin_image,[20 20]));
%imshowpair(imfilter(Filled_Image,h,'replicate'),medfilt2(Filled_Image,[10 10]))
bin_image = medfilt2(Filled_Image,[8 8]);

%%
% Labels the images
[labeled_im,num_of_objects]=bwlabel(bin_image,8);

% Gets the blob properties
blobMeasurements = regionprops(labeled_im,'all');
allBlobAreas = [blobMeasurements.Area];
allBlobExtents = [blobMeasurements.Extent];

% Logical vector that has 1 or 0 depending on whether it meets the
% threshold
allowableExtent = (allBlobExtents >= 0.52);

% Extracts the circular ones!!
% TODO: Improve on this? Maybe use circularity instead of extent? Maybe
% eccentricity??
BWcircles = ismember(labeled_im, find(allowableExtent));

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