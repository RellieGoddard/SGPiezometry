%% Undersampling_Step_size - tests if the spatial resolution is high enough 
% Rellie Goddard, July 2019
% Required functions:
% *ProcessEBSD_fun.m
% *LinearIntercepts_fun.m
% *Undersampling.fun.m

% Required user inputs:
%       nx, Int_max, direname, sample_name, Title, header_size,  gb_min,
%       sg_min, cutoff, phase, crystal, test, Phase_map, Band_contrast
%           nx: no. of line intercepts, chosen based on analysis from No_intercepts_check.m.
%           Int_max: the number of times you want to reduce the step-size. The step-size at an iteration will be Int_max multiplied by the original step-size. 
%           direname: equivalent to  pname
%           sample_name: equivalent to fname but without the .ctf.
%           Title: Title for figure 
%           Header_size: Number of lines, up to and including the line starting with ‘phase’ in the .ctf file (open in Notepad)
%           gb_min & sg_min: grain size and subgrain size, used for constructing maps
%           cutoff: minimum misorientation angle used to define a subgrain boundary, if using Goddard subgrain-size piezometer cuttoff = 1. 
%           phase: the phase you want to measure subgrains in 
%           crystal: crystal system on the phase in question
%           Phase_map: to output a phase map = 1 if not = 0
%           Band_contrast: to output a band contrast map = 1 if not = 0 
%
%       Outputs: Figure showing the Intercept variation factor plotted
%       against the number of pixels per intercept. See Goddard et al., 2020
%       for an explanation of the variables. 
%
%
% The test is successful if the measured mean intercept length is not sensitive to the effective step size. 
% The presence of an asymptote at an intercept variation factor of 1 is evidence that step size is small enough to capture the mean intercept length. 
% If such an asymptote doesn't exist then either re-map the sample, using a smaller step size, or use the 
% subgrain-size stress measurement as a lower bound.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data import
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all 
clear all 

%USER INPUT: Number of intercepts
nx = [];
ny = nx;

%USER INPUT: Maximum times of reducing the step-size 
Int_max = []; 

%File Location 
dirname = 'yourPath';

% USER INPUT: Enter .ctf file name (excluding the .ctf)
sample_name = 'yourFileName';

% USER INPUT: Title for graph
Title = 'yourTitle';

%% Define the parameters 

% USER INPUT: Header size of the original head file. Open text file. 
header_size = []; 

% USER INPUT: misorientation angles for SG and GS and cutoff for
% SG_piezometer
% For the Goddard 2020 subgrain piezometer set sg_min and cutoff to 1 degree. 

gb_min = [];
sg_min = [];
cutoff = []; 

% USER INPUT Phase, must match that in the CS file.

phase = 'yourPhase';

% USER INPUT: Crystal system 

%  Common crystal systems 
% 'Quartz = trigonal'   'Calcite = trigonal'    
% 'Enstatite  Opx AV77 = orthorhombic'  'Forsterite = orthorhombic'

crystal = 'yourCrystalSystem';
% test, if you want to do a smaller data set to test the code 1 = YES, 0 =
% NO

test = [];

% Following figures will be created if 1 and not if 0
Phase_map = [];
Band_contrast = [];

Input_CTF = [dirname sample_name '.ctf'];
A = importdata(Input_CTF);
[fname_new, stepx_all, Step_size_SG_size] = undersampling_fun(Int_max, dirname, sample_name, header_size,gb_min,sg_min,test, Phase_map, Band_contrast, nx, ny, cutoff, phase, crystal);

close all 

figure 
    plot(Step_size_SG_size(1)./stepx_all, Step_size_SG_size/Step_size_SG_size(1),'-o', 'LineWidth', 3, 'color', [0.49 0.34 0.75], 'MarkerSize', 7);
    set(0,'DefaultAxesFontSize',15,'DefaultAxesFontName','helvetica','DefaultAxesTickLength',[.03 .02],'DefaultAxesLineWidth',2);
    set(gca,'fontsize',15);
    ylabel('Intercept variation factor ,\bf\lambda\rm/\bf\lambda\rm_b_e_s_t', 'FontSize',15);
    xlabel('Pixels per intercept, \bf\lambda\rm_b_e_s_t/step size', 'FontSize', 15);
    title(Title, 'FontSize', 15)
