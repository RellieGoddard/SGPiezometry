%% ProcessEBSD_LinearIntercepts - measures mean line intercept length
% Rellie Goddard, July 2020

% This function measures the mean line intercept length and offers the option of providing a equivalent stress from the Goddard et al. 2020 subgrain-size piezometer 

% Required functions:
% *ProcessEBSD_fun.m
% *LinearIntercepts_fun.m

%% Required user inputs:
% * nx: The number of intercept lines, chosen based on analysis from 
%       No_intercepts_check.m.
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
% * test: the choice to run a smaller area to speed up the analysis. Good for 
%       testing if the script works, not recommended for analysis. 
%       To run a smaller data set, set to 1. Othewise, set to 0
% * Phase_map: To output a phase map, set to 1. Othewise, set to 0.
% * Band_contrast: To output a band contrast map, set to 1. Otherwise, set
%       to 0.
% * Check_different_misorientation: To measure the mean line intercept length for a range of minimum misorientation angles, set to 1.
%       Otherwise set to 0. 
% * SG_piezometer: To calculate equivalent stress straight from measured subgrain size, set to 1. Otherwise set to 0. 
% * Peizometer_choice: If SG_piezometer == 1, Piezometer_choice enables the choice between the subgrain-size piezometers with, and without the 
%        Holyoke and Kronenberg (2010) friction correct. 
% 
% Results: 
%       If input Check_different_misorientation = [1], a plot of mean line intercept length (y-axis) 
%       plotted against the defined critical misorientation angle (x-axis). A sample which contains subrgains will show 
%       smaller mean line intercept lengths for critical misorientation angles of < 5° than at 10°. 
%       A figure of the intercept analysis and a histogram of the line intercept lengths including the calculated arithmetic mean. 
%       Optional outputs included a band contrast map and a phase map if inputs Band_contrast and Phase_map both = [1].  
%       If SG_piezometer = 1, a stress calculated from one of the Goddard et al., 2020 subgrain-size piezometer will also be outputted. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data import
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify File Names

% USER INPUT: Enter file path 
% File location 
close all 
clear all 

pname = 'yourPath\';

% USER INPUT: Enter .ctf file name (including the .ctf)
fname = [pname 'yourFileName'];


%% Define the parameters 

% USER INPUT: misorientation angles for SG and GS and cutoff for SG_piezometer
% For the Goddard 2020 subgrain piezometer set sg_min and cutoff to 1 degree. 

gb_min = [];
sg_min = [];
cutoff = []; 


% USER INPUT: Crystal symmetry 
CS =  {... 
  'notIndexed',...
  crystalSymmetry('mmm', [UnitCellLengths(?)], 'mineral', 'yourPhase', 'color', 'yourColor')};

% USER INPUT Phase, must match that in the CS file.

phase = 'yourPhase';

% USER INPUT: Crystal system 
crystal = 'yourCrystalSystem';

%USER INPUT: Number of intercepts
nx = [];
ny = nx;

% USER INPUT: test 
% To run a smaller data set, set to 1. Othewise, set to 0
test = [];

% USER INPUT: figure outputs 
% To output either a phase map or a band contrast map, set to 1. Othewise, set to 0
Phase_map = [];
Band_contrast = [];


% USER INPUT: To run minimum misorientations used to define a subgrain size boundary from 1 to 10 degrees, set to 1. Otherwise, set to 0
Check_different_misorientation =  [];


% USER INPUT: Use pre-chosen shear Moduli and Burgers vector to calulate
% stress
% if user wishes to use the same shear moduli and Burgers vector as in the 
% Subgrain-size piezometer paper then SG_piezometer = [1] will output a stress. 

SG_piezometer =[];

% USER INPUT: 
% If SG_piezometer = 1, choose which piezometer to use. If using Equation
% 1, which includes the Holyoke and Kronenberg (2010) calibration then
% Piezometer_choice = 1. If using Equation 2, which doesn't have the
% Holyoke and Kronenberg (2010) calibration then Piezometer_choice = 2. 
Peizometer_choice = []; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run analysis 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create empty arrays to store data within 

Mis_orientation = [];
Subgrain_mis_ori = [];
Lengths_X_1 =[];
Lengths_Y_1 =[];

% Call on the ProcessEBSD function. 
[ebsd,grains,subgrains] = ProcessEBSD_fun(fname,gb_min,sg_min, CS, test, Phase_map, Band_contrast);


%% Linear intercept analysis 

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




%% plotting a historgam of each area 
%number of bins
figure
bin=15;

d_h = Lengths_X_1;
d_v = Lengths_Y_1;
d = [d_h;d_v];

%calculate the arithmetic mean 
a_mean_RG = sum(d)/length(d);

% Plot linear scale histogram
hist(d,15);

xlabel('Linear Intercept Length (\mum)')
ylabel('Probability')
title(['arithmetic mean = ' num2str(round(a_mean_RG, 2)) ' \mum'])
box on 


% Getting a stress from your the piezometer
if SG_piezometer == 1
[Equivalent_stress] = Stress_Calulation_fun(phase,Peizometer_choice,a_mean_RG);

% Print Von Mises Equilivant_Stress 
disp(Equivalent_stress)
end 


    
