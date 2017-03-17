[nLabel,num] = bwlabel(BWcircles,8);

s = regionprops(nLabel, 'Area', 'Centroid', 'MajorAxisLength');
areas = cat(1,s.Area);
[sortedareas,sortorder] = sort(areas,'descend');
s2 = s(sortorder);

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

%%
%filepath = '/Users/mbolick/Google Drive/the fatties/Data for Accuracy Plot/';
NM = load(fullfile(filepath,'Melissa.txt'));
NT = load(fullfile(filepath,'Tyler LD measure.txt'));
NS = load(fullfile(filepath,'LDdata87-173.txt'));
NMA = load(fullfile(filepath,'marge.txt'));
NP = [NM; NT; NS; NMA];

f = @(x) (x.*6.7)./10;

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








