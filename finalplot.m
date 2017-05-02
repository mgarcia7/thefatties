d = load('~/Google Drive/the fatties/Data/experimental_data_DeltaArea.mat');
experimental_data = d.experimental_data;
close all;
figure;

hold on

for d=1:numel(experimental_data)
    data = experimental_data{d};
    x1 = d*ones(1,numel(data{1}));
    x2 = d*ones(1,numel(data{2}));
    
%     err1 = std(data{1});
%     err1 = err1*ones(1,numel(data{1}));
%     err2 = std(data{2});
%     err2 = err2*ones(1,numel(data{2}));
    
    womean = mean(data{1});
    wmean = mean(data{2});
    
    plot(x1,data{1},'r.', 'markersize', 20);
    plot(x2,data{2},'b.', 'markersize', 20);
    
    
    hold on
    line([d-.1,d+.1],[womean,womean], 'Color', 'red','LineWidth', 4);
    line([d-.1,d+.1],[wmean,wmean], 'Color','blue','LineWidth', 4);

%     hold on
%     h1 = errorbar(x1, data{1}, err1);
%     set(h1,'linestyle','none')
%     hold on
%     h2 = errorbar(x2, data{2}, err2);
%     set(h2,'linestyle','none', 'Color', 'r')
end

title('Growth of Designs with and without Insulin','Fontsize',24)
xlabel('Designs','Fontsize',24)
ylabel('Area (Microns)','Fontsize',24)
set(gca, 'XTickLabel',{' ', 'A', 'B', 'C', 'D','E','F', 'G', 'H', ' '})
%A = 1
%B = 2
%C = 8
%D = 5
%E = 6
%F = 7
legend('Without Insulin','With Insulin')
set(gca,'Fontsize',24)

%% Statistical significance
H = [];
for d=experimental_data
    d = d{1};
    [~, p] = ttest2(d{1},d{2});
    H = [H p];
end