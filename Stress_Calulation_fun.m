%% Equivalent_stress function calulates the equivalent stress using the Goddard et al. submitted subgrain-size piezometer 
% Rellie M. Goddard, July 2020
function [Equivalent_stress] = Stress_Calulation_fun(Burgers,Shear_M,Piezometer_choice,a_mean_RG)

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

        
Equivalent_stress = Shear_M*((a_mean_RG/(Burgers*(10^ParA)))^(1/ParB));

end 
