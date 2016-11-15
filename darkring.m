function darkring()

fname = 'images/3D/3dsample1.jpg';
im_gray = process_image(fname);
[centers,radii] = getCircleCenters(im_gray);
bin_image = createCirclesMask(im_gray, centers,radii);
[labeled_im,num_objects2] = label_images(bin_image,im_gray);
[valid,num_objects1] = compare_image();
assignin('base','labeled_im',labeled_im);
assignin('base','bin_labeled_im',bin_image);

end

function im_gray = process_image(fname)
% Reads in sample, if it has three channels, takes only the first channel
im = imread(fname);
if size(im,3) == 3
    im = im(:, :, 2);
end
%%

% Converts image to a value btw 0 to 1
im_gray = double(im)/255; 

% Proportionally scales the image so that 0 = min val and 1 = max val
im_gray = imadjust(im_gray); 
end

function [centers,radii] = getCircleCenters(im_gray)
Rmin = 5;
Rmax = 30;

[centers, radii] = imfindcircles(im_gray,[Rmin Rmax],'ObjectPolarity','bright');

%{
imshow(im_gray)
hold on
viscircles(centersBright, radiiBright,'EdgeColor','g');
%}
end

function mask = createCirclesMask(varargin)
%xDim,yDim,centers,radii)
% Create a binary mask from circle centers and radii
%
% SYNTAX:
% mask = createCirclesMask([xDim,yDim],centers,radii);
% OR
% mask = createCirclesMask(I,centers,radii);
%
% INPUTS: 
% [XDIM, YDIM]   A 1x2 vector indicating the size of the desired
%                mask, as returned by [xDim,yDim,~] = size(img);
%  
% I              As an alternate to specifying the size of the mask 
%                (as above), you may specify an input image, I,  from which
%                size metrics are to be determined.
% 
% CENTERS        An m x 2 vector of [x, y] coordinates of circle centers
%
% RADII          An m x 1 vector of circle radii
%
% OUTPUTS:
% MASK           A logical mask of size [xDim,yDim], true where the circles
%                are indicated, false elsewhere.
%
%%% EXAMPLE 1:
%   img = imread('coins.png');
%   [centers,radii] = imfindcircles(img,[20 30],...
%      'Sensitivity',0.8500,...
%      'EdgeThreshold',0.30,...
%      'Method','PhaseCode',...
%      'ObjectPolarity','Bright');
%   figure
%   subplot(1,2,1);
%   imshow(img)
%   mask = createCirclesMask(img,centers,radii);
%   subplot(1,2,2);
%   imshow(mask)
%
%%% EXAMPLE 2:
%   % Note: Mask creation is the same as in Example 1, but the image is
%   % passed in, rather than the size of the image.
%
%   img = imread('coins.png');
%   [centers,radii] = imfindcircles(img,[20 30],...
%      'Sensitivity',0.8500,...
%      'EdgeThreshold',0.30,...
%      'Method','PhaseCode',...
%      'ObjectPolarity','Bright');
%   mask = createCirclesMask(size(img),centers,radii);
%
% See Also: imfindcircles, viscircles, CircleFinder
%
% Brett Shoelson, PhD
% 9/22/2014
% Comments, suggestions welcome: brett.shoelson@mathworks.com

% Copyright 2014 The MathWorks, Inc.

narginchk(3,3)
if numel(varargin{1}) == 2
	% SIZE specified
	xDim = varargin{1}(1);
	yDim = varargin{1}(2);
else
	% IMAGE specified
	[xDim,yDim] = size(varargin{1});
end
centers = varargin{2};
radii = varargin{3};
xc = centers(:,1);
yc = centers(:,2);
[xx,yy] = meshgrid(1:yDim,1:xDim);
mask = false(xDim,yDim);
for ii = 1:numel(radii)
	mask = mask | hypot(xx - xc(ii), yy - yc(ii)) <= radii(ii);
end

%image(mask)
%colormap([0,0,0;1,1,1])
end

function [labeled_im,num_of_objects] = compare_image()
    im_gray = process_image('images/3D/3dsample1_labeled.jpg');
    assignin('base','valid_im',im_gray);
    bin_image = im2bw(im_gray,0.95);
    Filled_Image = imfill(bin_image,'holes');
    bin_image = medfilt2(Filled_Image,[8 8]);
    [labeled_im,num_of_objects] = bwlabel(bin_image,8);

end

function [labeled_im, num_of_objects] = label_images(bin_image,im_gray)


%%
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

end