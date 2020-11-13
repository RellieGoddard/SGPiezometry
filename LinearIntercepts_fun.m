%% LinearIntercepts_fun - calculate linear intercepts
% Rellie M. Goddard, Modified november 2020 

function [Mean_Lengths_X,Mean_Lengths_Y, lengths_x, lengths_y] = LinearIntercepts_fun(ebsd,nx,ny,cutoff,phase,crystal)

set(0,'DefaultAxesFontSize',15,'DefaultAxesFontName','helvetica','DefaultAxesTickLength',[.03 .02],'DefaultAxesLineWidth',2)
figure('position',[422          95        1121         847])

%%%%%%% Horizontal Lines %%%%%%%%%
axesPos = subplot(2,2,1);
plot(ebsd(phase),ebsd(phase).orientations,'parent',axesPos), hold on

%decide line positions
y_pos = ((max(max(ebsd.y))-min(min(ebsd.y)))/nx  .*  [1:nx]) - (max(max(ebsd.y))-min(min(ebsd.y)))/nx /2 + min(min((ebsd.y)));

lengths_x = [];
for i = 1:nx
    
    % get data along line
    stepsize = ebsd.y(2)-ebsd.y(1);
    x_line = [0:stepsize:max(max(ebsd.x))]';
    y_line = y_pos(i)*ones(size(x_line));
    lineebsd = ebsd(findByLocation(ebsd,[x_line y_line]));
    if isempty(lineebsd(phase)) == 0
        ind = find(lineebsd('indexed').phase == lineebsd(phase).phase(1)); %indices of primary phase
        % preallocate orientaion vector
        ori = orientation('Euler',NaN(size(lineebsd('indexed'))),NaN(size(lineebsd('indexed'))),NaN(size(lineebsd('indexed'))),lineebsd(phase).CS,specimenSymmetry(crystal));
        
        ori(ind) = lineebsd(phase).orientations;%orientations of primary phase along line
        ind_2phase = find((lineebsd('indexed').phase ~= lineebsd(phase).phase(1))  + (lineebsd('indexed').phase ~= 0) > 1); %indices of secondary phases
        ori(ind_2phase) = orientation('Euler',zeros(size(ind_2phase)),zeros(size(ind_2phase)),zeros(size(ind_2phase)),lineebsd(phase).CS,specimenSymmetry(crystal)); %dummy orientations for secondary phases along line
        
        % find coordinates of intercepts
        angles = angle(ori(1:end-1),ori(2:end))/degree; %misorienatation angles along line
        ind1 = find(angles>cutoff);
        ind2 = ind1+1;
        
        intercept_x1 = lineebsd('indexed').x(ind1); %intercept on left side of unindexed region
        intercept_x2 = lineebsd('indexed').x(ind2); %intercept on right side of unindexed region
        intercept_x = (intercept_x1 + intercept_x2)./2; %average intercept position
        intercept_y = lineebsd('indexed').y(ind1);
        
        
        % find indices for segements that are not primary phase
        ind_2phaseseg = find(((lineebsd('indexed').phase(ind1(2:end)) ~= lineebsd(phase).phase(1)) + (lineebsd('indexed').phase(ind2(1:end-1)) ~= lineebsd(phase).phase(1)))==2);

        
        
        x_start = intercept_x(1:end-1);
        x_start(ind_2phaseseg) = [];
        x_end = intercept_x(2:end);
        x_end(ind_2phaseseg) = [];
        
        
        for l = 1:2:(length(x_start))
            line([x_start(l); x_end(l)],intercept_y(1:2),'color','b','linewidth',3)
        end
        for l = 1:2:(length(x_start))-1
            line([x_start(l+1); x_end(l+1)],intercept_y(1:2),'color','r','linewidth',3)
        end
        
        
        
        
        % store data
        lengths_x = [lengths_x; [x_end - x_start]];
    end
end

Mean_Lengths_X = mean(lengths_x); 
subplot(2,2,3)
hist(lengths_x)
ylabel('Frequency')
xlabel('Horizontal intercept length (\mum)')
title(['Mean intercept length = ' num2str(Mean_Lengths_X,3) ' \mum'])



%%%%%%% Vertical Lines %%%%%%%%%
axesPos = subplot(2,2,2);
plot(ebsd(phase),ebsd(phase).orientations,'parent',axesPos), hold on

%decide line positions
x_pos = ((max(max(ebsd.x))-min(min(ebsd.x)))/ny  .*  [1:nx]) - (max(max(ebsd.x))-min(min(ebsd.x)))/ny /2 + min(min(ebsd.x));

lengths_y = [];
for i = 1:ny
    
    % get data along line
    stepsize = ebsd.y(2)-ebsd.y(1);
    y_line = [0:stepsize:max(max(ebsd.y))]';
    x_line = x_pos(i)*ones(size(y_line));
    lineebsd = ebsd(findByLocation(ebsd,[x_line y_line]));
    if isempty(lineebsd(phase)) == 0
        ind = find(lineebsd('indexed').phase == lineebsd(phase).phase(1)); %indices of primary phase
        % preallocate orientaion vector
        ori = orientation('Euler',NaN(size(lineebsd('indexed'))),NaN(size(lineebsd('indexed'))),NaN(size(lineebsd('indexed'))),lineebsd(phase).CS,specimenSymmetry(crystal));
        ori(ind) = lineebsd(phase).orientations;%orientations of primary phase along line
        ind_2phase = find((lineebsd('indexed').phase ~= lineebsd(phase).phase(1))  + (lineebsd('indexed').phase ~= 0) > 1); %indices of secondary phases
        ori(ind_2phase) = orientation('Euler',zeros(size(ind_2phase)),zeros(size(ind_2phase)),zeros(size(ind_2phase)),lineebsd(phase).CS,specimenSymmetry(crystal)); %dummy orientations for secondary phases along line
        
        % find coordinates of intercepts
        angles = angle(ori(1:end-1),ori(2:end))/degree; %misorienatation angles along line
        ind1 = find(angles>cutoff);
        ind2 = ind1+1;
        
        intercept_y1 = lineebsd('indexed').y(ind1); %intercept on left side of unindexed region
        intercept_y2 = lineebsd('indexed').y(ind2); %intercept on right side of unindexed region
        intercept_y = (intercept_y1 + intercept_y2)./2; %average intercept position
        intercept_x = lineebsd('indexed').x(ind1);
        
        
        % find indices for segements that are not primary phase
        ind_2phaseseg = find(((lineebsd('indexed').phase(ind1(2:end)) ~= lineebsd(phase).phase(1)) + (lineebsd('indexed').phase(ind2(1:end-1)) ~= lineebsd(phase).phase(1)))==2);
        
        
        
        y_start = intercept_y(1:end-1);
        y_start(ind_2phaseseg) = [];
        y_end = intercept_y(2:end);
        y_end(ind_2phaseseg) = [];
        
        
        for l = 1:2:(length(y_start))
            line(intercept_x(1:2),[y_start(l); y_end(l)],'color','b','linewidth',3)
        end
        for l = 1:2:(length(y_start))-1
            line(intercept_x(1:2),[y_start(l+1); y_end(l+1)],'color','r','linewidth',3)
        end
        
        
        
        
        % store data
        lengths_y = [lengths_y; [y_end - y_start]];
    end
end

Mean_Lengths_Y = mean(lengths_y); 
subplot(2,2,4)
hist(lengths_y)
ylabel('Frequency')
xlabel('Verical intercept length (\mum)')
title(['Mean intercept length = ' num2str(Mean_Lengths_Y,3) ' \mum'])
