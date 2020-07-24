%% ProcessEBSD_LinearIntercepts - measures mean line intercept length
% Rellie M. Goddard, July 

% This function measures the mean line intercept length and offers the option of providing a 
% equivalent stress from the Goddard et al. (submitted) subgrain-size piezometer 

% Required functions:
% *ProcessEBSD_fun.m
% *LinearIntercepts_fun.m

%% Required user inputs:
% * nx: The number of intercept lines, chosen based on analysis from 
%       No_intercepts_check.m.
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
% * Phase_map: To output a phase map, set to 1. Othewise, set to 0.
% * Band_contrast: To output a band contrast map, set to 1. Otherwise, set
%       to 0
% * Check_different_misorientation: To measure the mean line intercept length for minimum misorientation angle between 1 and 10 degrees, set to 1.
%       Otherwise set to 0. 
% * SG_piezometer: To calculate equivalent stress straight from measured subgrain size, set to 1. Otherwise set to 0. 
% * Piezometer_choice: If SG_piezometer == 1, Piezometer_choice enables the choice between the subgrain-size piezometers with, and without the 
%        Holyoke and Kronenberg (2010) friction correct.
% * Burgers: Burgers vector of phase of interest 
% * Shear_M: shear modulus of the phase of interest 
% 
%% Additional user inputs produced by MTEX
% * CS: Crystal symmetry class variable for all indexed phaes in EBSD map.
% * pname: Path to data (e.g., 'C:/Users/admin/data/')
% * fname: File name  combined with path
% 
% Results: 
%       If input Check_different_misorientation = [1], a plot of mean line intercept length (y-axis) 
%       plotted against the defined critical misorientation angle (x-axis). A sample which contains subrgains will show 
%       smaller mean line intercept lengths for critical misorientation angles of < 5° than at 10°. 
%       A figure of the intercept analysis and a histogram of the line intercept lengths including the calculated arithmetic mean. 
%       Optional outputs included a band contrast map and a phase map if inputs Band_contrast and Phase_map both = [1].  
%       If SG_piezometer = 1, a stress calculated from one of the Goddard et al., (submitted) subgrain-size piezometer will also be outputted. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data import
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close, clear all 
% Specify File Names

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


% USER INPUT: Required information 

nx = []; % Number of intercept lines 
gb_min = []; % Minimum misorientation for grain boundary (for figures)
sg_min = []; % Minimum misorientation for subgrain boundary (for figures)
cutoff = []; % Minimum misorientation for subgrain boundary (for calculation)
phase = 'yourPhase'; % Phase to measure. Must match a phase present in CS.
crystal = 'yourCrystalSystem'; % Crystal system of phase to measure. 
Phase_map = 0; % Set to 1 to plot a phase map of the EBSD data. 
Band_contrast = 0; % Set to 1 to plot a band contrast map.
test = 0; % Set to 1 to speed up analysis when troubleshooting. 
Check_different_misorientation =  0; % To run minimum misorientations used to define a 
                                     % subgrain size boundary from 1 to 10 degrees, set to 1. Otherwise, set to 0
SG_piezometer =[]; % if user wishes to use the same shear moduli and Burgers vector as in the subgrain-size piezometer paper then SG_piezometer = [1] will output a stress. 
Piezometer_choice = []; % If value = 1, piezometric equation will be eq. 1 from Goddard et al. (submitted). If value = 2, piezometric equation will be eq. 2 from Goddard et al. (submitted)
Burgers = []; % Burgers vector of phase of interest 
Shear_M = []; % Shear modulus of phase of interest 


%% END OF USER INPUTS 


%% Create empty arrays to store data within 
%% Programmatically calculate other necessary variables 
ny = nx; % Set number of intercepts in y-direction to equal number of intercepts in the x-direction.

%% Create empty arrays to store data
Mis_orientation = [];
Subgrain_mis_ori = [];
Lengths_X_1 =[];
Lengths_Y_1 =[];


%% Calculate and plot 
[ebsd,grains,subgrains] = ProcessEBSD_fun(fname,gb_min,sg_min, CS, test, Phase_map, Band_contrast);

% Linear intercept analysis 

if Check_different_misorientation == 1
    for cutoff = 1:1:10
      Mis_orientation = [Mis_orientation, cutoff];
      [Mean_Lengths_X,Mean_Lengths_Y, lengths_x, lengths_y] = LinearIntercepts_fun(ebsd,nx,ny,cutoff,phase,crystal);
      store = [];
      store = [lengths_x;lengths_y];
      Subgrain_mis_ori = [Subgrain_mis_ori, (sum(store)/length(store))];
      if cutoff == 1
          Lengths_X_1 = [Lengths_X_1, lengths_x];
          Lengths_Y_1 = [Lengths_Y_1, lengths_y];
      end 
    end

    % Add a line of best fit 
    MA = 0;
    SG = 0;
    for a = 1:10
        MA(end+1) = Mis_orientation(a);
        SG(end+1) = Subgrain_mis_ori(a);
    end 

    figure
    scatter(Mis_orientation,Subgrain_mis_ori,50, 'filled', 'black');
    hold on

    % Specify the limits of the axis 
    xlim([0 10]);
    hold on 
    ylim_old = max(Subgrain_mis_ori);
    hold on 
    ylim = ([0 2*ylim_old]);
    hold on 
    
    % Add labels
    xlabel('Minimum misorientation angle ({\circ})')
    ylabel('\it\lambda\it (\mum)')
    hold on 
    box on 
     
    % Adding a smooth line
    Z = smooth(MA,SG, 'sgolay');
    plot(MA, Z, 'black','LineWidth',2);
    box on 

elseif Check_different_misorientation == 0 
    cutoff = 1
    [Mean_Lengths_X,Mean_Lengths_Y, lengths_x, lengths_y] = LinearIntercepts_fun(ebsd,nx,ny,cutoff,phase,crystal);
    Lengths_X_1 = [Lengths_X_1, lengths_x];
    Lengths_Y_1 = [Lengths_Y_1, lengths_y];
end 



% Plot histogram of line intercepts 
% Number of bins
figure
bin=15;

d_h = Lengths_X_1;
d_v = Lengths_Y_1;
d = [d_h;d_v];

% Calculate the arithmetic mean 
a_mean_RG = sum(d)/length(d);

% Plot linear scale histogram
hist(d,15);

xlabel('Linear Intercept Length (\mum)')
ylabel('Probability')
title(['arithmetic mean = ' num2str(round(a_mean_RG, 2)) ' \mum'])
box on 


% Getting a stress from your the piezometer
if SG_piezometer == 1
[Equivalent_stress] = Stress_Calulation_fun(phase,Piezometer_choice,a_mean_RG);

% Print Von Mises Equilivant_Stress 
disp(Equivalent_stress)
end 


    
