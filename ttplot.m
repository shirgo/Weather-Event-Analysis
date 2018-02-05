function ttplot(tt)
%TTPLOT Plot data from a timetable.
%   TTPLOT(TT) creates a stacked line plot of the numeric variables in the
%   timetable TT. Any non-numeric variables in TT are ignored.
%
%   A stacked line plot shows each numeric variable with its own vertical
%   axis, all aligned horizontally to the same time axis.
%
%   TTPLOT(T) creates a stacked line plot of the numeric variables in the table
%   T, using the first datetime or duration variable as the time variable. Any
%   other non-numeric variables in T are ignored.
%
%   Examples:
%      Plot the numeric variables in a timetable:
%         tt = array2timetable(randn(25,5),'VariableNames',{'V' 'W' 'X' 'Y' 'Z'}, ...
%                  'RowTimes',datetime(2016,8,1:25))
%         ttplot(tt)
%
%      Plot the numeric variables in a timetable, all overlayed on the same
%      vertical axis:
%         plot(tt.Time, tt{:,vartype('numeric')},'-')
%         legend(tt.Properties.VariableNames)
%
%      Plot the numeric variables in a table against a time variable:
%         t = array2table(randn(25,5),'VariableNames',{'V' 'W' 'X' 'Y' 'Z'})
%         t.Time = datetime(2016,8,1:25)'
%         ttplot(t);
%
%   See also TIMETABLE, TABLE, PLOT.

if verLessThan('matlab', '8.4.0') % datetime/duration introduced in R2014b
    error('Requires MATLAB R2014b or later.');
end

if isa(tt,'timetable')
    time = tt.Properties.RowTimes;
elseif isa(tt,'table')
    % Take the time vector as the first datetime/duration variable in the table.
    rowtimesCandidates = varfun(@(x)isdatetime(x) || isduration(x),tt,'OutputFormat','uniform');
    rowtimesIndex = find(rowtimesCandidates,1);
    if isempty(rowtimesIndex)
        error('Input table must contain datetime or duration vector for row times.');
    end
    time = tt.(rowtimesIndex);
end

varnames = tt.Properties.VariableNames;
which = find(varfun(@isnumeric,tt,'Output','uniform'));

subplot(111);
nplots = length(which);
for j = 1:nplots
    var_j = tt.(which(j));
    ax(j) = subplot(nplots,1,j); %#ok<*AGROW>
    plot(time,var_j,'-');
    ax(j).YTickLabel = {};
    ylabel(varnames{j});
    ax(j).YLabel.Rotation = 0;
    ax(j).YLabel.HorizontalAlignment = 'right';
    ax(j).YLabel.VerticalAlignment = 'middle';
    if j < which(end)
        ax(j).XTickMode = 'manual';
        ax(j).XTickLabel = {};
    end
end

% Resize each subplot to almost touch the one above.
posn = cell2mat(get(ax,'Position'));
posn(:,4) = posn(1,2) - posn(2,2);
set(ax,{'Position'},num2cell(posn,2));

subplot(111);
