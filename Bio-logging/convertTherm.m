function [temp_uC,temp_uF] = convertTherm(Vo)
Vo = uint32(Vo);

Rf = uint32(100000);
Vi = uint32(1800000); % volts
Rt = int32((((Vo/1000)*(Rf/1000)) / ((Vi-Vo)/1000)) * 1000);

% Linear model Poly1:
% f(x) = p1*x + p2
% Coefficients (with 95% confidence bounds):
% p1 =  -0.0001962  (-0.0002086, -0.0001838)
% p2 =       45.18  (43.81, 46.55)

temp_uC = int32(-196 * Rt + 45177309);
temp_uF = temp_uC * 1.8 + 32;

% Vi = 1.8; % volts
% Rt = (Vo*100000) / (Vi-Vo);
% 
% % Linear model Poly1:
% % f(x) = p1*x + p2
% % Coefficients (with 95% confidence bounds):
% % p1 =  -0.0001962  (-0.0002086, -0.0001838)
% % p2 =       45.18  (43.81, 46.55)
% 
% tempC = -0.000196 * Rt + 45.18;
% tempF = tempC * 1.8 + 32;