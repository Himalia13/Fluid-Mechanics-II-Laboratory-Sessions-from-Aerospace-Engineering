clear; clc;

% Define el radio del cilindro (diámetro de 1 cm)
R = 0.005; % Radio en metros

% Lista de Reynolds y nombres de archivos correspondientes
Re_vals = [0.1, 1, 4, 10, 20, 30, 45, 70];
archivos = {'0.1_PC.txt','1_PC.txt', '4_PC.txt', '10_PC.txt', '20_PC.txt', '30_PC.txt','45_PC.txt','70_PC.txt'};

% Re_vals = [4, 10, 20, 30, 45, 70];
% archivos = {'4_PC.txt', '10_PC.txt', '20_PC.txt', '30_PC.txt','45_PC.txt','70_PC.txt'};


% Crear figura combinada
fig_comb = figure(6);
set(fig_comb, 'Position', [260, 320, 900, 500]);
hold on;

% Colores para cada curva
colores = lines(length(archivos));

% Recorrer cada archivo de datos
for k = 1:length(archivos)
    filename = archivos{k};
    fid = fopen(filename, 'r');
    
    if fid == -1
        warning('No se pudo abrir el archivo: %s', filename);
        continue;
    end

    data = [];

    % Leer archivo línea por línea
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
    Cp = data(:,2);

    % Calcular ángulo theta
    theta_rad = acos(-position / R);
    theta_deg = rad2deg(theta_rad);

    % Ordenar por ángulo
    [theta_deg_sorted, idx] = sort(theta_deg);
    Cp_sorted = Cp(idx);
    Cp_save(k,:) = Cp_sorted;

    %% ➤ Agregar al gráfico combinado
    plot(theta_deg_sorted, Cp_sorted, 'Color', colores(k,:), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Re = %d', Re_vals(k)));


end

% Finalizar gráfico combinado
xlabel('$\theta\ (\mathrm{degrees})$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$C_p$', 'Interpreter', 'latex', 'FontSize', 12);
title('Pressure Coefficient on the Cylinder Surface for Different Reynolds Numbers', ...
       'Interpreter', 'latex', 'FontSize', 14);
legend('Location', 'best');
grid on;
hold off;

% ➤ Crear figura individual corregida
% % % fig_ind = figure(100); % Usa un índice único fuera de conflicto con otros
% % % set(fig_ind, 'Position', [300 + 40, 250 + 30, 600, 400]);
% % % plot(theta_deg_sorted, Cp_save(1,:), '-o', 'Color', colores(1,:), 'LineWidth', 1.5);
% % % xlabel('$\theta\ (\mathrm{degrees})$', 'Interpreter', 'latex', 'FontSize', 12);
% % % ylabel('$C_p$', 'Interpreter', 'latex', 'FontSize', 12);
% % % title(sprintf('Pressure Coefficient on the Cylinder Surface (Re = %d)', Re_vals(1)), ...
% % %     'Interpreter', 'latex', 'FontSize', 14);
% % % grid on;
% % % 
% % % fig_ind = figure(200); % Usa un índice único fuera de conflicto con otros
% % % set(fig_ind, 'Position', [300 + 40, 250 + 30, 600, 400]);
% % % plot(theta_deg_sorted, Cp_save(2,:), '-o', 'Color', colores(2,:), 'LineWidth', 1.5);
% % % xlabel('$\theta\ (\mathrm{degrees})$', 'Interpreter', 'latex', 'FontSize', 12);
% % % ylabel('$C_p$', 'Interpreter', 'latex', 'FontSize', 12);
% % % title(sprintf('Pressure Coefficient on the Cylinder Surface (Re = %d)', Re_vals(2)), ...
% % %     'Interpreter', 'latex', 'FontSize', 14);
% % % grid on;
% % % 
% % % fig_ind = figure(300); % Usa un índice único fuera de conflicto con otros
% % % set(fig_ind, 'Position', [300 + 40, 250 + 30, 600, 400]);
% % % plot(theta_deg_sorted, Cp_save(3,:), '-o', 'Color', colores(3,:), 'LineWidth', 1.5);
% % % xlabel('$\theta\ (\mathrm{degrees})$', 'Interpreter', 'latex', 'FontSize', 12);
% % % ylabel('$C_p$', 'Interpreter', 'latex', 'FontSize', 12);
% % % title(sprintf('Pressure Coefficient on the Cylinder Surface (Re = %d)', Re_vals(3)), ...
% % %     'Interpreter', 'latex', 'FontSize', 14);
% % % grid on;
% % % 
% % % fig_ind = figure(400); % Usa un índice único fuera de conflicto con otros
% % % set(fig_ind, 'Position', [300 + 40, 250 + 30, 600, 400]);
% % % plot(theta_deg_sorted, Cp_save(4,:), '-o', 'Color', colores(4,:), 'LineWidth', 1.5);
% % % xlabel('$\theta\ (\mathrm{degrees})$', 'Interpreter', 'latex', 'FontSize', 12);
% % % ylabel('$C_p$', 'Interpreter', 'latex', 'FontSize', 12);
% % % title(sprintf('Pressure Coefficient on the Cylinder Surface (Re = %d)', Re_vals(4)), ...
% % %     'Interpreter', 'latex', 'FontSize', 14);
% % % grid on;
% % % 
% % % fig_ind = figure(500); % Usa un índice único fuera de conflicto con otros
% % % set(fig_ind, 'Position', [300 + 40, 250 + 30, 600, 400]);
% % % plot(theta_deg_sorted, Cp_save(5,:), '-o', 'Color', colores(5,:), 'LineWidth', 1.5);
% % % xlabel('$\theta\ (\mathrm{degrees})$', 'Interpreter', 'latex', 'FontSize', 12);
% % % ylabel('$C_p$', 'Interpreter', 'latex', 'FontSize', 12);
% % % title(sprintf('Pressure Coefficient on the Cylinder Surface (Re = %d)', Re_vals(5)), ...
% % %     'Interpreter', 'latex', 'FontSize', 14);
% % % grid on;
% % % 
% % % fig_ind = figure(600); % Usa un índice único fuera de conflicto con otros
% % % set(fig_ind, 'Position', [300 + 40, 250 + 30, 600, 400]);
% % % plot(theta_deg_sorted, Cp_save(6,:), '-o', 'Color', colores(6,:), 'LineWidth', 1.5);
% % % xlabel('$\theta\ (\mathrm{degrees})$', 'Interpreter', 'latex', 'FontSize', 12);
% % % ylabel('$C_p$', 'Interpreter', 'latex', 'FontSize', 12);
% % % title(sprintf('Pressure Coefficient on the Cylinder Surface (Re = %d)', Re_vals(6)), ...
% % %     'Interpreter', 'latex', 'FontSize', 14);
% % % grid on;
% % % 
% % % fig_ind = figure(700); % Usa un índice único fuera de conflicto con otros
% % % set(fig_ind, 'Position', [300 + 40, 250 + 30, 600, 400]);
% % % plot(theta_deg_sorted, Cp_save(7,:), '-o', 'Color', colores(7,:), 'LineWidth', 1.5);
% % % xlabel('$\theta\ (\mathrm{degrees})$', 'Interpreter', 'latex', 'FontSize', 12);
% % % ylabel('$C_p$', 'Interpreter', 'latex', 'FontSize', 12);
% % % title(sprintf('Pressure Coefficient on the Cylinder Surface (Re = %d)', Re_vals(7)), ...
% % %     'Interpreter', 'latex', 'FontSize', 14);
% % % grid on;
% % % 
% % % fig_ind = figure(800); % Usa un índice único fuera de conflicto con otros
% % % set(fig_ind, 'Position', [300 + 40, 250 + 30, 600, 400]);
% % % plot(theta_deg_sorted, Cp_save(8,:), '-o', 'Color', colores(8,:), 'LineWidth', 1.5);
% % % xlabel('$\theta\ (\mathrm{degrees})$', 'Interpreter', 'latex', 'FontSize', 12);
% % % ylabel('$C_p$', 'Interpreter', 'latex', 'FontSize', 12);
% % % title(sprintf('Pressure Coefficient on the Cylinder Surface (Re = %d)', Re_vals(8)), ...
% % %     'Interpreter', 'latex', 'FontSize', 14);
% % % grid on;