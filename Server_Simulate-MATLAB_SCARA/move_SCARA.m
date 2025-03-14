%% Funciones de movimiento
function message = move_SCARA(d1, q2, q3, claw_state , num_steps)
    H_holder = [];
    message = '';
    global actualPos max_angle_finger robot z_max range_q2 range_q3 n_pinzas handle_final;
    if ~((0 <= d1) & (d1 <= z_max) & (abs(q2) <= range_q2) & (abs(q3) <= range_q3))
        message = 'Robot >>> Posicion fuera de los limites';
    else
        if claw_state == actualPos(4)
            if claw_state
                claw_initial = max_angle_finger;
                claw_final =  max_angle_finger;
            else
                claw_initial = 0;
                claw_final =  0;
            end
        else
            if claw_state
                claw_initial = 0;
                claw_final =  max_angle_finger;
            else
                claw_initial = max_angle_finger;
                claw_final =  0;
            end
        end

        q_initial = [actualPos(1); actualPos(2); actualPos(3); claw_initial;claw_initial; claw_initial;];   % Posición inicial [θ2, θ3, z1]
        q_final = [d1; q2; q3; claw_final; claw_final; claw_final];

        q_traj = zeros(6, num_steps);
        for i = 1:6
            q_traj(i, :) = linspace(q_initial(i), q_final(i), num_steps);
        end
        
        for j = 1:length(handle_final)
            delete(handle_final(j));
        end

        for i = 1:num_steps
            show(robot, q_traj(:, i), 'PreservePlot', false);
            for j = 1:length(H_holder)
                delete(H_holder(j));
            end
            H_holder = show_SCARA(robot, q_traj(:, i), n_pinzas);
            drawnow;
            pause(0.0005);  % Pequeña pausa para suavizar la animación
        end
        
        handle_final = H_holder;
        
        %Actualizar posicion
        actualPos(1) = d1 ; actualPos(2) = q2 ; actualPos(3) = q3; actualPos(4) = claw_state;
    end
    message = 'Robot >>> Movimiento hecho';
end

