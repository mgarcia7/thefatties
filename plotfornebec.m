round9 = d{9};
round6 = d{6};

D2wi = round9{2,2};
D2wo = round9{1,2};

D8wi = round9{2,8};
D8wo = round9{1,8};

D1wi = round9{2,1};
D1wo = round9{1,1};

%D6wi = round6{2,6};
D6wo = round6{1,6};

f = figure;
hold on

plot(D1wi(:,1),D1wi(:,2), '-*', 'LineWidth', 6)
plot(D2wi(:,1),D2wi(:,2), '-*', 'LineWidth', 6)
plot(D8wi(:,1),D8wi(:,2), '-*', 'LineWidth', 6)
plot(D6wi(:,1),D6wi(:,2), '-*', 'LineWidth', 6)

title('Lipid Accumulation for Design B and Design C')
xlabel('Day')
ylabel('Total LD Area of FOV (micron^{2})')

axis([0 18 0 7*10^5])

set(findall(f,'-property','FontSize', '-property', 'FontWeight'),'FontSize',25, 'FontWeight', 'bold')
set(gca, 'FontSize',20)
legend('Design A','Design B', 'Design C', 'Design E', 'Location','northwest', 'FontSize', 20)
set(gca, 'Color', 'none');


