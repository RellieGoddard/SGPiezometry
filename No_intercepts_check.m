%% No_intercepts_check 
% Rellie M. Goddard, July 2020

% This function checks the number of intercepts required to acurately capture the subgrain-size

% Required functions:
% *ProcessEBSD_fun.m
% *LinearIntercepts_fun.m

% Required user inputs:
% * nx_max: The maximum number of intercepts that you want to test (recommended to start at either 30 or 40)
% * gb_min: Minimum misorientation angle to define a grain boundary in 
%       degrees. Used for constructing maps
% * sg_min: Minimum misorientation angle to define a subgrain boundary in 
%       degrees. Only used for constructing maps.
% * cutoff: Minimum misorientation angle to define a subgrain boundary in
%       degrees. Used for piezometer calculations. Recommended value is 1.
% * phase: Name of the phase of interest (e.g., 'Forsterite')
% * crystal: Crystal system of the phase to be examined (e.g., 'orthorhombic')
% * test: When set to 1, reduces the size of the input EBSD map by taking
%       every tenth pixel in both the horizontal and vertical direction. Can be 
%       utilized to ensure the script runs correctly for a new sample file or for
%       troubleshooting. During full analysis, test should be set to 0.
% * include_low: The choice of if you want to test very low number of intercepts (1-9). To include set to 1. Othewise, set to 0.
%
%% Additional user inputs produced by MTEX
% * CS: Crystal symmetry class variable for all indexed phases in EBSD map.
% * pname: Path to data (e.g., 'C:/Users/admin/data/')
% * fname: File name combined with path
% 
% Results: 
%   Figures showing the line intercepts on top of EBSD data for each iteration, a figure showing the mean line intercept length against the no. of
%   intercepts, and a figure showing the change in mean line intercept length relative to last
%
% The test is successful if the measured mean line-intercept length stabilises (change in intercept length relative to last is < or = 2.5%). 
% If the mean line-intercept does not stabilise, increase nx_max and run again. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data import
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close, clear all 

% USER INPUT: Data inport information from MTEX
% This information is produced automatically by the MTEX import wizard 
% Paste in your CS, plotting conventions, pname, and fname here. 

% Specify Crystal and Specimen Symmetries 
% crystal symmetry
CS =  {};
% plotting convention
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');

% Specify File Names 
% path to file 
pname = 'yourPath';
% which file to be imported  
fname = [pname 'yourFileName.ctf'];

%% USER INPUT: Required information 
nx_max = []; % Max number of intercepts to try. Must be multiple of 10. Suggested starting value, 30 or 40
gb_min = []; % Minimum misorientation for grain boundary (for figures)
sg_min = []; % Minimum misorientation for subgrain boundary (for figures)
cutoff = []; % Minimum misorientation for subgrain boundary (for calculation)
phase = 'yourPhase'; % Phase to measure. Must match a phase present in CS.
crystal = 'yourCrystalSystem'; % Crystal system of phase to measure. 
test = 0; % Set to 1 to speed up analysis when troubleshooting. 
include_low = 0; to include analysis, set to 1. Otherwise, set to 0

%% END OF USER INPUTS 

%% Calculate and plot

if include_low % create an array to keep data in
    X1 = [1:1:9]';
    X2 = 10.*[1:1:(nx_max/10)]';
    X = [X1;X2];
    X = X';
    Y = zeros([1,((nx_max/10) + 9)]);
else
    X = 10.*[1:1:(nx_max/10)];
    Y = zeros([1, nx_max/10]);
end


%  Call on the ProcessEBSD function. 
[ebsd,grains,subgrains] = ProcessEBSD_fun(fname,gb_min,sg_min, CS, test, 0, 0);

if include_low
    for nx = 1:1:9
        ny = nx; 
        [lengths_x, lengths_y] = LinearIntercepts_fun(ebsd,nx,ny,cutoff,phase,crystal);
        d_h = lengths_x;
        d_v = lengths_y;
        d = [d_h;d_v];
        XY = sum(d)/length(d);
        Y(nx) = XY;

        
        
    end 

    for nx= 10:10:nx_max
        ny = nx;
        [lengths_x, lengths_y] = LinearIntercepts_fun(ebsd,nx,ny,cutoff,phase,crystal);
        d_h = lengths_x;
        d_v = lengths_y;
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
        d_v = lengths_y;
        d = [d_h;d_v];
        XY = sum(d)/length(d);
        nx = (nx/10)
        Y(nx) = XY;
    end 
end 
    

% Plot figure 
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
    %Set format 
    set(0,'DefaultAxesFontSize',15,'DefaultAxesFontName','helvetica','DefaultAxesTickLength',[.03 .02],'DefaultAxesLineWidth',2);
    %Label the graph
    ylabel('Change relative to previous (%)', 'FontSize', 15);
    xlabel('No. Intercepts ', 'FontSize', 15);
    box on 
    
