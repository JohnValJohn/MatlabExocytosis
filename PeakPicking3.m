function PeakPicking3(xData, yData)
%Counter for peaks
numPeak=0;
%create an empty cell array to store the peak (each cell can contain a
%matrix)
peaks = cell.empty;

%creating the figure to plot peaks and giving it a handle. I am creating it
%first, like that fig1 will be in focus at the beginning for the user.
fig2 = figure('Name', 'peak plot');
fig2Handle = fig2;

%creating the figure where I will plot, and giving it a handle.
fig1 = figure('KeyPressFcn', @key1Press,...
    'Name', 'Main plot');
fig1Handle = fig1;

%Make fig1 the current figure and plot.
figure(fig1Handle);
plot(xData, yData);

%button to select the peaks
button1 = uicontrol('Parent', fig1, 'Style', 'pushbutton',...
    'Callback', @button1Callback, ...
    'String', 'Select Peaks', 'Position', [20 5 120 20]);

%button to send peaks to base
button2 = uicontrol('Parent', fig1, 'Style', 'pushbutton',...
    'Callback', @button2Callback, ...
    'String', 'Peaks to Matlab', 'Position', [150 5 120 20]);

%button to export peaks to text file to be latter analyzed by another
%program
button3 = uicontrol('Parent', fig1, 'Style', 'pushbutton',...
    'Callback', @button3Callback, ...
    'String', 'Peaks to txt', 'Position', [280 5 120 20]);


%this function allows the user to select a peak and asks for confirmation
    function button1Callback(~,~)
        
        %ginput(2) to store coordinates of data point when we click on the mouse.
        %It does it twice
        [xInterval, ~] = ginput(2);
        
        %creates a logical with 1s for the points we want and 0s everywhere else
        logic1 = xData>xInterval(1) & xData<xInterval(2);
        
        %Make fig2 the current figure
        figure(fig2Handle);
        
        %plot the data
        % We use logic1 to get the indices of the data we are interested in
        plot(xData(logic1), yData(logic1));
        
        %asks user for confirmation. Arguments:(question, title, string1, string2,
        %default)
        confirmPeak = questdlg('Keep Peak?',...
            'Keep Peak?','Yes', 'No', 'Yes');
        %select what to do depending on answer
        switch confirmPeak
            case 'Yes'
                numPeak = numPeak + 1;
                % We use logic1 to get the indices of the data we are interested in
                peaks{numPeak,1}=xData(logic1);
                peaks{numPeak,2}=yData(logic1);
            case 'No'
                
                %do nothing
        end
        
        %Send the focus back to fig1
        figure(fig1Handle);
        disp(num2str(numPeak));
    end

% this part is to get a shortcut to execute button1Callback. I do not
% understand it very well, just took it from stackoverflow and it works.
    function key1Press(~,event)
        switch event.Key
            case 'a'
                button1Callback(button1, [])
        end
        
    end

    function button2Callback(~,~)
        %Send the peaks to base working space
        assignin('base', 'peaks', peaks);
    end

    function button3Callback(~,~)
        %find number of rows (and columns) in peaks array
        [nr, ~]=size(peaks);
        
        %get name of the folder where we want to save the file
            folderName = uigetdir;
        
        %loop over all the rows in peaks array
        for i = 1:nr
            
            %create a matrix to hold peak data and assign the first column
            %to this matrix. Hopefully this will also overwrite all data on
            %subsequent passages of the loop.
            mat = peaks{i,1};
            
            %Translate the time data so it starts at 0
            mat = mat - mat(1);
            
            %add the second column of data to the matrix
            mat = [mat peaks{i,2}];
            
            %Create name for the file
            fileName = fullfile(folderName, ['peak' num2str(i) '.txt']);
            
            %export the matrix as tab delimited text file, with newline that
            %can be read by a pc
            dlmwrite(fileName, mat, 'delimiter','\t', 'newline','pc');
            
            %In case you want to send it to matlab workspace
            %assignin('base', 'mat', mat);
            
        end %end for loop
    end
end