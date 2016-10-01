close all
%https://www.mathworks.com/help/images/image-enhancement-and-analysis.html
%https://www.mathworks.com/help/images/ref/strel-class.html

I = imread('Images/sample.jpg');
imshow(I)

%Getting the small lipid droplets
background = imopen(I, strel('disk',6));

figure
surf(double(background(1:8:end, 1:8:end))), zlim([0 255]);
set(gca,'ydir','reverse');

I2 = I - background;
imshow(I2)

I3 = imadjust(I2);
imshow(I3);

level = graythresh(I3);
bw = im2bw(I3,level);
bw = bwareaopen(bw,50);
imshow(bw)

%Getting the medium lipid droplets
background1 = imopen(I, strel('disk',10));

figure
surf(double(background1(1:8:end, 1:8:end))), zlim([0 255]);
set(gca,'ydir','reverse');

I4 = I - background1;
imshow(I4)

I5 = imadjust(I4);
imshow(I5);

level = graythresh(I5);
bw2 = im2bw(I5,level);
bw2 = bwareaopen(bw2,50);
imshow(bw2)

figure
imshowpair(bw,bw2,'Scaling','none');
