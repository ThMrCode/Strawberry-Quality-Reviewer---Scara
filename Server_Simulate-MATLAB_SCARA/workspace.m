function workspace(tree_robot, num_steps, alpha)
    global z_max range_q2 range_q3 a2 a3 a4;
    vertices = [];

    a = sqrt(a3^2 + a4^2 - 2 * a3 * a4 * cos(pi - range_q3));
    angle = acos((a^2 + a3^2 - a4^2) / (2 * a3 * a4));
    
    
    for i = 1:num_steps
        q2_temp = angle - (range_q2 + angle)* i / num_steps;
        tform = getTransform(tree_robot, [0; q2_temp; -range_q3; 0; 0; 0;], 'body_gripper');
        nueva_coord = (tform(1:3, 4))';
        vertices = [vertices; nueva_coord];
    end
    
    for i = 1:num_steps
        q3_temp = -range_q3 + i * (range_q3) / num_steps;
        tform = getTransform(tree_robot, [0; -range_q2; q3_temp; 0; 0; 0;], 'body_gripper');
        nueva_coord = (tform(1:3, 4))';
        vertices = [vertices; nueva_coord];
    end
    
    for i = 1:num_steps
        q2_temp = -range_q2 + i * (2 * range_q2) / num_steps;
        tform = getTransform(tree_robot, [0; q2_temp; 0; 0; 0; 0;], 'body_gripper');
        nueva_coord = (tform(1:3, 4))';
        vertices = [vertices; nueva_coord];
    end
    
    for i = 1:num_steps
        q3_temp = 0 + range_q3 * i / num_steps;
        tform = getTransform(tree_robot, [0; range_q2; q3_temp; 0; 0; 0;], 'body_gripper');
        nueva_coord = (tform(1:3, 4))';
        vertices = [vertices; nueva_coord];
    end
    
    for i = 1:num_steps
        q2_temp = range_q2 - (range_q2 + angle) * i / num_steps;
        tform = getTransform(tree_robot, [0; q2_temp; range_q3; 0; 0; 0;], 'body_gripper');
        nueva_coord = (tform(1:3, 4))';
        vertices = [vertices; nueva_coord];
    end
    
    vertices_superior = vertices;
    vertices_superior(:,3) = -a2 + z_max;
    
    faces = 1:size(vertices, 1);
    patch('Vertices', vertices, 'Faces', faces, 'FaceColor', 'cyan', 'FaceAlpha', alpha, 'EdgeColor', 'none');
    patch('Vertices', vertices_superior, 'Faces', faces, 'FaceColor', 'cyan', 'FaceAlpha', alpha, 'EdgeColor', 'none');
    
    vertices_totales = [vertices ;vertices_superior];

    n = size(vertices, 1);
    faces = [];
    for i = 1:n
        i_next = mod(i, n) + 1; % Índice del siguiente punto
        faces = [faces; i, i_next, i_next + n, i + n];
    end
    patch('Vertices', vertices_totales, 'Faces', faces, 'FaceColor', 'cyan', 'FaceAlpha', alpha, 'EdgeColor', 'none');
    
end