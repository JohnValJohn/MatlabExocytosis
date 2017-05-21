function PeakAnalysis(cell_peaks)

%create new cell array
peaks_subtracted = cell.empty;

%create empty matrices for results. Maybe I should preallocate it for speed
charge = [];
xMaxPosition = [];
yMaxPosition = [];
tHalf = [];

%find number of rows (and columns) in cell_peaks array
[nr, ~]=size(cell_peaks);

%loop over all the rows in peaks cell_array
for i = 1:nr
    
    %get peak data and store in variables xValues and yValues
    xValues = cell_peaks{i,1};
    yValues = cell_peaks{i,2};
    
    %find size of xValues
    length_x = length(xValues);
    
    %get y-minimun on the first quarter of the peak.
    %get its corresponding x-value
    quarter1 = round(length_x/4);
    [y1, y1Index] = min(yValues(1:quarter1));
    x1 = xValues(y1Index);
    
    %get y-minimum on the last quarter of the peak
    quarter3 = round(length_x*3/4);
    [y2, y2Index] = min(yValues(quarter3:length_x));
    
    %y2Index is not the value I want because it counts from the beginning of
    %the interval, not the beginning of the vector
    %get correct value for y2Index
    y2Index = y2Index + quarter3 - 1;
    
    %get corresponding x value
    x2 = xValues(y2Index);
    
    %calculate baseline as ax + b
    a = (y2 - y1)/(x2 - x1);
    b = y1 - (a*x1);
    
    %subtract the baseline from the y-values and store in new variable
    new_yValues = yValues - (a*xValues + b);
    
    %offset to get have the bottom of the peak at 0
    new_yValues = new_yValues - new_yValues(y1Index);
    
    %get rid of data outside the 2 minima
    xValues = xValues(y1Index:y2Index);
    new_yValues = new_yValues(y1Index:y2Index);
    
    %Send new peak data to peaks_subtracted
    peaks_subtracted{i,1} = xValues;
    peaks_subtracted{i,2} = new_yValues;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Calculate the integral. 
    %note: since my spacing is constant I might be able to speed up the process
    %by passing the spacing instead of the xvalues
    charge(i,1) = trapz(xValues, new_yValues);
    
    %find y maxima. Find x corresponding value.
    [ymax, max1Index] = max(new_yValues);
    xmax = xValues(max1Index);
    xMaxPosition(i,1) = xmax;
    yMaxPosition(i,1) = ymax;
    
    %calculate t1/2
    %calculate t1/2: search for value closest to max/2, on first part of the
    %peak
    [~, indexAtMin1] = min(abs(new_yValues(1:max1Index) - (ymax/2)));
    
    %calculate t1/2: search for value closest to max/2, on second part of the
    %peak
    [~, indexAtMin2] = min(abs(new_yValues(max1Index:end) - (ymax/2)));
    
    %indexAtMin2 is offset by a value of max1Index. I need to correct for that
    indexAtMin2 = indexAtMin2 + max1Index -1;
    
    %calculate t1/2: Final calculation and storage in 4th column of results
    tHalf(i,1) = xValues(indexAtMin2) - xValues(indexAtMin1);
    
    
end

%send new peaks to base
assignin('base', 'peaks_subtracted', peaks_subtracted);


%Calculate average and standard deviation. 
average_charge(1,1) = mean(charge);
average_charge(2,1) = std(charge);

average_yMaxPosition(1,1) = mean(yMaxPosition);
average_yMaxPosition(2,1) = std(yMaxPosition);

average_tHalf(1,1) = mean(tHalf);
average_tHalf(2,1) = std(tHalf);

%create tables for the results and the averages. Send them to base.
resultTable = table(charge, xMaxPosition, yMaxPosition, tHalf,...
    'VariableNames', {'charge', 'ImaxPosition', 'Imax', 'tHalf'});
assignin('base', 'resultTable', resultTable);

averageTable = table(average_charge, average_yMaxPosition, average_tHalf, ...
    'VariableNames', {'Charge', 'Imax', 'thalf'});
assignin('base', 'averageTable', averageTable);


% xtHalf(1) = xValues(indexAtMin1);
% xtHalf(2) = xValues(indexAtMin2);
% ytHalf(1) = new_yValues(indexAtMin1);
% ytHalf(2) = new_yValues(indexAtMin2);
% 
% disp(num2str(indexAtMin1));


% fig = figure();
% %plot(peaks_subtracted{1,1}, peaks_subtracted{1,2});
% plot(xValues, new_yValues);
% hold on;
% plot(xtHalf,ytHalf);
%plot(xValues(max1Index:end), new_yValues(max1Index:end));

%var1 =new_yValues(max1Index:end) - (ymax/2);
%assignin('base', 'var', var1)

% disp(num2str(indexAtMin2));
% disp(num2str(y1));
% disp(num2str(y2));
% disp(num2str(y1Index));
% disp(num2str(y2Index));
% disp(num2str(x1));
% disp(num2str(x2));

end