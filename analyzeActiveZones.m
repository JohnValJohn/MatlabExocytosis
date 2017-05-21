function analyzeActiveZones(pairedData)

%get number of row of pairedData
nr = height(pairedData);

%convert the table to matrix
pairedMatrix = [pairedData.charge, pairedData.ImaxPosition, ...
    pairedData.Imax, pairedData.tHalf, pairedData.sliceElectro, ...
    pairedData.xFluo, pairedData.yFluo, pairedData.sliceFluo];

%counters for number of peaks in active and not active zones
nActive = 0;
nNotActive=0;

%loop to separate the peaks into the ones inside active zones and the ones
%outside
for i = 1:nr
    %get x and y coordinates for current peak
    xPeak = pairedMatrix(i,6);
    yPeak = pairedMatrix(i,7);
    
    %create condition based on active zones delimitations (I defined the limits
    %myself). In ImageJ roi manager choose the 'specify' option to get the
    %coordinates.
    activeZone1 = xPeak>405.18 & xPeak<426.27 & yPeak>27.11 & yPeak<49.7;
    activeZone2 = xPeak>536.22 & xPeak<569.36 & yPeak>507.60 & yPeak<546.76;
    activeZone3 = xPeak>379.57 & xPeak<415.72 & yPeak>426.26 & yPeak<457.89;
    
    %separate peaks inside active zones and peaks outside
    if (activeZone1 | activeZone2 | activeZone3)
        nActive = nActive + 1;
        activeZoneMatrix(nActive,:) = pairedMatrix(i,:);
    else
        nNotActive = nNotActive + 1;
        notActiveZoneMatrix(nNotActive,:) = pairedMatrix(i,:);
    end
end

%Write tables and send them to base
activeZonePeaks = array2table(activeZoneMatrix, ...
    'VariableNames', {'charge', 'ImaxPosition', 'Imax', 'tHalf', 'sliceElectro', 'xFluo', 'yFluo', 'sliceFluo'});
assignin('base', 'activeZonePeaks', activeZonePeaks);

notActiveZonePeaks = array2table(notActiveZoneMatrix, ...
    'VariableNames', {'charge', 'ImaxPosition', 'Imax', 'tHalf', 'sliceElectro', 'xFluo', 'yFluo', 'sliceFluo'});
assignin('base', 'notActiveZonePeaks', notActiveZonePeaks);

%calculate average and standard deviation, then create a table and send it
%to base
%charge
avgActive(1,1) = mean(activeZoneMatrix(:,1));
avgActive(2,1) = std(activeZoneMatrix(:,1));

avgNotActive(1,1) = mean(notActiveZoneMatrix(:,1));
avgNotActive(2,1) = std(notActiveZoneMatrix(:,1));

%Imax
avgActive(1,2) = mean(activeZoneMatrix(:,3));
avgActive(2,2) = std(activeZoneMatrix(:,3));

avgNotActive(1,2) = mean(notActiveZoneMatrix(:,3));
avgNotActive(2,2) = std(notActiveZoneMatrix(:,3));

%tHalf
avgActive(1,3) = mean(activeZoneMatrix(:,4));
avgActive(2,3) = std(activeZoneMatrix(:,4));

avgNotActive(1,3) = mean(notActiveZoneMatrix(:,4));
avgNotActive(2,3) = std(notActiveZoneMatrix(:,4));

avgActiveZonesTable = array2table(avgActive, ...
    'VariableNames', {'charge',  'Imax', 'tHalf'});
assignin('base', 'avgActiveZonesTable', avgActiveZonesTable);

avgNotActiveZonesTable = array2table(avgNotActive, ...
    'VariableNames', {'charge',  'Imax', 'tHalf'});
assignin('base', 'avgNotActiveZonesTable', avgNotActiveZonesTable);

end