%% Plot index numbers on top of the original image

% im = the tif image
% BWcircles = the binary image

[nLabel,num] = bwlabel(BWcircles,8);

s = regionprops(nLabel, 'Area', 'Centroid', 'MajorAxisLength');
dia = cat(1,s.MajorAxisLength);

imshow(im)
hold on

boundaries = bwboundaries(BWcircles);
numberOfBoundaries = size(boundaries,1);
for k = 1 : numberOfBoundaries
    thisBoundary = boundaries{k};
    plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end

for k = C
   centroid = s(k).Centroid;
   text(centroid(1), centroid(2), sprintf('%d', k), 'Color', 'm');
end


hold off
%% Get the R coefficient ~

<<<<<<< HEAD:ts.m
%%
%filepath = '/Users/mbolick/Google Drive/the fatties/Data for Accuracy Plot/';
=======
% Loads all the collected data into a matrix where first column = ind of
% LD, and second column is the area
filepath = '~/Google Drive/the fatties/Data for Accuracy Plot/';
>>>>>>> origin/master:GetDiameters.m
NM = load(fullfile(filepath,'Melissa.txt'));
NT = load(fullfile(filepath,'Tyler LD measure.txt'));
NS = load(fullfile(filepath,'LDdata87-173.txt'));
NMA = load(fullfile(filepath,'marge.txt'));
NP = [NM; NT; NS; NMA];

f = @(x) (x.*6.7)./10; % Function to convert pixels to microns
ind = NP(:,1); % These are the indices of the LDs that we calculated diameters for

algorithm_diameters = f(dia(ind)); % Algorithm found diameters for the specific LDs in microns
hand_diameters = f(NP(:,2)); % Hand calculated diameters for specific LDS in microns
R = corr2(algorithm_diameters,hand_diameters);

%% You can ignore this!
figure;
ind = NP(:,1);
plot(f(dia(ind)),f(NP(:,2)), 'o', 'Linewidth', 6)

hold on 

FIT = polyfit(f(dia(ind)),f(NP(:,2)), 1);
realtrend = plot(f(dia(ind)),f(polyval(FIT,dia(ind))), 'Linewidth', 6);

eq = sprintf('y = %.3f x + %.3f',FIT(1),FIT(2));
corref = sprintf('Correlation coefficient = %.3f', corr2(dia(ind),NP(:,2)));

text(13,7,eq, 'Fontweight', 'bold', 'Fontsize',30)
text(13,5, corref, 'Fontweight', 'bold', 'Fontsize',30)

y = ylabel('Hand Measured Diameter (Microns)');
x = xlabel('Algorithm Measured Diameter (Microns)');
t = title('Accuracy of Algorithm on Tissue Model Image');
set(gca,'Fontweight','bold','Fontsize',25);








