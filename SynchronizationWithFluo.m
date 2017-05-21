%resultsElectro  and resultFluo must be of "table" type
%resultsElectro must have the peaks in order (earlier peaks need to be
%earlier in the table)

%Careful: If 2 electro peaks are calculated to be on the same frame, the pairing
%algorithm will always choose the first one. If 2 fluo frames can be paired
%with 2 electroPeaks, the 1st fluo will go with the 1st electro, even if
%they are all on the same frame.

function SynchronizationWithFluo(resultsElectro, resultsFluo)

%find number or rows in resultsElectro
nr = height(resultsElectro);

%find number of rows in resultsFluo
nr2 = height(resultsFluo);

%convert the tables to matrices that are easier to work with (and probably
%faster)
electroMatrix = [resultsElectro.charge, resultsElectro.ImaxPosition, resultsElectro.Imax, resultsElectro.tHalf];
fluoMatrix = [resultsFluo.XM, resultsFluo.YM, resultsFluo.Slice];

%loop through electroMatrix
for i = 1:nr
    
    %get xvalue for imax and calculate on which frame it is expected
    %I have determined that frame 2 is at 158517 ms and each frame is
    %separated by 80.7784 ms (except between frames 1 and 2).
    %store results in 5th column
    electroMatrix(i,5) = round((((electroMatrix(i,2)*1000 - 158517)/80.7784)+2)); %+2 because my ref is frame 2
    
    
end

%Now to pair the peaks.
%sort the fluo matrix by frame number (column 3);
fluoMatrix=sortrows(fluoMatrix,3);

%duplicate the electrochemistry data 'cause I will delete part of it to
%make sure I do not count a peak twice.
electroMatrix2 = electroMatrix;

%counter for number of paired events
pairedCounter = 0;

%%%%%%%%%%%%%%%%%% pairing %%%%%%%%%%%%%%%%%%%%%
%Loop through fluo data
for i = 1:nr2
    % find which electrochemistry peak is closer
    min1 = min(electroMatrix2(:,5)-fluoMatrix(i,3));
    
    %this is to make sure we are not taking into account lone
    %electrochemistry peaks. If an electrochemistry peak arrives before the
    %fluo peak we are currently looping, it is deleted.
    while (min1 <0)
        electroMatrix2(1, :) = [];
        min1 = min(electroMatrix2(:,5)-fluoMatrix(i,3));
    end

    %find which fluo peak to the right of the current one is closer to it
    min2 = min(fluoMatrix((i+1):end,3)-fluoMatrix(i,3));
    
    %Now pair the data if close enough and no other fluo peak closer
    if (min1<=2 & min2>min1)
        %increment the counter
        pairedCounter = pairedCounter + 1;
        
        %find row of electrochemistry data
        %find the slide number
        slideElectro = fluoMatrix(i,3) + min1;
        %find the row
        rowElectro = electroMatrix2(:,5) == slideElectro; % gets all indices of matching value
        rowElectro = rowElectro(1,1); %keep only the first index (row of first matching peak)
        
        %get data in new matrix
        pairedData(pairedCounter, :) = [electroMatrix2(rowElectro, :), fluoMatrix(i, :)]; % [] to concatenate
       
        %remove peak from electroMatrix2
        electroMatrix2(rowElectro, :) = [];
        
    end    
    
end


%Now we want to plot fluo and electro data on same graph. We will use stem
%graphs

%Create a vector full of 1s that has the same size as the number of
%electro events
electroOnes = ones(nr);

%create a new figure and plot fluo data (based on frame number)
figure;
stem(electroMatrix(:,5), electroOnes);

%make sure you can add data to previous graph
hold on;

%Create a vector full of 1s that has the same size as the number of
%fluo events
fluoOnes = ones(nr2);

%Plot electro data
stem(fluoMatrix(:,3), fluoOnes, 'color', 'blue');

% Transform paired data to table and send to base
pairedDataTable = array2table(pairedData, ...
   'VariableNames', {'charge', 'ImaxPosition', 'Imax', 'tHalf', 'sliceElectro', 'xFluo', 'yFluo', 'sliceFluo'});
assignin('base', 'pairedData', pairedDataTable);

%Send electropeaks with slide number to base
resultsElectro = array2table(electroMatrix, ...
    'VariableNames', {'charge', 'ImaxPosition', 'Imax', 'tHalf', 'sliceElectro'});
assignin('base', 'resultsElectro', resultsElectro);


end