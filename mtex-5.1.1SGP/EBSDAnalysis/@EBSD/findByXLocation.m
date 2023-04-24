function map = findByYLocation( ebsd, x )
% select EBSD data by spatial coordinates (specifically anything along a
% single y-line)
%
% Input
%  ebsd - @EBSD
%  xy - list of [x(:) y(:)] coordinates, respectively [x(:) y(:) z(:)]
%
% Output
%  ebsd - @EBSD subset
%
% Example
%   mtexdata fo
%   plotx2east
%   plot(ebsd)
%   p = [10000 5000] %ginput(1)
%   g = findByLocation(ebsd,p)
%
% See also
% EBSD/findByLocation grain2d/findByOrientation
% Based of findByLocation
% Jack McGrath, Uni Of Leeds 2023

if all(isfield(ebsd.prop,{'x','y','z'}))
  x_D = [ebsd.prop.x,ebsd.prop.y,ebsd.prop.z];
elseif all(isfield(ebsd.prop,{'x','y'}))
  x_D = [ebsd.prop.x,ebsd.prop.y];
else
  error('mtex:findByLocation','no Spatial Data!');
end

delta = 1.5*mean(sqrt(sum(diff(ebsd.unitCell).^2,2)));

x_Dm = x_D-delta;  x_Dp = x_D+delta;

nd = sparse(length(ebsd),size(x,1));
dim = size(x_D,2);
for k=1:size(x,1)
  
  candit = find(all(bsxfun(@le,x_Dm(:,1),x) & bsxfun(@ge,x_Dp(:,1),x),2));
%   dist = sqrt(sum(bsxfun(@minus,x_D(candit,:),y).^2,2));
    dist = x_D(candit,1) - x;
    i = find(abs(dist) == min(abs(dist)));
    mindist = min(unique(dist(i))); % Line added findByLocation selects BL pixel when several are the same distance
    i = find(dist == mindist);
%   [dist, i] = min(dist);
  nd(candit(i),k) = 1;
  
end

map = find(any(nd,2));
