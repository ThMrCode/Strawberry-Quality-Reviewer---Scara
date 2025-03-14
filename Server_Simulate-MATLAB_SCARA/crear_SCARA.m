%%Creacion del robot
function robot = crear_SCARA()
    % Longitudes en centimetros y angulos en radianes
    global a1 a2 a3 a4 z_max range_q2 range_q3 gripper_l1 gripper_l2 angle_finger n_pinzas;
    global max_angle_finger;
    
    % Crear el árbol del robot
    robot = rigidBodyTree('DataFormat', 'column', 'MaxNumBodies', 3);

    body_z = rigidBody('body_z');
    jnt_z = rigidBodyJoint('jnt_z', 'prismatic');
    setFixedTransform(jnt_z, trvec2tform([0 0 1]));
    jnt_z.JointAxis = [0 0 1];
    jnt_z.PositionLimits = [0, z_max];
    jnt_z.HomePosition = 0;
    body_z.Joint = jnt_z;
    addBody(robot, body_z, 'base');

    body_m = rigidBody('body_m');
    jnt_m = rigidBodyJoint('jnt_m','fixed');
    setFixedTransform(jnt_m, trvec2tform([0 0 z_max]));
    body_m.Joint = jnt_m;
    addBody(robot, body_m, 'base')

    body_q2_h = rigidBody('body_q2_h');
    jnt_q2_h = rigidBodyJoint('jnt_q2_h', 'fixed');
    setFixedTransform(jnt_q2_h, trvec2tform([a1 0 0]));
    body_q2_h.Joint = jnt_q2_h;
    addBody(robot, body_q2_h, 'body_z');

    body_q2_v = rigidBody('body_q2_v');
    jnt_q2_v = rigidBodyJoint('jnt_q2_v', 'revolute');
    setFixedTransform(jnt_q2_v, trvec2tform([0 0 -a2]));
    jnt_q2_v.JointAxis = [0 0 1];
    jnt_q2_v.PositionLimits = [-range_q2, range_q2];
    jnt_q2_v.HomePosition = 0;
    body_q2_v.Joint = jnt_q2_v;
    addBody(robot, body_q2_v, 'body_q2_h');

    body_q3 = rigidBody('body_q3');
    jnt_q3 = rigidBodyJoint('jnt_q3', 'revolute');
    setFixedTransform(jnt_q3, trvec2tform([a3 0 0]));
    jnt_q3.JointAxis = [0 0 1];
    jnt_q3.PositionLimits = [-range_q3, range_q3];
    jnt_q3.HomePosition = 0;
    body_q3.Joint = jnt_q3;
    addBody(robot, body_q3, 'body_q2_v');

    body_gripper = rigidBody('body_gripper');
    jnt_gripper = rigidBodyJoint('jnt_gripper', 'fixed');
    setFixedTransform(jnt_gripper, trvec2tform([a4 0 0]));
    body_gripper.Joint = jnt_gripper;
    addBody(robot, body_gripper, 'body_q3');

    l_segment = sqrt(gripper_l1^2 + gripper_l2^2 - 2 * gripper_l1 * gripper_l2 * cos(angle_finger));
    angle_aux1 = acos( (gripper_l1^2 + l_segment^2 - gripper_l2^2) / (2 * gripper_l1 * l_segment) );
    angle_aux2 = pi - angle_aux1 - angle_finger;
    max_angle_finger = pi/2 - angle_aux1;

    for i = 1:n_pinzas
        finger = rigidBody(['finger_' num2str(i)]);
        jnt_finger = rigidBodyJoint(['jnt_finger_' num2str(i)], 'revolute');
        setFixedTransform(jnt_finger, trvec2tform([0 0 0])); % En la base del gripper
        setFixedTransform(jnt_finger, axang2tform([0 0 1 2*pi*i/n_pinzas]));

        % cos(2*pi*i/n_pinzas) sin(2*pi*i/n_pinzas)

        % Configurar la dirección de movimiento (hacia afuera)
        jnt_finger.JointAxis = [1 0 0]; % Direcciones en 120°
        jnt_finger.HomePosition = 0; % Cerrado inicialmente
        jnt_finger.PositionLimits = [0 pi/2]; % Límite de apertura

        finger.Joint = jnt_finger;
        addBody(robot, finger, 'body_gripper'); % Unir al agarre

        % Configuracion del dedo1
        claw1 = rigidBody(['claw_' num2str(i) '_1']);
        jnt_claw1 = rigidBodyJoint(['jnt_claw1_' num2str(i)], 'fixed');
        setFixedTransform(jnt_claw1, trvec2tform([0 gripper_l1 * sin(angle_aux1) -gripper_l1 * cos(angle_aux1)]));
        claw1.Joint = jnt_claw1;
        addBody(robot, claw1, ['finger_' num2str(i)]);

        % Configuracion del dedo2
        claw2 = rigidBody(['claw_' num2str(i) '_2']);
        jnt_claw2 = rigidBodyJoint(['jnt_claw2_' num2str(i)], 'fixed');
        setFixedTransform(jnt_claw2, trvec2tform([0 -gripper_l2 * sin(angle_aux2) -gripper_l2 * cos(angle_aux2)]));
        claw2.Joint = jnt_claw2;
        addBody(robot, claw2, ['claw_' num2str(i) '_1']);
    end
end
