%% Area_Analysis_reduction - test to see if the map size is large enough
% Rellie Goddard, July 2020

% This function examines how the effective map size affects
% the mean line intercept length of a given phase in the map.

%% Required functions:
% * ProcessEBSD_fun.m
% * LinearIntercepts_fun.m

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
%       to 0
%
% Results 
%   An EBSD map for each analysis is outputted with a red box outlining the analysed subarea. 
%   A figure showing the intercept analysis of the final subarea. 
%   A figure showing the mean line intercept length plotted against the area as a percentage of the original map. 
%   On the right axis of the same figure the % change of the mean line intercepts length relative to the full map is plotted against map area. 
%
% The test is successful if, as the size of the sub-area increases, the mean intercept length asymptotically approaches the mean for the entire map.  
% For all the samples included in the subgrain-size piezometer, the % change in mean line intercept length relative to the full map was < 5% for a 20% reduction in map area. 
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Conduct test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Creat an array to store the mean line intercept lengths in
Mean_SG_size_area = zeros(1,10); 


% Call on the ProcessEBSD function. This function will output [enter the maps which I want it to output]
[ebsd,grains,subgrains] = ProcessEBSD_fun(fname,gb_min,sg_min, CS, test, Phase_map, Band_contrast);

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

