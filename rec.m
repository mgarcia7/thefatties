maxAxis = 100;
maxRadius = 2;
nCircles = 40;
% Random centers
xLoc = randi(maxAxis,nCircles);
yLoc = randi(maxAxis,nCircles);
% Random radii
radius = randi(maxRadius,nCircles);
% Transform the data into position = [left bottom width height]
pos = [xLoc(:)-radius(:) yLoc(:)-radius(:) 2*radius(:)*[1 1]];
% Create and format the axes
ha = axes;
hold on;
axis equal;
box on;
set(ha,'XTickLabel',[],'YTickLabel',[]);
% Create the circles
for idx = 1:nCircles
    rectangle(...
        'Position',pos(idx,:),...
        'Curvature',[1 1],...
        'FaceColor','k',...
        'EdgeColor','none');
end