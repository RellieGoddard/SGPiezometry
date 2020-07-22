%% Area_Analysis_reduction - test to see if the map size is large enough
% Rellie M. Goddard, July 2020

% This function examines how the effective map size affects
% the mean line intercept length of a given phase in the map.

%% Required functions:
% * ProcessEBSD_fun.m
% * LinearIntercepts_fun.m

%% Required user inputs:
% * nx: The number of intercept lines, chosen based on analysis from 
%       No_intercepts_check.m.
% * gb_min: Minimum misorientation angle to define a grain boundary in 
%       degrees. Used for constructing maps.
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
%
%% Additional user inputs produced by MTEX
% * CS: Crystal symmetry class variable for all indexed phaes in EBSD map.
% * pname: Path to data (e.g., 'C:/Users/admin/data/')
% * fname: File name combined with path
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
nx = []; % Number of intercept lines 
gb_min = []; % Minimum misorientation for grain boundary (for figures)
sg_min = []; % Minimum misorientation for subgrain boundary (for figures)
cutoff = []; % Minimum misorientation for subgrain boundary (for calculation)
phase = 'yourPhase'; % Phase to measure. Must match a phase present in CS.
crystal = 'yourCrystalSystem'; % Crystal system of phase to measure. 
Phase_map = 0; % Set to 1 to plot a phase map of the EBSD data. 
Band_contrast = 0; % Set to 1 to plot a band contrast map of the EBSD data.
test = 0; % Set to 1 to speed up analysis when troubleshooting. 

%% END OF USER INPUTS 

%% Programmatically calculate other necessary variables 
ny = nx; % Set number of intercepts in y-direction to equal number of intercepts in the x-direction.
Mean_SG_size_area = zeros(1,10); % Creates an array to store the mean line intercept lengths in.

%% Calculate and plot 

% Call on the ProcessEBSD function. 
[ebsd,grains,subgrains] = ProcessEBSD_fun(fname,gb_min,sg_min, CS, test, Phase_map, Band_contrast);

%% Reduce the area used to mean mean line intercepts from 

% Define the size of the ebsd map 
y_max = max(ebsd.y);
x_max = max(ebsd.x);

figure 

for a = 0:1:9
    % Reduce the area of the map 
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

% Add the percentage change 
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

