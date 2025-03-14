#include <WiFi.h>

const char* ssid = "TuSSID";
const char* password = "TuPassword";

WiFiServer server(80);

// Pines para los motores
#define STEP_Z1  25
#define DIR_Z1   26
#define STEP_T2  33
#define DIR_T2   32
#define STEP_T3  27
#define DIR_T3   14
#define STEP_CLAW  12   // Nuevo motor de la garra
#define DIR_CLAW   13   // Dirección del motor de la garra

void setup() {
    Serial.begin(115200);

    // Configurar pines de los motores
    pinMode(STEP_Z1, OUTPUT);
    pinMode(DIR_Z1, OUTPUT);
    pinMode(STEP_T2, OUTPUT);
    pinMode(DIR_T2, OUTPUT);
    pinMode(STEP_T3, OUTPUT);
    pinMode(DIR_T3, OUTPUT);
    pinMode(STEP_CLAW, OUTPUT);
    pinMode(DIR_CLAW, OUTPUT);

    // Conectar a Wi-Fi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) { delay(1000); }

    server.begin();
    Serial.println("Servidor iniciado...");
}

void moveMotor(int stepPin, int dirPin, int steps, int dir) {
    digitalWrite(dirPin, dir);
    for (int i = 0; i < steps; i++) {
        digitalWrite(stepPin, HIGH);
        delayMicroseconds(500);
        digitalWrite(stepPin, LOW);
        delayMicroseconds(500);
    }
}

// Función para mover la garra a 0° o 90°
void moveClaw(int state) {
    int steps = (state == 1) ? 500 : -500;  // 500 pasos para 90°, -500 para 0°
    int direction = (state == 1) ? HIGH : LOW;

    Serial.println(state == 1 ? "Garra a 90°" : "Garra a 0°");
    moveMotor(STEP_CLAW, DIR_CLAW, abs(steps), direction);
}

void loop() {
    WiFiClient client = server.available();

    if (client) {
        String command = client.readStringUntil('\n');
        command.trim();  // Eliminar espacios en blanco y saltos de línea
        Serial.println("Recibido: " + command);

        // Eliminar corchetes
        if (command.startsWith("[") && command.endsWith("]")) {
            command = command.substring(1, command.length() - 1);
        } else {
            Serial.println("Formato inválido");
            client.println("Error: Formato inválido");
            return;
        }

        // Extraer valores separados por ","
        int firstComma = command.indexOf(',');
        int secondComma = command.indexOf(',', firstComma + 1);
        int thirdComma = command.indexOf(',', secondComma + 1);

        if (firstComma == -1 || secondComma == -1 || thirdComma == -1) {
            Serial.println("Error en el formato");
            client.println("Error: Formato incorrecto");
            return;
        }

        int z1 = command.substring(0, firstComma).toInt();
        int theta2 = command.substring(firstComma + 1, secondComma).toInt();
        int theta3 = command.substring(secondComma + 1, thirdComma).toInt();
        int state_claw = command.substring(thirdComma + 1).toInt();

        Serial.print("z1: "); Serial.println(z1);
        Serial.print("theta2: "); Serial.println(theta2);
        Serial.print("theta3: "); Serial.println(theta3);
        Serial.print("state_claw: "); Serial.println(state_claw);

        // Convertir coordenadas absolutas a pasos
        int stepsZ1 = map(z1, 0, 200, 0, 1000);
        int stepsT2 = map(theta2, -90, 90, -500, 500);
        int stepsT3 = map(theta3, -90, 90, -500, 500);

        moveMotor(STEP_Z1, DIR_Z1, abs(stepsZ1), stepsZ1 > 0);
        moveMotor(STEP_T2, DIR_T2, abs(stepsT2), stepsT2 > 0);
        moveMotor(STEP_T3, DIR_T3, abs(stepsT3), stepsT3 > 0);

        // Mover la garra
        moveClaw(state_claw);

        // Responder al cliente
        client.println("OK");
    }
}

