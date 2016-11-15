% code from this paper
% http://online.liebertpub.com/doi/pdf/10.1089/ten.tec.2009.0755
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4442582/

clc
close all

fname = 'images/sample4.jpg';
im_RGB=imread(fname);
im_gray=rgb2gray(im_RGB);

im_gray=double(im_gray);
im_gray=im_gray/255;
im_gray=wiener2(im_gray);

figure(1);
imshow(im_gray); title('Grayscale Image');

% Thresholding
threshold=0.44;
Binary_Image=im2bw(im_gray,threshold);
figure(2);
imshow(Binary_Image); title('Binary Image');

%%

% Region Filling
Filled_Image=imfill(Binary_Image,'holes');
figure(3);
imshow(Filled_Image);title('Binary Filled Image');

% Connected Component Labeling
[labeled_im,num_of_objects]=bwlabel(Filled_Image,4);

RGB_labeled_im=label2rgb(labeled_im);
figure(4);
imshow(RGB_labeled_im); title('Labeled Image');


% Area Calculations
area=zeros(1,num_of_objects);
for i=1:length(labeled_im(:))
    if labeled_im(i) ~= 0
        object_serial_num=labeled_im(i);
        area(object_serial_num)=area(object_serial_num)+1;
    end
end

% Labeling each object with its Area (in Pixels)
labeled_im_area=labeled_im;
for i=1:length(labeled_im(:))
    
    if labeled_im(i)~=0
        object_serial_num=labeled_im(i);
        labeled_im_area(i)=area(object_serial_num);
    end
end

% Deleting the Connected Components with Area <5 Pixels
labeled_im_area(labeled_im_area==1)=0;
labeled_im_area(labeled_im_area==2)=0;
labeled_im_area(labeled_im_area==3)=0;
labeled_im_area(labeled_im_area==4)=0;
labeled_im(labeled_im_area==0)=0;

figure(5);
imshow(labeled_im_area); title('Area');
%pixval;

% Back to Area Calculations
total_area=sum(area);

image_area=length(im_gray(:));
area_ratio=total_area/image_area;

