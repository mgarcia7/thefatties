function [totalLDcount] = getTotalAreaFOV(im)

% if TESTING
%     MYDIR = 'Data/Round1/Design2i/Day12/';
%     fname = {'R1D2S1d12I2wi.tif', 'R1D2S3d12I1wi.tif', 'R1D2S3d12I2wi.tif', 'R1D2S2d12I2wi.tif', 'R1D2S1d12I1wi.tif'};
%     im = imread(strcat(MYDIR,fname{1}));
% end

try
    nred = im(:,:,3);
    nred = imadjust(nred);

    LDcontent_threshold = graythresh(nred);
    LDcontent = im2bw(nred,LDcontent_threshold*0.4);

    totalLDcount = sum(sum(LDcontent));
catch
    totalLDcount = improf(im);
end

end
