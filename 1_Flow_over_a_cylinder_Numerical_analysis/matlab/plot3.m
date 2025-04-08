clear; clc;

% Definir radio del cilindro (diámetro de 1 cm)
R = 0.005; % Radio en metros

% Lista de Reynolds y archivos correspondientes
Re_vals = [10, 20, 30, 45, 70];
archivos = {'10_SF.txt', '20_SF.txt', '30_SF.txt','45_SF.txt','70_SF.txt'};

% Crear figura combinada
fig_comb = figure(1);
set(fig_comb, 'Position', [260, 320, 900, 500]);
hold on;

% Colores para cada curva
colores = lines(length(archivos));

% Vector para guardar ángulos de separación
theta_sep = NaN(1, length(archivos));

% Recorrer cada archivo
for k = 1:length(archivos)
    filename = archivos{k};
    fid = fopen(filename, 'r');

    if fid == -1
        warning('No se pudo abrir el archivo: %s', filename);
        continue;
    end

    data = [];

    % Leer línea por línea
    while ~feof(fid)
        line = fgetl(fid);
        if isempty(line) || line(1) == '(' || contains(line, 'title') || contains(line, 'labels')
            continue;
        end
        nums = sscanf(line, '%f');
        if numel(nums) == 2
            data = [data; nums'];
        end
    end
    fclose(fid);

    % Separar datos
    position = data(:,1);
    Cf = data(:,2);

    % Validar dominio de arccos
    valid_idx = abs(position) <= R;
    position_valid = position(valid_idx);
    Cf_valid = Cf(valid_idx);

    % Calcular ángulo theta
    theta_rad = acos(-position_valid / R);
    theta_deg = rad2deg(theta_rad);

    % Ordenar por ángulo
    [theta_deg_sorted, idx] = sort(theta_deg);
    Cf_sorted = Cf_valid(idx);

    %% ➤ Agregar al gráfico combinado
    plot(theta_deg_sorted, Cf_sorted, '-o', 'Color', colores(k,:), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Re = %d', Re_vals(k)));

    %% ➤ Cálculo del punto de separación como mínimo de Cf (excluyendo bordes)
    valid_range = theta_deg_sorted > 10 & theta_deg_sorted < 170;

    if any(valid_range)
        [~, min_idx_rel] = min(Cf_sorted(valid_range));
        valid_thetas = theta_deg_sorted(valid_range);
        sep_angle = valid_thetas(min_idx_rel);
        theta_sep(k) = sep_angle;
    else
        warning('No hay puntos válidos entre 10° y 170° para Re = %d.', Re_vals(k));
    end
end

% Finalizar gráfico combinado
xlabel('$\theta\ (\mathrm{degrees})$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$\lambda$', 'Interpreter', 'latex', 'FontSize', 12);
title('Skin Friction Coefficient on the Cylinder Surface for Different Reynolds Numbers', ...
       'Interpreter', 'latex', 'FontSize', 14);
legend('Location', 'best');
grid on;
hold off;

%% ➤ Mostrar resultados
fprintf('\nSeparation angles (theta in degrees, defined as Cf minimum between 10° and 170°):\n');
for k = 1:length(Re_vals)
    if ~isnan(theta_sep(k))
        fprintf('Re = %d → Separation at θ ≈ %.2f°\n', Re_vals(k), theta_sep(k));
    else
        fprintf('Re = %d → No valid minimum found in range [10°, 170°]\n', Re_vals(k));
    end
end

%% ➤ Plot de ángulo de separación vs Re
figure;
plot(Re_vals, theta_sep, 'ko-', 'LineWidth', 1.5, 'MarkerSize', 8);
xlabel('Reynolds Number, Re', 'FontSize', 12);
ylabel('Separation Angle, $\theta_{\mathrm{sep}}$ (deg)', 'Interpreter', 'latex', 'FontSize', 12);
title('Boundary Layer Separation Angle vs Reynolds Number','Interpreter', 'latex', 'FontSize', 14);
grid on;
