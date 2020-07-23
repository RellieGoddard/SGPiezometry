%% Equivalent_stress function calulates the equivalent stress using the Goddard et al. 2020 subgrain-size piezometer 
% Rellie M. Goddard, July 2020
function [Equivalent_stress] = Stress_Calulation_fun(phase,Piezometer_choice,a_mean_RG)

if Piezometer_choice == 1
    ParA = 0.6;
    ParA_err = (0.7/2); 
    ParB = -1.2;
    ParB_err = (0.3/2); 
elseif Piezometer_choice == 2
    ParA = 1.2;
    ParA_err = (1/2); 
    ParB = -1.0;
    ParB_err = (0.4/2); 
end 

if phase == 'Forsterite'
    Burgers = 4.75*10^-4; %what vector? 4.75 in microns
    prompt = 'Which Forsterite Fo-90/Fo-50 [e.g. Fo-90]: ';
    Phase_str = input(prompt,'s');
    if Phase_str == 'Fo-90';
        Shear_M = 7.78*10^4;%need to confirm but Mao et al., 2015 at Room temp;
    elseif Phase_str == 'Fo-50';
        Shear_M = 6.26*10^4; %need to confirm but Mao et al., 2015 at Room temp 
    end 
elseif phase == 'Quartz'
    Shear_M = 4.2*10^4; %MPa taken from Twiss 1977;
    Burgers = 5.1*10^-4; %what vector? in microns 
end 
        
Equivalent_stress = Shear_M*((a_mean_RG/(Burgers*(10^ParA)))^(1/ParB));

end 
