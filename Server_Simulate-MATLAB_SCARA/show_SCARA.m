function H = show_SCARA(tree_robot, config, n_clawls)
    H = gobjects();
    
    % Plataforma
    H = [H drawCylinder([0 0 -3], [0 0 0], 12, [0.1, 0.1, 0.1], 'k')];

    tform = getTransform(tree_robot, config, 'body_m');
    pos_body_m = (tform(1:3, 4))';
    H = [H drawPrism([0 0 0], pos_body_m, 4, 4, [0.5, 0.5, 0.5], 'k')];
    
    tform = getTransform(tree_robot, config, 'body_z');
    pos_body_z = (tform(1:3, 4))';
    
    tform = getTransform(tree_robot, config, 'body_q2_h');
    pos_body_q2_h = (tform(1:3, 4))';
    H = [H drawCylinder(pos_body_z, pos_body_q2_h, 2, [0.5, 0.5, 0.7], 'k')];
    
    H = [H drawCube(pos_body_q2_h, 5, [0.5, 0.5, 0.7], 'k')];
    
    tform = getTransform(tree_robot, config, 'body_q2_v');
    pos_body_q2_v = (tform(1:3, 4))';
    H = [H drawCylinder(pos_body_q2_v, pos_body_q2_h, 2, [0.5, 0.5, 0.7], 'k')];
    
    H = [H drawSphere(pos_body_q2_v, 2.5, [0.1, 0.7, 0.1], 'k')];
    
    tform = getTransform(tree_robot, config, 'body_q3');
    pos_body_q3 = (tform(1:3, 4))';
    H = [H drawCylinder(pos_body_q2_v, pos_body_q3, 2, [0.5, 0.5, 0.7], 'k')];
    
    H = [H drawSphere(pos_body_q3, 2.5, [0.1, 0.7, 0.1], 'k')];
    
    tform = getTransform(tree_robot, config, 'body_gripper');
    pos_body_gripper = (tform(1:3, 4))';
    H = [H drawCylinder(pos_body_gripper, pos_body_q3, 1.5, [0.5, 0.5, 0.7], 'k')];
    
    H = [H drawCube(pos_body_gripper, 3.5, [0.5, 0.5, 0.7], 'k')];
    
    for i = 1:n_clawls
        tform = getTransform(tree_robot, config, ['claw_' num2str(i) '_1']);
        pos_body_clawl1 = (tform(1:3, 4))';
        H = [H drawCylinder(pos_body_gripper, pos_body_clawl1, 1, [0.5, 0.5, 0.7], 'k')];
        
        H = [H drawCube(pos_body_clawl1, 2.5, [0.5, 0.5, 0.7], 'k')];
        
        tform = getTransform(tree_robot, config, ['claw_' num2str(i) '_2']);
        pos_body_clawl2 = (tform(1:3, 4))';
        H = [H drawCylinder(pos_body_clawl2, pos_body_clawl1, 1, [0.5, 0.5, 0.7], 'k')];
        
        H = [H drawCube(pos_body_clawl2, 2.5, [0.5, 0.5, 0.7], 'k')];
    end
end

%% Funciones de dibujo
function h = drawCylinder(p1, p2, radius, color, edgeColor)
    h = gobjects();

    [X, Y, Z] = cylinder(radius, 20);  % Crear cilindro en el origen
    height = norm(p2 - p1);  % Longitud del cilindro
    Z = Z * height;  % Escalar altura del cilindro
    v = (p2 - p1) / height;  % Vector de dirección normalizado
    z_axis = [0 0 1];  % Dirección original del cilindro en MATLAB
    % Determinar la rotación necesaria
    if norm(cross(z_axis, v)) ~= 0
        rot_axis = cross(z_axis, v);  % Eje de rotación
        rot_angle = acos(dot(z_axis, v));  % Ángulo de rotación
        R = axang2rotm([rot_axis rot_angle]);  % Matriz de rotación
    else
        R = eye(3);  % No se necesita rotación si ya está alineado
    end
    % Aplicar transformación al cilindro
    for i = 1:size(X, 1)
        for j = 1:size(X, 2)
            point = R * [X(i, j); Y(i, j); Z(i, j)];  % Rotar el punto
            X(i, j) = point(1) + p1(1);
            Y(i, j) = point(2) + p1(2);
            Z(i, j) = point(3) + p1(3);
        end
    end

    % Dibujar cilindro
    h = [h surf(X, Y, Z, 'FaceColor', color, 'EdgeColor', 'none')];  

    % --- TAPAR EXTREMOS ---
    theta = linspace(0, 2*pi, 20);  % Ángulos para el círculo
    circle = radius * [cos(theta); sin(theta); zeros(1, numel(theta))];  % Círculo plano en XY

    % Transformar círculos a la orientación del cilindro
    circle1 = R * circle + p1';  % Disco en p1
    circle2 = R * circle + p2';  % Disco en p2

    % Dibujar tapas correctamente
    h = [h patch(circle1(1, :), circle1(2, :), circle1(3, :), color, 'EdgeColor', 'none')]; % Extremo 1
    h = [h patch(circle2(1, :), circle2(2, :), circle2(3, :), color, 'EdgeColor', 'none')]; % Extremo 2

    % --- AGREGAR CONTORNOS ---
    h = [h plot3(circle1(1, :), circle1(2, :), circle1(3, :), 'Color', edgeColor, 'LineWidth', 1.5)]; % Borde inferior
    h = [h plot3(circle2(1, :), circle2(2, :), circle2(3, :), 'Color', edgeColor, 'LineWidth', 1.5)]; % Borde superior
end

function h = drawPrism(p1, p2, radius, sides, color, edgeColor)
    h = gobjects();

    % --- CREAR POLÍGONO BASE ---
    theta = linspace(pi/sides, 2*pi + pi/sides, sides+1);  % Ángulos de los vértices
    base = radius * [cos(theta); sin(theta); zeros(1, numel(theta))];  % Coordenadas XY

    % --- VECTOR DE DIRECCIÓN ---
    height = norm(p2 - p1);  % Altura del prisma
    v = (p2 - p1) / height;  % Vector normalizado
    z_axis = [0 0 1];  % Eje Z estándar
    
    % Determinar rotación
    if norm(cross(z_axis, v)) ~= 0
        rot_axis = cross(z_axis, v);  % Eje de rotación
        rot_angle = acos(dot(z_axis, v));  % Ángulo de rotación
        R = axang2rotm([rot_axis rot_angle]);  % Matriz de rotación
    else
        R = eye(3);  % Sin rotación si ya está alineado
    end

    % --- TRANSFORMAR VÉRTICES ---
    base1 = R * base + p1';  % Base inferior
    base2 = R * base + p2';  % Base superior

    % --- DIBUJAR BASES ---
    h = [h patch(base1(1, :), base1(2, :), base1(3, :), color, 'EdgeColor', edgeColor)]; % Base inferior
    h = [h patch(base2(1, :), base2(2, :), base2(3, :), color, 'EdgeColor', edgeColor)]; % Base superior

    % --- DIBUJAR CARAS LATERALES ---
    for i = 1:sides
        x = [base1(1, i), base1(1, i+1), base2(1, i+1), base2(1, i)];
        y = [base1(2, i), base1(2, i+1), base2(2, i+1), base2(2, i)];
        z = [base1(3, i), base1(3, i+1), base2(3, i+1), base2(3, i)];
        h = [h patch(x, y, z, color, 'EdgeColor', edgeColor)];  % Cara lateral
    end

    % --- DIBUJAR ARISTAS LATERALES ---
    for i = 1:sides
        h = [h plot3([base1(1, i), base2(1, i)], ...
              [base1(2, i), base2(2, i)], ...
              [base1(3, i), base2(3, i)], 'Color', edgeColor, 'LineWidth', 1.5)];
    end
end

function h = drawSphere(center, radius, color, edgeColor)
    % center -> Centro de la esfera [x, y, z]
    % radius -> Radio de la esfera
    % color -> Color de la superficie
    % edgeColor -> Color de las líneas de malla

    [X, Y, Z] = sphere(20);  % Crear malla esférica (20 divisiones)
    X = X * radius + center(1);
    Y = Y * radius + center(2);
    Z = Z * radius + center(3);

    % Dibujar la esfera
    h = surf(X, Y, Z, 'FaceColor', color, 'EdgeColor', 'none');
end

function h = drawCube(p, sideLength, color, edgeColor)
    % p -> Centro del cubo [x, y, z]
    % sideLength -> Longitud de los lados del cubo
    % color -> Color de las caras
    % edgeColor -> Color de los bordes

    % Obtener los vértices del cubo centrado en p
    halfSide = sideLength / 2;
    
    % Definir los 8 vértices del cubo
    vertices = [
        -1, -1, -1;
         1, -1, -1;
         1,  1, -1;
        -1,  1, -1;
        -1, -1,  1;
         1, -1,  1;
         1,  1,  1;
        -1,  1,  1
    ] * halfSide + p;

    % Definir las caras del cubo (índices de los vértices)
    faces = [
        1 2 3 4; % Cara inferior
        5 6 7 8; % Cara superior
        1 2 6 5; % Cara frontal
        2 3 7 6; % Cara derecha
        3 4 8 7; % Cara trasera
        4 1 5 8  % Cara izquierda
    ];

    % Dibujar el cubo
    h = patch('Vertices', vertices, 'Faces', faces, ...
          'FaceColor', color, 'EdgeColor', edgeColor);
end