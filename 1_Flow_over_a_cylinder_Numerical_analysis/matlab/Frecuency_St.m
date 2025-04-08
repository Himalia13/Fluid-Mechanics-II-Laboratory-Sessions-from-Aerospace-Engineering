%% Parameters
% Cylinder parameters (for a 1 cm diameter cylinder)
d = 0.01;       % Diameter in meters
R = d/2;        % Radius (not used in frequency analysis, but kept for consistency)
U_inf = [0.11686, 0.14607, 0.17528, 0.2191, 0.24832, 0.29214, 0.36518, 0.4382, 1.4607]; % Inlet velocities in m/s

% List of Reynolds numbers and corresponding data file names
Re_vals = [80, 100, 120, 150, 170, 200, 250, 300, 1000];  % Reynolds numbers
filenames = {'Re80 (2).txt', 'Re100 (2).txt', 'Re120 (2).txt', 'Re150 (2).txt', ...
             'Re170 (2).txt', 'Re200 (2).txt', 'Re250 (2).txt', 'Re300 (2).txt', 'Re1000 (2).txt'};

U_inf = [0.11686, 0.14607, 0.17528, 0.2191, 0.24832, 0.29214, 0.36518, 0.4382]; % Inlet velocities in m/s

% List of Reynolds numbers and corresponding data file names
Re_vals = [80, 100, 120, 150, 170, 200, 250, 300];  % Reynolds numbers
filenames = {'Re80 (2).txt', 'Re100 (2).txt', 'Re120 (2).txt', 'Re150 (2).txt', ...
             'Re170 (2).txt', 'Re200 (2).txt', 'Re250 (2).txt', 'Re300 (2).txt'};

% Preallocate arrays for dominant frequency and Strouhal number
f_osc = zeros(length(Re_vals), 1);
St = zeros(length(Re_vals), 1);

%% Loop over each Reynolds number data file
for k = 1:length(Re_vals)
    % Open the data file
    filename = filenames{k};
    fid = fopen(filename, 'r');
    if fid == -1
        error('Could not open file %s', filename);
    end
    
    % Initialize an empty array to hold numeric data
    data = [];
    
    % Read file line-by-line; skip header or non-numeric lines
    while ~feof(fid)
        line = fgetl(fid);
        % Skip empty lines, headers with quotes, parentheses, or text
        if isempty(line) || line(1) == '"' || line(1) == '(' || contains(lower(line), 'time') || contains(lower(line), 'step')
            continue;
        end
        % Extract numeric data (expecting 3 columns: TimeStep, Coefficient, Flow time)
        nums = sscanf(line, '%f');
        if numel(nums) == 3
            data = [data; nums'];
        end
    end
    fclose(fid);
    
    % Check if data was read
    if isempty(data)
        error('No numeric data found in %s', filename);
    end
    
    % Extract time and coefficient (assuming column 2 is the oscillating quantity, e.g., lift coefficient)
    time = data(:, 3);      % Flow time (s)
    coeff = data(:, 2);     % Coefficient (e.g., Y-velocity or lift coefficient)
    
    % Compute sampling parameters
    dt = time(2) - time(1); % Time step (s)
    fs = 1 / dt;            % Sampling frequency (Hz)
    n = length(time);       % Number of samples
    
    % Remove transient phase (e.g., start analysis after t = 4 s)
    start_idx = find(time >= 4, 1); % Index where t >= 4 s
    if isempty(start_idx)
        start_idx = 1; % Use full data if no time >= 4 s
    end
    time_trim = time(start_idx:end);
    coeff_trim = coeff(start_idx:end);
    n_trim = length(time_trim);
    
    % Remove mean (DC component) for FFT analysis
    coeff_detrended = coeff_trim - mean(coeff_trim);
    
    % Compute FFT
    Y = fft(coeff_detrended);
    f = fftfreq(n_trim, dt); % Frequency bins using helper function
    % Single-sided spectrum (positive frequencies only)
    idx = f >= 0;
    f_positive = f(idx);
    P2 = abs(Y / n_trim);     % Two-sided spectrum
    P1 = P2(idx);             % Single-sided spectrum
    P1(2:end-1) = 2 * P1(2:end-1); % Double amplitudes except DC and Nyquist
    
    % Find the dominant frequency (excluding DC component)
    [~, peak_idx] = max(P1(2:end)); % Skip f=0
    f_dom = f_positive(peak_idx + 1); % Adjust index for skipping DC
    f_osc(k) = f_dom;
    
    % Compute the Strouhal number: St = (f * d) / U_inf
    St(k) = (f_dom * d) / U_inf(k);
    
    fprintf('Re = %d: f = %.3f Hz, St = %.3f\n', Re_vals(k), f_dom, St(k));
end

% Calculate the average Strouhal number
St_avg = mean(St);
fprintf('Average St across all Re: %.3f\n', St_avg);

%% Plotting the results
% Create a single figure with dual y-axes
figure;
set(gcf, 'Position', [260, 320, 700, 500]); % Set figure size

% Plot oscillation frequency (f) on the left y-axis
yyaxis left;
plot(Re_vals, f_osc, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 8);
ylabel('$f$ (Hz)', 'Interpreter', 'latex', 'FontSize', 12);

% Plot Strouhal number (St) on the right y-axis
yyaxis right;
plot(Re_vals, St, 'rs-', 'LineWidth', 1.5, 'MarkerSize', 8);
hold on; % Hold to add the average line
plot([Re_vals(1), Re_vals(end)], [St_avg, St_avg], 'k--', 'Color', 'r', 'LineWidth', 1.5); % Dashed line for average St
hold off;
ylabel('$\mathrm{St}$', 'Interpreter', 'latex', 'FontSize', 12);
ylim([0 0.2]);

% Common x-axis label and title
xlabel('$\mathrm{Re}$', 'Interpreter', 'latex', 'FontSize', 12);
title('Oscillation Frequency and Strouhal Number vs. Reynolds Number', ...
      'Interpreter', 'latex', 'FontSize', 14);

% Add grid and legend
grid on;
legend({'$f$ (Hz)', '$\mathrm{St}$', '$\mathrm{St_{avg}}$'}, ...
       'Interpreter', 'latex', 'Location', 'best');

% Customize axis colors to match plot lines
yyaxis left; ax = gca; ax.YColor = 'b'; % Blue for f_osc
yyaxis right; ax.YColor = 'r'; % Red for St (average line remains black)

%% Helper function: fftfreq
function f = fftfreq(n, dt)
    % Computes FFT frequency bins
    % n: number of samples
    % dt: sample spacing
    f = (0:(n-1)) / (n * dt);
    % Shift frequencies above Nyquist to negative
    half_n = floor(n/2);
    f(half_n+2:end) = f(half_n+2:end) - 1/dt;
end