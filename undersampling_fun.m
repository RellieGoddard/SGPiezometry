%% ProcessEBSD_fun - imports and processes EBSD data 
% Rellie Goddard, July 2020

function [fname_new, stepx_all, Step_size_SG_size] = undersampling_fun(Int_max, dirname, sample_name, header_size,gb_min,sg_min,test, Phase_map, Band_contrast, nx, ny, cutoff, phase, crystal);

Step_size_SG_size = [];
stepx_all = [];

%%%%%% User Inputs%%%%%%
for Int = 1:1:Int_max
fname_new = [sample_name '_int' num2str(Int)];

%%%%%%%%%%%%%%%%%%%%%%%%%


Input_CTF = [dirname sample_name '.ctf'];
data = importdata(Input_CTF,';');

%Original numbers of rows and columns
nc_or =(str2num(data{5}(8:size(data{5},2))));
nr_or =(str2num(data{6}(8:size(data{6},2))));

%New numbers of rows and columns
nc = ceil(nc_or/Int);
nr = ceil(nr_or/Int);


%Indices of points to use
x=[1:Int:nc_or]';
ind=[];
for i=1:nr
    temp=x+(nc_or*Int)*(i-1);
    ind=[ind;temp];
end

%Modify step size
stepx = str2num(data{7}(7:end))*Int;
stepy = str2num(data{8}(7:end))*Int;
data{7}(7:end) = '';
data{7}(7:7+size(num2str(stepx),2)-1) = num2str(stepx);
data{8}(7:end) = '';
data{8}(7:7+size(num2str(stepy),2)-1) = num2str(stepy);

stepx_all = [stepx_all, stepx];

%Modify number of cells
data{5}(8:end) = '';
data{5}(8:8+size(num2str(nc),2)-1) = num2str(nc);
data{6}(8:end) = '';
data{6}(8:8+size(num2str(nr),2)-1) = num2str(nr);

%Modify rows of data
data_new = data(1:length(ind)+ header_size);
data_new(header_size+1:end) = data(ind+header_size);


%Write to new ctf file
fileid = fopen([fname_new '.ctf'],'w');
fprintf(fileid,'%s\r\n',data_new{:,:})
fclose(fileid)

fname = [fname_new '.ctf'];
[ebsd,grains,subgrains] = ProcessEBSD_fun(fname,gb_min,sg_min, phase, test, Phase_map, Band_contrast);
[Mean_Lengths_X,Mean_Lengths_Y, lengths_x, lengths_y] = LinearIntercepts_fun(ebsd,nx,ny,cutoff,phase,crystal);

d_h = lengths_x;
d_v = lengths_y;
d = [d_h;d_v];
%calculate the arithmetic mean 
a_mean_RG = sum(d)/length(d);

Step_size_SG_size = [Step_size_SG_size, a_mean_RG];
end 
end 






