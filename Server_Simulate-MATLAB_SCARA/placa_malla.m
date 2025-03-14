function placa_malla(center, rows, columns, d_rows, d_columns, radius_hole, color, alpha)
    alto = (1 + rows) * d_rows; ancho = (1 + columns) * d_columns;
    vertices = [];
    vertices = [vertices; center(1) - ancho/2, center(2) - alto/2, center(3)];
    vertices = [vertices; center(1) - ancho/2, center(2) + alto/2, center(3)];
    vertices = [vertices; center(1) - ancho/2 + d_columns, center(2) + alto/2, center(3)];

    for i = 1:rows
      theta = linspace(pi/2, -pi/2, 10);
      x = center(1) - ancho/2 + d_columns - radius_hole * cos(theta);
      y = center(2) + alto/2 + radius_hole * sin(theta) - d_rows * i;
      z = ones(1, 10) * center(3);
      vertices = [vertices; x(:), y(:), z(:)];
    end

    vertices = [vertices; center(1) - ancho/2 + d_columns, center(2) - alto/2, center(3)];
    faces = 1:size(vertices, 1);
    patch('Vertices', vertices, 'Faces', faces, 'FaceColor', color, 'FaceAlpha', alpha, 'EdgeColor', 'none');

    for h = 1:(columns - 1)
       vertices = [];
       point_izq_inf = [center(1) - ancho/2 + h * d_columns, center(2) - alto/2, center(3)];
       vertices = [vertices; point_izq_inf];

       for i = 1:rows
          theta = linspace(-pi/2, pi/2, 10);
          x = point_izq_inf(1) + radius_hole * cos(theta);
          y = point_izq_inf(2) + i * d_rows + radius_hole * sin(theta);
          z = ones(1, 10) * center(3);
          vertices = [vertices; x(:), y(:), z(:)];
       end

       point_izq_sup = [center(1) - ancho/2 + h * d_columns, center(2) + alto/2, center(3)];
       vertices = [vertices; point_izq_sup];
       point_der_sup = [center(1) - ancho/2 + (h + 1) * d_columns, center(2) + alto/2, center(3)];
       vertices = [vertices; point_der_sup];

       for i = 1:rows
          theta = linspace(pi/2, -pi/2, 10);
          x = point_der_sup(1) - radius_hole * cos(theta);
          y = point_der_sup(2) - i * d_rows + radius_hole * sin(theta) ;
          z = ones(1, 10) * center(3);
          vertices = [vertices; x(:), y(:), z(:)];
       end

       point_der_inf = [center(1) - ancho/2 + (h + 1) * d_columns, center(2) - alto/2, center(3)];
       vertices = [vertices; point_der_inf];
       faces = 1:size(vertices, 1);
       patch('Vertices', vertices, 'Faces', faces, 'FaceColor', color, 'FaceAlpha', alpha, 'EdgeColor', 'none');       
    end

    vertices = [];
    vertices = [vertices; center(1) + ancho/2 - d_columns, center(2) - alto/2, center(3)];

    for i = 1:rows
        theta = linspace(-pi/2, pi/2, 10);
        x = center(1) + ancho/2 - d_columns + radius_hole * cos(theta);
        y = center(2) - alto/2 + radius_hole * sin(theta) + d_rows * i;
        z = ones(1, 10) * center(3);
        vertices = [vertices; x(:), y(:), z(:)];
    end

    vertices = [vertices; center(1) + ancho/2 - d_columns, center(2) + alto/2, center(3)];
    vertices = [vertices; center(1) + ancho/2 , center(2) + alto/2, center(3)];
    vertices = [vertices; center(1) + ancho/2 , center(2) - alto/2, center(3)];
    faces = 1:size(vertices, 1);
    patch('Vertices', vertices, 'Faces', faces, 'FaceColor', color, 'FaceAlpha', alpha, 'EdgeColor', 'none');

end