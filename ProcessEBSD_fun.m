%% ProcessEBSD_fun - imports and processes EBSD data 
% Rellie Goddard, July 2020
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ebsd,grains,subgrains] = ProcessEBSD_fun(fullname, gb_min, sg_min, CS, test, Phase_map, Band_contrast)
%% Specify Crystal and Specimen Symmetries

% plotting convention
plotx2east
plotzIntoPlane

%% Import the Data
% create an EBSD variable containing the data
% can change to ctf file 
ebsd = loadEBSD(fullname,CS,'interface','ctf','convertEuler2SpatialReferenceFrame');
ebsd_orig = ebsd; %a backup of the original data

if test 
    
    %Reduce size data set for testing
    ebsd = reduce(ebsd,10);
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Rotate data - map and orientaitons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rot = rotation('Euler',[0 0 0]*degree);
ebsd = rotate(ebsd,rot);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data processing and mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Grain detection and noise removal
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',gb_min*degree);

% Remove wild spikes and shards
wild = grains.grainSize == 1;
shard = grains.grainSize < 3 ;
ebsd(grains(wild)).phase = 0;
ebsd(grains(shard)).phase = 0;

% Find small non-indexed regions to remove
% Higher thresholds mean more of the non-indexed regions will be filled in.
threshold = 1;
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',gb_min*degree);
notIndexed = grains('notIndexed');
toRemove = notIndexed(notIndexed.grainSize<threshold);
ebsd(toRemove) = [];

% Reconstruct grains and subgrains
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',gb_min*degree);
subgrains = calcGrains(ebsd,'angle',sg_min*degree);


% Fill non-indexed regions by interpolation. Does not fill in regions that are 
% larger than the threshold
ebsd = fill(ebsd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot Maps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Phase_map
% phase map with boundaries
    figure
    plot(ebsd)
    hold on
    plot(subgrains.boundary('indexed'),'linecolor',[.6 .6 .6],'linewidth',1)
    plot(grains.boundary('indexed'),'linecolor','k','linewidth',2)

elseif Band_contrast 
    % band contrast map with boundaries
    figure
    plot(ebsd_orig,ebsd_orig.bc)
    mtexColorMap black2white
    hold on
    plot(subgrains.boundary('indexed'),'linecolor',[.6 .6 .6],'linewidth',1)
    plot(grains.boundary('indexed'),'linecolor','k','linewidth',2)


end 
