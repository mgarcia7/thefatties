close all
figure

 %X = rand(5,1);
 %Y = rand(5,1);
 %centers = [X Y];
 %radii = 0.1*rand(5,1);
    
 %viscircles(centers,radii);

 
 for i = 1:10
     pos = [(i+2), (i+3), 0.5, 0.5]; 
     rectangle('Position',pos,'Curvature',[1 1],'FaceColor','w')
 end
 axis equal
 set(gca,'Color',[0 0 0]);