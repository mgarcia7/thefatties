clc
close all

fname = 'images/3D/3dsample1.jpg';
im = imread(fname);
if size(im,3) == 3
    im = im(:, :, 1);
end

im_gray = double(im)/255; % not sure what this step does, but like everyone does it so?
im_gray = imadjust(im_gray); %adjust contrast of an image, we can play around w values
%imhist(im_gray)

% Pick an appropriate threshold value -- find a better way to do this
[pixelCounts, grayLevels] = imhist(im_gray);

pval = 0.1;
totalsum = sum(pixelCounts);
numelements = numel(pixelCounts);
currentsum = 0;
dk = [];
for i = numelements:-1:1
    currentsum = currentsum + pixelCounts(i);
    dk = [dk currentsum/totalsum];
    if currentsum/totalsum >= pval
        break
    end
    
end

disp(grayLevels(i))

% Creating binary image
threshold = grayLevels(i);
bin_image = im2bw(im_gray,threshold);

% Fill the holes
Filled_Image=imfill(bin_image,'holes');
%BW2 = bwareaopen(Filled_Image,75);

% Decide which filter
h = fspecial('disk',10);
imshowpair(im_gray,medfilt2(Filled_Image,[10 10]),'montage');
%imshow(medfilt2(bin_image,[20 20]));
%imshowpair(imfilter(bin_image,h,'replicate'),medfilt2(bin_image,[15 15]),'montage')
bin_image = medfilt2(Filled_Image,[15 15]);

%%
% Connected Component Labeling
[labeled_im,num_of_objects]=bwlabel(bin_image,8);
imshow(labeled_im)

%%

RGB_labeled_im=label2rgb(labeled_im); % i think it just makes it pretty???
figure(4);
%imshow(RGB_labeled_im); title('Labeled Image');
imshow(bin_image)
hold on
blobMeasurements = regionprops(labeled_im,im_gray,'all');
numberOfBlobs = size(blobMeasurements,1);

boundaries = bwboundaries(bin_image);
numberOfBoundaries = size(boundaries,1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end
hold off
%%
allBlobAreas = [blobMeasurements.Area];
allBlobExtents = [blobMeasurements.Extent];

allowableExtent = allBlobExtents >= 0.79;

BWcircles = ismember(bin_image, find(allowableExtent));
labeled_circles = logical(BWcircles);

imshowpair(bin_image,BWcircles)