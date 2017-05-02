function [allBlobDiams] = attempt2(im)
% This function takes in a matrix representing an image, and returns the diameters of the lipid droplets

im_gray = imadjust(im); 
im_gray = mat2gray(im_gray);
 
% Create binary image with calculated threshold
threshold = graythresh(im_gray);
bin_image = im2bw(im_gray,threshold*1.2);
 
% Filters image to get rid of random specks
bin_image = medfilt2(bin_image,[8 8]);
 
% Labels the image
[labeled_im,num_of_objects]=bwlabel(bin_image,8);
 
% Gets the blob properties
blobMeasurements = regionprops(labeled_im,'all');
allBlobAreas = [blobMeasurements.Area];
allBlobPerimeters = [blobMeasurements.Perimeter];
allBlobExtents = [blobMeasurements.Extent];
allBlobSolidity = [blobMeasurements.Solidity];
allBlobCircularities = (4*3.14.*allBlobAreas)./(allBlobPerimeters.^2); % Isoperimetric inequality
 
% Decides what is permissible based on area, solidity, extent, and circularity
allowableArea = (allBlobAreas > 10) & (allBlobAreas < max(allBlobAreas));
allowableExtent = (allBlobExtents >= 0.50);
allowableCircularity = (allBlobCircularities >= 0.8); 
allowableSolidity = (allBlobSolidity > 0.5);
 
BWcircles = ismember(labeled_im, find(allowableArea & (allowableCircularity | allowableExtent) & allowableSolidity ));

% Filters out more false positives by looking at the intensity profiles of each blob across the diameter
measurements = regionprops(BWcircles,'all');
C = cat(1,measurements.Centroid);
rad = cat(1,measurements.MajorAxisLength)/2 + 7;
 
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

 
[labeled_im]=bwlabel(BWcircles,8);
blobMeasurements = regionprops(labeled_im,'MajorAxisLength','Area');
allBlobDiams = [blobMeasurements.MajorAxisLength];

end