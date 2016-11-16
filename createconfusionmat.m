function [tn,fn,fp,tp] = createconfusionmat(fname, predicted_bin_image)
fname = strtok(fname,'.');
mat_fname = strcat(fname,'_labeled.mat');
labeled_fname = strcat(fname,'_labeled.jpg');

if exist(mat_fname,'file')
    load(mat_fname,'-mat', 'actual_bin_image');
else
    % Reads in sample, if it has three channels, takes only the first channel
    im = imread(labeled_fname);
    if size(im,3) == 3
        im = im(:, :, 2);
    end
    
    % Converts image to a value btw 0 to 1
    im_gray = double(im)/255;
    
    % Proportionally scales the image so that 0 = min val and 1 = max val
    im_gray = imadjust(im_gray);
    
    actual_bin_image = im2bw(im_gray,0.95);
    save(mat_fname,'actual_bin_image');
end

predicted_bin_image = logical(predicted_bin_image);
actual_bin_image = logical(actual_bin_image);

confusionMatrix = zeros(2); % Initialize
[row,col] = size(predicted_bin_image);
for n = 1 : col
    for m = 1 : row
        % Find the row and column that these classes
        % will have in the confusion matrix.
        r = predicted_bin_image(m, n) + 1; %predicted
        c = actual_bin_image(m, n) + 1; %actual
        confusionMatrix(r, c) = confusionMatrix(r, c) + 1;
    end
end

%confusionMatrix = confusionMatrix/numel(actual_bin_image);
tn = confusionMatrix(1,1);
tp = confusionMatrix(2,2);
fn = confusionMatrix(1,2);
fp = confusionMatrix(2,1);

fprintf('\t \t    Actual \n')
fprintf('                  BG        Cell \n')
fprintf('Predicted  BG   %d   %d \n', tn,fn)
fprintf('           Cell %d   %d \n', fp,tp)

total = numel(actual_bin_image);
accuracy = (tp+tn)/total;
misclassification = (fp+fn)/total;
trueposrate = tp/(fn+tp); % sensitivity
falseposrate = fp/(tn+fp);
specificity = tn/(tn+fp);
precision = tp/(fp+tp);

poslikelihood = trueposrate/(1-specificity); 
neglikelihood = (1-trueposrate)/specificity;

fprintf('\nAccuracy = %5.5f (how often is classifier correct?) \n', accuracy)
fprintf('Misclassification rate = %5.5f (how often is it wrong) \n', misclassification)
fprintf('Positive likelihood = %5.5f (when it is actually yes, what is the likelihood that it will predict yes?) \n', poslikelihood)
fprintf('False positive rate = %5.5f (when it is no, how often does it predict yes?) \n', falseposrate)
fprintf('Negative likelihood = %5.5f (when it is actually no, how often does it predict yes?) \n', neglikelihood)
fprintf('Precision = %5.5f (when it predicts yes, how often is it correct) \n', precision)


%figure;
%imshowpair(actual_bin_image,predicted_bin_image)
end
