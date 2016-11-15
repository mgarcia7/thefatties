fname = 'images/3D/3dsample1.jpg';

fname = strtok(fname,'.');
mat_fname = strcat(fname,'_labeled.mat');
labeled_fname = strcat(fname,'_labeled.jpg');

% if exist(mat_fname,'file')
%     load(mat_fname,'-mat', 'valid_labels');
% else
    % Reads in sample, if it has three channels, takes only the first channel
    im = imread(labeled_fname);
    if size(im,3) == 3
        im = im(:, :, 2);
    end
    
    % Converts image to a value btw 0 to 1
    im_gray = double(im)/255;
    
    % Proportionally scales the image so that 0 = min val and 1 = max val
    im_gray = imadjust(im_gray);
    
    bin_image = im2bw(im_gray,0.95);
    valid_labels = bwlabel(bin_image,8);                                                                                                                                                                                                                                                
    save(mat_fname,'valid_labels');
% end

fp = logical(~bin_image & bin_labeled_im);
fn = logical(bin_image & ~bin_labeled_im);
tp = logical(bin_image & bin_labeled_im);
tn = logical(~bin_image & ~bin_labeled_im);

close all;

size_of_im = numel(fp);
fp_count = numel(fp(fp==1));
fn_count = numel(fn(fn==1));
tp_count = numel(tp(tp==1));
tn_count = numel(tn(tn==1));

sum =fp_count + fn_count + tp_count + tn_count;

fprintf('False Positive: %f \n',fp_count * 100); 
fprintf('False Negative: %f \n',fn_count * 100);
fprintf('True Positive: %f \n',tp_count * 100);
fprintf('True Negative: %f \n',tn_count * 100);