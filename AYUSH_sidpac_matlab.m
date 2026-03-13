load massdamper_full.mat
unpack_massdamper_full
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DATA INITIALIZATION 

% ADJUST INTERPOLATION HZ HERE
inter_time = 1:0.1:60;
c = 0.3;
k= 0.2;
m = 2;
trueparams = [-c/m, -k/m]';

time = transpose(sampled_random_noise_sinusoidalForce_sparcityLevel150_t);
x = transpose(sampled_random_noise_sinusoidalForce_sparcityLevel150_x);

sinwave = sin(2*pi .* time)'; 
highFreq_sin = sin(2*pi .* inter_time)';

u = sinwave;                 % input force options
% highFreq vs regular U SIGNAL CAUSES MEASURABLE DIFFERENCES IN OUTPUT ACCURACY 


%% DATA SMOOTHING AND DIFFERENTIATION

% Attempts at different smoothing methods
% butterworth filter implementation 
% fs = 2.5;      % sampling frequency
% fc = 1.2;      % cutoff frequency - below is preserved, above is removed 
% [b,a] = butter(6, fc/(fs/2));     % the hardcoded number is filter order - higher order is more aggressive removal above the set frequency
% smoothed_x = filtfilt(b, a, x);
% 
% UNSMOOTHED:
% smoothed_x = x;

smoothed_x = sgolayfilt(x, 2, 21);

interpolated = interp1(time, smoothed_x, inter_time, "spline")';

xdot = deriv(interpolated, inter_time(2)-inter_time(1));      
accel = deriv(xdot, inter_time(2)-inter_time(1));

inter_u = u;
if length(time)==length(inter_u)
    inter_u = interp1(time, u, inter_time, "spline")';    % interpolation algorithm has a meaningful impact on performance
end


%% LEAST SQUARES REGRESSION for initial parameter guesses

% according to hand calcs, parameters will be in the form [-c/m; -k/m; 1/m]

regressormatrix = [xdot, interpolated, inter_u];
[accel_linreg_model, lin_reg_parameter_estimates, crb, s2, xm, sv] = lesq(regressormatrix, accel); 

lin_reg_parameter_estimates = min(lin_reg_parameter_estimates, 0);
lin_reg_parameter_estimates(3) = 1/m;

%% OUTPUT ERROR SOLVER (MORE ACCURATE)
% % code for normalizing inputs
% y_std = std(interpolated);
% y_n = interpolated / y_std;  % normalizing position
% x0 = x0 / y_std;             % normalizing initial state
% u_std = std(inter_u);
% u_n = inter_u / u_std;      % normalizing input signal
% 
% x_std = std(x);
% x_n = x / x_std;    % normalizing position
% x0 = x0 / x_std;             % normalizing initial state
% u_std = std(u);
% u_n = u / u_std;      % normalizing input signal
% 

% CONSIDER:
% - using oe.m with the uninterpolated, unsmoothed data ??
% - using oe.m with normalized y, u, x0
% both of the above here:
%[y_oe_model, p_est, covar, rr, cost] = oe('AYUSH_statespace_smd', lin_reg_parameter_estimates, u_n, time,  x0,  c, x_n,  1, crb);
% y_oe_model = y_oe_model * x_std;
%
% rawest form of data - unnormalized unsmoothed uninterpolated
%  x0 = [x(1); xdot(1)]; % STATE VECTOR INITIAL CONDITION
% [y_oe_model, p_est, covar, rr, cost] = oe('AYUSH_statespace_smd', lin_reg_parameter_estimates, u, time,  x0,  c, x,  1, crb);
% % y_oe_model = y_oe_model * x_std;

x0 = [interpolated(1); xdot(1)]; % STATE VECTOR INITIAL CONDITION
c = m; % constants passed to state space file (n/a)

% smoothed, interpolated position data
% interpolated signal data to ensure the time series are of the same length
[y_oe_model, p_est, covar, rr, cost] = oe('AYUSH_statespace_smd', lin_reg_parameter_estimates, inter_u, inter_time,  x0,  c, interpolated,  1, crb);

figure(4)
if length(y_oe_model)==length(inter_time)
    plot(inter_time, y_oe_model, 'r'); hold on; plot(time, x, 'b*', 'MarkerSize', 3, 'LineStyle',':', LineWidth=0.25); plot(gt_sinusoidal_t, gt_sinusoidal_x, 'y'); legend('Model', 'Measured', 'Truth'); hold off;
else
    plot(time, y_oe_model, 'r'); hold on; plot(time, x, 'b*', 'MarkerSize', 3, 'LineStyle',':', LineWidth=0.25); plot(gt_sinusoidal_t, gt_sinusoidal_x, 'y'); legend('Model', 'Measured', 'Truth'); hold off;
end

%% DISPLAYING RESULTS

% displaying and comparing these parameters
fprintf('###########################################################\n\n');
fprintf('TRUE PARAMETERS: \n');
fprintf('-c/m: %.4f, -k/m: %.4f \n', trueparams(1), trueparams(2));

fprintf('###########################################################\n');
fprintf('Initial parameter guesses from linear regression model: \n');
fprintf('-c/m: %.4f, -k/m: %.4f \n', lin_reg_parameter_estimates(1), lin_reg_parameter_estimates(2));

fprintf('\n\n');
fprintf('Final parameter guesses from output error model: \n');
fprintf('-c/m: %.4f, -k/m: %.4f \n\n', p_est(1), p_est(2));

percent_errors = ((p_est(1:2)-trueparams(1:2)) ./ trueparams(1:2)) .*100;
fprintf('###########################################################\n\n');
fprintf('Parameter percent errors: \n');
fprintf('-c/m: %.4f, -k/m: %.4f \n', percent_errors(1), percent_errors(2));
