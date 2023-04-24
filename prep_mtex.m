function prep_mtex(version, SGPpath)

if nargin < 1
    mtex_version = '5.1.1SGP';
else
    mtex_version = version;
end

if nargin < 2
    SGPpath = '/nfs/a285/homes/eejdm/SGPiezometry';
else
    SGPpath;
end

curdir = pwd;

mtex = [SGPpath, filesep, 'mtex-', mtex_version];

fprintf('mtex location: %s', mtex)

cd(mtex)

install_mtex

addpath(genpath(mtex))
addpath('/nfs/a285/homes/eejdm/SGPiezometry')

cd(curdir)

fprintf('Ready to roll!!!\n')

