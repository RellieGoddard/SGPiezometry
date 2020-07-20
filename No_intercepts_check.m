%% No_intercepts_check 
% Rellie Goddard, July 2020

% This function checks the number of intercepts required to acurately capture the subgrain-size

% Required functions:
% *ProcessEBSD_fun.m
% *LinearIntercepts_fun.m

% Required user inputs:

% * pname: Path to data (e.g., 'C:/Users/admin/data/')
% * fname: File name with extension (e.g., 'W1066.ctf')
% * gb_min: Grain size, used for constructing maps.
% * sg_min: Subgrain size, used for constructing maps
% * cutoff: Minimum misorientation angle used to define a subgrain boundary.
%       If using recommended Goddard subgrain-size piezometer parameters,
%       set to 1.
% * CS: crystal symmetry. Phases have to be in the same order as the .cpr file. 
%       Can be added manually or CS information can be obtained through using the 
%       command 'import_wizard'. In inport_wizard choose the EBSD tab, click on the '+'
%       botton to upload the .ctf file of intrest. Navigate through until you finish, 
%       this will create an untitled script. Copy the '% crystal symmetry' section of
%       the script into the section below labeled '% crystal symmetry'. 
% * phase: Name of the phase of interest (e.g., 'olivine')
% * crystal: Crystal system of the phase to be examined (e.g., 'orthorhombic')
% * nx_max: The maximum number of intercepts that you want to test (recommended to start at either 30 or 40)
% * include_low: The choice of if you want to test very low number of intercepts (1-9). To include set to 1. Othewise, set to 0.
% * test: the choice to run a smaller area to speed up the analysis. Good for 
%       testing if the script works, not recommended for analysis. 
%       To run a smaller data set, set to 1. Othewise, set to 0
%
% Results: 
%   figures showing the line intercepts on top of EBSD data for each iteration, a figure showing the mean line intercept length against the No. of
%   intercepts, and a figure showing the change in mean line intercept length relative to last
%
% The test is successful if the measured mean line-intercept length stabilises (change in intercept length relative to last is < or = 2.5%). 
% If the mean line-intercept does not stabilise, increase nx_max and run again. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data import
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all 
clear all 

% Specify File Names

% USER INPUT: Enter file path 
% File location 
pname = 'yourPath\';

% USER INPUT: Enter .ctf file name (including the .ctf)

fname = [pname 'yourFileName.ctf'];

% USER INPUT: misorientation angles for SG and GS and cutoff for SG_piezometer
% For the Goddard 2020 subgrain piezometer set sg_min and cutoff to 1 degree. 

gb_min = [];
sg_min = [];
cutoff =  [];

% USER INPUT: Crystal symmetry 
CS =  {... 
  'notIndexed',...
  crystalSymmetry('mmm', [UnitCellLengths(?)], 'mineral', 'yourPhase', 'color', 'yourColor')};

% USER INPUT Phase, must match that in the CS file.
phase = 'yourPhase';

% USER INPUT: Crystal system 
crystal = 'yourCrystalSystem';


% USER INPUT: Max number of intercepts to try. Must be multiple of 10. Suggested starting value, 30 or 40
nx_max = [];

% USER INPUT: test 
% To run a smaller data set, set to 1. Othewise, set to 0
test = [];

% USER INPUT: to include analysis, set to 1. Otherwise, set to 0
include_low = []; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run test 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create an array to keep data in
if include_low
    X1 = [1:1:9]';
    X2 = 10.*[1:1:(nx_max/10)]';
    X = [X1;X2];
    X = X';
    Y = zeros([1,((nx_max/10) + 9)]);
else
    X = 10.*[1:1:(nx_max/10)];
    Y = zeros([1, nx_max/10]);
end


%%  Call on the ProcessEBSD function. This function will output [enter the maps which I want it to output]
[ebsd,grains,subgrains] = ProcessEBSD_fun(fname,gb_min,sg_min, CS, test, 0, 0);

if include_low
    for nx = 1:1:9
        ny = nx; 
        [lengths_x, lengths_y] = LinearIntercepts_fun(ebsd,nx,ny,cutoff,phase,crystal);
        d_h = lengths_x;
        d_v = lengths_x;
        d = [d_h;d_v];
        XY = sum(d)/length(d);
        Y(nx) = XY;

        
        
    end 

    for nx= 10:10:nx_max
        ny = nx;
        [lengths_x, lengths_y] = LinearIntercepts_fun(ebsd,nx,ny,cutoff,phase,crystal);
        d_h = lengths_x;
        d_v = lengths_x;
        d = [d_h;d_v];
        XY = sum(d)/length(d);
        nx = 9 + (nx/10)
        Y(nx) = XY;
    end 
else 

    for nx= 10:10:nx_max
        ny = nx;
        [lengths_x, lengths_y] = LinearIntercepts_fun(ebsd,nx,ny,cutoff,phase,crystal);
        d_h = lengths_x;
        d_v = lengths_x;
        d = [d_h;d_v];
        XY = sum(d)/length(d);
        nx = (nx/10)
        Y(nx) = XY;
    end 
end 
    

%% plot the figure 
    figure
    scatter(X,Y,40, 'filled', 'r');
    hold on 
    %Set axis limits 
    yl = ylim; % Get current limits.
    ylim([0, 2*yl(2)]);  
    set(0,'DefaultAxesFontSize',15,'DefaultAxesFontName','helvetica','DefaultAxesTickLength',[.03 .02],'DefaultAxesLineWidth',2);
    
    %Label the graph
    ylabel('Mean intercept length  (\mum)', 'FontSize', 15);
    xlabel('No. Intercepts ', 'FontSize', 15);
    box on 
    
    figure
    Y_change = zeros(1,(length(X)-1));
    for i = 2:1:(length(X))
        Y_change(i-1) = (abs(Y(i)-Y(i-1))/Y(i-1))*100;
    end 
    X_change = (X(2:length(X)));
    scatter(X_change,Y_change,40, 'filled', 'k');
    ylim([0, 5]);  
    %Set format 
    set(0,'DefaultAxesFontSize',15,'DefaultAxesFontName','helvetica','DefaultAxesTickLength',[.03 .02],'DefaultAxesLineWidth',2);
    %Label the graph
    ylabel('Change relative to previous (%)', 'FontSize', 15);
    xlabel('No. Intercepts ', 'FontSize', 15);
    box on 
    
