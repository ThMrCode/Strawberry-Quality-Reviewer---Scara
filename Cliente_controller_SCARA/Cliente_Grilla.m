clc; clear all; close all
%% Longitudes del brazo en centimetros 
% Longitudes en centimetros y angulos en radianes
global a1 a2 a3 a4 z_max range_q2 range_q3 gripper_l1 gripper_l2 angle_finger n_pinzas;
a1 = 19 ; a2 = 6.3 ; a3 = 16.2 ; a4 = 20.2;
z_max = 67; range_q2 = 90 * pi/180; range_q3 = 105 * pi/180;
gripper_l1 = 7; gripper_l2 = 5; angle_finger = 105 * pi/180;  n_pinzas = 3;

%Implementaciones respecto a la rejilla (centimetros)
centro = [46 0 0]; filas = 8; columnas = 3; d_filas = 4; d_columnas = 4;

%% Mapeo de posiciones posibles en la rejilla
global X Y;
% Extraer las coordenadas del centro
x_c = centro(1);
y_c = centro(2);

x_range = (columnas + 1) * d_columnas / 2 - d_columnas;
y_range = (filas + 1) * d_filas / 2 - d_filas;
X = linspace(-x_range, x_range, columnas) + x_c;
Y = linspace(-y_range, y_range, filas) + y_c;

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
while ~strcmp(mensaje,'exit') & ~strcmp(mensaje,'exitserver')
    mensaje = input('Indicar fila,columna, altura y garra : ','s');
    if ~isempty(str2num(mensaje))
        v = str2num(mensaje);
        moverSCARA_rejilla(v(1), v(2), v(3), v(4))
    elseif strcmp(mensaje,'exit') | strcmp(mensaje,'exitserver')
        outputStream.println(mensaje)
    else
        disp('Error de comando')
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

function [d1 ,q2 ,q3] = cinematica_inversa_PRR(x, y, z) 
    global a1 a2 a3 a4
    d1 = z + a2;
    if y ~= 0
        D = ((x-a1)^2 + y^2 - a3^2 - a4^2)/(2 * a3 * a4);
        q3 = atan2(sign(y) * sqrt(1 - D^2) , D);
        q2 = atan2(y , x - a1) - atan2(a4 * sin(q3) , a3 + a4 * cos(q3));
    else 
        q2 = -acos((a3^2 + (x - a1)^2 - a4^2) / (2 * a3 * (x - a1)));
        q3 = acos((a3^2 + a4^2 - (x - a1)^2) / (2 * a3 * a4));
    end
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
function moverSCARA_rejilla(fila, columna, altura, claw_state)
    global X Y;
   [d1, q2, q3] = cinematica_inversa_PRR(X(columna), Y(fila), altura);
    moverSCARA(d1, q2, q3, claw_state)
end
