clc; clear all; close all
%% Longitudes del brazo en centimetros 
% Longitudes en centimetros y angulos en radianes
global a1 a2 a3 a4 z_max range_q2 range_q3 gripper_l1 gripper_l2 angle_finger n_pinzas handle_final;
a1 = 19 ; a2 = 6.3 ; a3 = 16.2 ; a4 = 20.2;
z_max = 67; range_q2 = 90 * pi/180; range_q3 = 105 * pi/180;
gripper_l1 = 7; gripper_l2 = 5; angle_finger = 105 * pi/180;  n_pinzas = 3;

%Implementaciones respecto a la rejilla (centimetros)
centro_rejilla = [25,5]; filas = 10; columnas = 20; sep_filas = 5; sep_columnas = 5;

%% Mapeo de posiciones posibles en la rejilla
% Extraer las coordenadas del centro
x_c = centro_rejilla(1);
y_c = centro_rejilla(2);

% Crear índices de filas y columnas centrados en 0
idx_filas = (-floor(filas/2)):(ceil(filas/2)-1);
idx_columnas = (-floor(columnas/2)):(ceil(columnas/2)-1);

% Crear la rejilla
global X Y;
[X, Y] = meshgrid(idx_columnas * sep_columnas, idx_filas * sep_filas);

% Ajustar los valores para centrar en centro_rejilla
X = X + x_c;
Y = Y + y_c;

%% Datos de conexión
import java.net.Socket
import java.io.*

server_ip = "127.0.0.1";  % Dirección del servidor
server_port = 5000;

% Conectar al servidor
socket = Socket(server_ip, server_port);
disp("Conectado al servidor.");

global inputStream outputStream;
inputStream = BufferedReader(InputStreamReader(socket.getInputStream()));
outputStream = PrintWriter(socket.getOutputStream(), true);

mensaje = '';
%% Enviar comandos
while ~strcmp(mensaje,'N')
    v = [z_max * rand, -range_q2 + 2 * range_q2 * rand, -range_q3 + 2 * range_q3 * rand, randi([0, 1]);];
    moverSCARA(v(1), v(2), v(3), v(4));
    
    if strcmp(fileread('Control.txt'), 'exit')
        fid = fopen('Control.txt', 'w'); % Abre el archivo en modo escritura (sobreescribe)
        fprintf(fid, '');
        fclose(fid); % Cierra el archivo
        outputStream.println('exitserver');
        break;
    end
end
%% Cerrar conexión correctamente
socket.close();
disp("Conexión cerrada.");


%% Funciones
function [x, y, z] = cinematica_directa_PRR(d1, q2, q3) 
    global a1 a2 a3 a4
    
    x = a4 * cos(q2 - q3) + a3 * cos(q2) + a1;
    y = a4 * sin(q2 - q3) + a3 * sin(q2);
    z = d1 - a2;
end

function [d1, q2, q3] = cinematica_inversa_PRR(x, y, z) 
    global a1 a2 a3 a4
    
    d1 = z + a2;
    D = ((x-19)^2 + y^2 - a3^2 - a4^2)/(2 * a3 * a4);
    q3 = atan2(sign(y) * sqrt(1 - D^2) , D)
    q2 = atan2(y , x - 19) - atan2(a4 * sin(q3) , a3 + a4 * cos(q3))
end

% Función para mover el SCARA, imprime respuesta del scara
function moverSCARA(d1, q2, q3, claw_state)
    global inputStream outputStream;

    % Enviar mensaje
    mensaje = sprintf('[%f,%f,%f,%d]\n', d1, q2, q3, claw_state);
    outputStream.println(mensaje);

    % Leer respuesta del servidor
    respuesta = char(inputStream.readLine());
    disp(respuesta);
end

%Funcion de movimiento basado en la rejilla
function moverSCARA_rejilla(fila, columna, claw_state)
    global X Y;
    Pos = cinematica_inversa_PRR(X(fila, columna), Y(fila, columna), 0);
    moverSCARA(Pos(1), Pos(2), Pos(3), claw_state)
end
