function iniciar_SCARA(robot)
    global handle_final n_pinzas;
    global centro filas columnas d_filas d_columnas radio color alpha;
    figure;
    show(robot);
    title('SCARA en MATLAB');
    view(3);
    xlim([-15 85]); 
    ylim([-45 45]); 
    zlim([-21 69]);
    view(45, 60);
    hold on;
    handle_final = show_SCARA(robot, [0;0;0;0;0;0;], n_pinzas);
    workspace(robot, 10, 0.2);
    placa_malla(centro, filas, columnas, d_filas, d_columnas, radio, color, alpha)
    drawnow;
end