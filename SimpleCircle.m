close all
figure

 X = rand(5,1);
 Y = rand(5,1);
 centers = [X Y];
 radii = 0.1*rand(5,1);
    
 viscircles(centers,radii,'Color','black');
