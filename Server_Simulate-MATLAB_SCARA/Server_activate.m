clc; clear all; close all;

% Longitudes en centimetros y angulos en radianes
global a1 a2 a3 a4 z_max range_q2 range_q3 gripper_l1 gripper_l2 angle_finger n_pinzas handle_final;
a1 = 19 ; a2 = 6.3 ; a3 = 16.2 ; a4 = 20.2;
z_max = 67; range_q2 = 90 * pi/180; range_q3 = 105 * pi/180;
gripper_l1 = 7; gripper_l2 = 5; angle_finger = 105 * pi/180;  n_pinzas = 3;

% Datos de grilla
global centro filas columnas d_filas d_columnas radio color alpha;
centro = [46 0 0]; filas = 8; columnas = 3; d_filas = 4; d_columnas = 4; radio = 1.5; color = [0.5 0.5 0.5]; alpha =1;

%Almacenamiento y variables globales
global actualPos max_angle_finger robot; 
actualPos = [0 0 0 0]; max_angle_finger = 0; %Formato d1, q2 , q3, claw_state(0 cerrado, 1 abierto)

robot = crear_SCARA();
iniciar_SCARA(robot);

%% Conexion como servidor
import java.net.ServerSocket
import java.io.*

server_port = 5000;
serverSocket = ServerSocket(server_port); 

fid = fopen('Control.txt', 'w'); % Abre el archivo en modo escritura (sobreescribe)
fprintf(fid, 'Activo');
fclose(fid); % Cierra el archivo

%% Aceptar comandos externos como cadena
while true
    disp("Servidor esperando conexiones...");
    socket = serverSocket.accept();  % Espera una nueva conexión
    disp("Cliente conectado.");

    inputStream = BufferedReader(InputStreamReader(socket.getInputStream()));
    outputStream = PrintWriter(socket.getOutputStream(), true);
    while ~socket.isClosed()
        % Leer mensaje del cliente
        mensaje = char(inputStream.readLine());
        if ~isempty(str2num(mensaje))
            q_config = str2num(mensaje);
            respuesta = move_SCARA(q_config(1) ,q_config(2) ,q_config(3), q_config(4),20);
            % Enviar respuesta
            outputStream.println(respuesta);
            disp(['Comando recibido : ' mat2str(q_config)]);
        elseif strcmp(mensaje,'exit') | strcmp(mensaje,'exitserver')
            break;
        elseif strcmp(mensaje,'') 

        else
            disp('Comando invalido');
        end
        
        pause(0.5);
    end

    % Cerrar conexión con este cliente
    socket.close();
    disp("Cliente desconectado.");
    
    % Si el mensaje recibido es "exit", cerramos el servidor
    if strcmp(mensaje, "exitserver")
        break;
    end
end

serverSocket.close();
disp("Servidor cerrado.");
close;


