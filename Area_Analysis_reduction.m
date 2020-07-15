%% Area_Analysis_reduction - map size test
% Rellie Goddard, July 2019
% Required functions:
% *ProcessEBSD_fun.m
% *LinearIntercepts_fun.m
% Required user inputs:
%       pname, fname, gb_min, sg_min, cutoff, phase, crystal, nx, test, Phase_map, Band_contrast
%           pname & fname: file path and file name, including .ctf
%           gb_min & sg_min: grain size and subgrain size, used for constructing maps
%           cutoff: minimum misorientation angle used to define a subgrain boundary, if using Goddard subgrain-size piezometer cuttoff = 1. 
%           phase: the phase you want to measure subgrains in 
%           crystal: crystal system on the phase in question
%           nx: no. of line intercepts, chosen based on analysis from No_intercepts_check.m.
%           test: choice to run a smaller area to speed up the script. Good for testing if the script works, not recommended for analysis        
%           Phase_map: to output a phase map = 1 if not = 0
%           Band_contrast: to output a band contrast map = 1 if not = 0 

% OUTPUTs 
%   An EBSD map for each analysis is outputted with a red box outlining the analysed subarea. 
%   A figure showing the intercept analysis of the final subarea. 
%   A figure showing the mean line intercept length plotted against the area as a percentage of the original map. 
%   On the right axis of the same figure the % change of the mean line intercepts length relative to the full map is plotted against map area. 
% 

% The test is successful if, as the size of the sub-area increases, the mean intercept length asymptotically approaches the mean for the entire map.  
% For all the samples included in the subgrain-size piezometer, the % change in mean line intercept length relative to the full map was ? 5% for a 20% reduction in map area. 
% If the mean line intercept length changes significantly with the reduced map size more maps or larger maps are required to accurately capture the subgrain size. 


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


%% Define the parameters 

% USER INPUT: misorientation angles for SG and GS and cutoff for SG_piezometer
% For the Goddard 2019 subgrain piezometer set sg_min and cutoff to 1 degree. 

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

%USER INPUT: Number of intercepts
nx = [];
ny = nx;


% USER INPUT: Test a smaller dataset, Yes = 1, No = 0
test = [];

% USER INPUT: Figures to be created, Yes = 1, No = 0
Phase_map = [];
Band_contrast = [];


% Creat an array to store the mean line intercept lengths in
Mean_SG_size_area = zeros(1,10); 


% Call on the ProcessEBSD function. This function will output [enter the maps which I want it to output]
[ebsd,grains,subgrains] = ProcessEBSD_fun(fname,gb_min,sg_min, phase, test, Phase_map, Band_contrast);

%% Reduce the area used to mean mean line intercepts from 

%Define the size of the ebsd map 
y_max = max(ebsd.y);
x_max = max(ebsd.x);

figure 

for a = 0:1:9
    %size of the reduced area 
    Height = y_max - a*0.1*y_max;
    Length = x_max - a*0.1*y_max;
  
    plot(ebsd(phase),ebsd(phase).orientations)
    hold on 
    region = [((x_max/2)-(Length/2)) ((y_max/2)-(Height/2)) Length Height];
    rectangle('position',region,'edgecolor','r','linewidth',2)
    
    condition = inpolygon(ebsd,region);
    ebsd_mod = ebsd(condition);

    [Mean_Lengths_X,Mean_Lengths_Y, lengths_x, lengths_y] = LinearIntercepts_fun(ebsd_mod,nx,ny,cutoff,phase,crystal);
    
    d_combined = horzcat(lengths_x', lengths_y');
    Mean_SG_size_area(a+1) = (sum(d_combined)/length(d_combined));
  
end


Mean_SG_size_area_mod = fliplr(Mean_SG_size_area);
size =  [1,4,9,16,25,36,49,64,81,100];

%% Add the percentage change 
Percent_change = zeros(1,9);

for b = 1:1:10
    Percent_change(b) = (abs(Mean_SG_size_area_mod(b)-Mean_SG_size_area_mod(10))/Mean_SG_size_area_mod(10))*100;
end 

  figure 
  set(0,'DefaultAxesFontSize',17,'DefaultAxesFontName','helvetica','DefaultAxesTickLength',[.03 .02],'DefaultAxesLineWidth',2)
  plot(size, Mean_SG_size_area_mod, 'LineWidth', 2, 'color', 'k');
  hold on
  scatter(size, Mean_SG_size_area_mod,50, 'filled', 'black');
  hold on 
  
  xlabel('Area of submap (% of original map)')
  ylabel('\lambda(\mum)')
  % Get current limits.
  yl = ylim; 
  ylim([0, 1.5*yl(2)]); 
  box on 
  hold on 
 
  size_2 =  [1,4,9,16,25,36,49,64,81,100];
  
 
  yyaxis right
  ylim([0, 30]);
  scatter(size_2, Percent_change, 50, 'filled', 'sr');
  ylabel('% change (abs((\lambda - \lambda_b_e_s_t)/ \lambda_b_e_s_t))*100')
  left_colour = [1 0 0];
  right_colour = [0 0 0];
  set(0,'defaultAxesColorOrder',[left_colour; right_colour]);
  hold on 

