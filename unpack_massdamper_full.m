%% ===============================
%  UNPACK MASS DAMPER DATASET
%  ===============================

%% -------------------------------
% 1) Ground Truth Parameters
% -------------------------------

gt = data.data_groundtruth.ground_truth_params;

x0         = gt.x0;
t_span     = gt.t_span;
t_eval     = gt.t_eval;
m_true     = gt.m_true;
c_true     = gt.c_true;
k_true     = gt.k_true;
Kp_array   = gt.Kp_array;
delta_val  = gt.delta_val;
omega0_val = gt.omega0_val;
T_val      = gt.T_val;


%% -------------------------------
% 2) Ground Truth Trajectories
% -------------------------------

gt_struct = data.data_groundtruth;

gt_no_force      = gt_struct.("model: No external force");
gt_sinusoidal    = gt_struct.("model: sinusoidal force");
gt_square        = gt_struct.("model: square wave force");
gt_reference_P   = gt_struct.("model: reference tracking with P controller");

% No external force
gt_no_force_t = gt_no_force.t;
gt_no_force_x = gt_no_force.x;
gt_no_force_v = gt_no_force.v;

% Sinusoidal force
gt_sinusoidal_t = gt_sinusoidal.t;
gt_sinusoidal_x = gt_sinusoidal.x;
gt_sinusoidal_v = gt_sinusoidal.v;

% Square wave force
gt_square_t = gt_square.t;
gt_square_x = gt_square.x;
gt_square_v = gt_square.v;

% Reference tracking with P controller
gt_reference_P_t = gt_reference_P.t;
gt_reference_P_x = gt_reference_P.x;
gt_reference_P_v = gt_reference_P.v;


%% -------------------------------
% 3) Uniformly Sampled Data
% -------------------------------

sampled = data.data_sampled;

forces = fieldnames(sampled);

for i = 1:length(forces)
    force_name = forces{i};
    levels = fieldnames(sampled.(force_name));

    for j = 1:length(levels)
        level_name = levels{j};

        d = sampled.(force_name).(level_name);

        base_name = matlab.lang.makeValidName([ ...
            'sampled_' force_name '_' level_name]);

        assignin('base',[base_name '_t'], d.t);
        assignin('base',[base_name '_x'], d.x);
        assignin('base',[base_name '_v'], d.v);
    end
end


%% -------------------------------
% 4) Random Sampled Data
% -------------------------------

sampled_rand = data.data_sampled_random;

forces = fieldnames(sampled_rand);

for i = 1:length(forces)
    force_name = forces{i};
    levels = fieldnames(sampled_rand.(force_name));

    for j = 1:length(levels)
        level_name = levels{j};

        d = sampled_rand.(force_name).(level_name);

        base_name = matlab.lang.makeValidName([ ...
            'sampled_random_' force_name '_' level_name]);

        assignin('base',[base_name '_t'], d.t);
        assignin('base',[base_name '_x'], d.x);
        assignin('base',[base_name '_v'], d.v);
    end
end


%% -------------------------------
% 5) Random Sampled Data With Noise
% -------------------------------

sampled_rand_noise = data.data_sampled_random_with_noise;

forces = fieldnames(sampled_rand_noise);

for i = 1:length(forces)
    force_name = forces{i};
    levels = fieldnames(sampled_rand_noise.(force_name));

    for j = 1:length(levels)
        level_name = levels{j};

        d = sampled_rand_noise.(force_name).(level_name);

        base_name = matlab.lang.makeValidName([ ...
            'sampled_random_noise_' force_name '_' level_name]);

        assignin('base',[base_name '_t'], d.t);
        assignin('base',[base_name '_x'], d.x);
        assignin('base',[base_name '_v'], d.v);
    end
end


%% -------------------------------
% 6) Collocation Points
% -------------------------------

colloc = data.data_colloc;
colloc_fields = fieldnames(colloc);

for i = 1:length(colloc_fields)
    name = colloc_fields{i};
    clean_name = matlab.lang.makeValidName(['colloc_' name]);

    assignin('base', clean_name, colloc.(name));
end


disp("All data successfully unpacked into workspace.")
