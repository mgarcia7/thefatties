%
%Plotting hand measured vs. program collected data
close all;
handlabeled = [ 89 64 35 35 88 28 64 39 27 35 36 77 63 63];
allBlobDiameters = [26.3664   32.9942   36.8757   36.8757   36.8757...
    36.8757   52.1502   61.9376   61.9479 62.5513   62.5513   74.7546...
    88.4825   88.4825];

%Sorted the diameters
sortedh = sort(handlabeled);
sortedabd = sort(allBlobDiameters);
x1 = 0:1:90;
y1 = 0:1:90;

%Correlation Coefficient
Coeff = corr2(sortedabd,sortedh);

%Plot data in new figure
figure
rawdata = scatter(sortedabd, sortedh,'b','Linewidth', 3);
hold on;
handle1 = line(x1,y1,'Color','k','LineWidth',3);
hold on;
trendline = polyfit(sortedabd,sortedh,1);
Y2 = polyval(trendline,x1);
ptrend = plot(x1,Y2,'r','Linewidth', 3);
hold off;
a = trendline(1);
b = trendline(2);
polyfit_str = ['y = ' num2str(a) ' *x + ' num2str(b)];
txt = text(55,20, polyfit_str);
coeff_str = ['Correlation Coefficient = ' num2str(Coeff)];
txt2 = text(50,15, coeff_str);

%Settings to graph
y = ylabel('Hand Measured Diameter (Microns)');
x = xlabel('Algorithm Measured Diameter (Microns)');
t = title('Hand Measured vs. Algorithm Measured Diameter');
set(txt,'Fontweight','bold','Fontsize', 20);
set(txt2,'Fontweight','bold','Fontsize', 20);
set(handle1,'DisplayName', 'Ideal Trend Line');
set(rawdata,'DisplayName', 'Raw Data Points');
set(ptrend,'DisplayName', 'Actual Trend Line');
set(t,'Fontweight','bold','Fontsize', 23);
set(x,'Fontweight','bold','Fontsize', 23);
set(y,'Fontweight','bold','Fontsize', 23);
set(gca,'Fontweight','bold','Fontsize',20);
axis([0 90 0 90]);
legend('show')