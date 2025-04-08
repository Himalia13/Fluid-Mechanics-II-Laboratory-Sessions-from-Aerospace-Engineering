% Script para crear un video a partir de imágenes PNG en una carpeta

% Especifica la ruta de la carpeta que contiene las imágenes PNG
carpeta = 'fp1000';  % Cambia esta ruta según tu carpeta

% Obtén la lista de archivos PNG en la carpeta
patronArchivos = fullfile(carpeta, '*.png');
archivos = dir(patronArchivos);

% Verifica que se hayan encontrado imágenes
if isempty(archivos)
    error('No se encontraron imágenes PNG en la carpeta especificada.');
end

numero = regexp(carpeta, '\d+', 'match');  % Extrae los números de la cadena
nombreVideoSalida = ['CV_' numero{1} '.avi'];  % Formatea el nombre del archivo


% Crea el objeto VideoWriter para el archivo de salida
videoSalida = VideoWriter(nombreVideoSalida);
videoSalida.FrameRate = 50;  % Establece la tasa de cuadros (frames por segundo), ajusta según necesidad

open(videoSalida);

% Recorre cada imagen y la escribe en el video
for k = 1:length(archivos)
    % Obtén el nombre completo del archivo
    nombreArchivo = fullfile(carpeta, archivos(k).name);
    % Lee la imagen
    img = imread(nombreArchivo);
    % Si la imagen es de tipo indexed, conviértela a RGB
    if size(img,3) == 1
        img = repmat(img, [1 1 3]);
    end
    % Escribe la imagen como un cuadro en el video
    writeVideo(videoSalida, img);
end

% Cierra el objeto VideoWriter
close(videoSalida);

disp('Video creado exitosamente.');
