% Loads all the collected data into a matrix where first column = ind of
% LD, and second column is the area
filepath = '~/Google Drive/the fatties/Data for Accuracy Plot/';
NP = load(fullfile(filepath,'Design1.txt'));

filepath2 = '~/Google Drive/the fatties/Selected Images for Confusion Matrix/Design 5/';
dia = importdata(fullfile(filepath2,'~R7d06-2017-0016-D5S1I1wi_diameters.mat'));

f = @(x) (x.*6.7)./10; % Function to convert pixels to microns
ind = NP(:,1); % These are the indices of the LDs that we calculated diameters for

algorithm_diameters = f(dia(ind)); % Algorithm found diameters for the specific LDs in microns
hand_diameters = f(NP(:,2)); % Hand calculated diameters for specific LDS in microns
R = corr2(algorithm_diameters,hand_diameters);

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

y = ylabel('Hand Measured Diameter (Microns)','Fontsize',30);
x = xlabel('Algorithm Measured Diameter (Microns)','Fontsize',30);
t = title('Accuracy of Algorithm on Tissue Model Image','Fontsize',30);
set(gca,'Fontweight','bold','Fontsize',25);