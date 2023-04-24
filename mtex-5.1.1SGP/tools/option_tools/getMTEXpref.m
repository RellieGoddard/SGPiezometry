function value = getMTEXpref(pref,default)

group = getappdata(0,'mtex');

if nargin == 0

  value = group;
  
elseif isfield(group,pref)
  
  value = group.(pref);
  
else
    try
        value = default;
    catch
        if strcmpi(pref, 'version')
            fprintf('Cannot find version - mtex verion finding failed\n')
            value = '0.0.0';
        else
            value = [];
        end
    end
end

end

