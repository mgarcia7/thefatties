d = load('~/Google Drive/the fatties/Data/experimental_data_DeltaAreaPercentages.mat');
experimental_data = d.experimental_data;

figure;

hold on

mat2add = [];
num2pad = 12;
for d=1:numel(experimental_data)
    data = experimental_data{d};
    x1 = d*ones(1,numel(data{1}));
    x2 = d*ones(1,numel(data{2}));
    

    plot(x1,data{1},'r.', 'markersize', 20);
    plot(x2,data{2},'b.', 'markersize', 20);
end

csvwrite('~/Desktop/total_data.csv',mat2add)

%% Statistical significance
H = [];
for d=experimental_data
    d = d{1};
    [~, p] = ttest2(d{1},d{2});
    H = [H p];
end