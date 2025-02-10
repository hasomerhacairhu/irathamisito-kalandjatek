#include <Arduino.h>
#include <ESP_FlexyStepper.h>
#include <ArduinoLog.h>
#include <CommandParser.h>
#include <TaskScheduler.h>
#include <ArduinoJson.h> // Include ArduinoJson library

// HardwareSerial for Commands
#define RXD2 16
#define TXD2 17
#define MAX_STEP 7000
#define LIMIT_SWITCH_POSITION 0
HardwareSerial CommandSerial(1);
Scheduler ts;

static const int STEP_PINS[5] = {22, 4, 18, 13, 26};
static const int DIR_PINS[5] = {21, 0, 19, 12, 15};
static const int ENABLE_PINS[5] = {23, 2, 5, 14, 27};
static const int ENDSTOP_PINS[5] = {25, 34, 35, 32, 33};

// Stepper Motor Objects
ESP_FlexyStepper steppers[5];

// Global Configuration
bool motorDirectionInverted[5] = {false, false, false, false, false};
bool isHoming[5] = {false, false, false, false, false};

// CommandParser object
typedef CommandParser<16, 4, 10, 32, 64> MyCommandParser;
MyCommandParser parser;

// Function Prototypes
void handleMove(MyCommandParser::Argument *args, char *response);
void handleGoto(MyCommandParser::Argument *args, char *response);
void handleStop(MyCommandParser::Argument *args, char *response);
void handleHome(MyCommandParser::Argument *args, char *response);
void handleSetPosition(MyCommandParser::Argument *args, char *response);
void handleDirection(MyCommandParser::Argument *args, char *response);
void handleSpeed(MyCommandParser::Argument *args, char *response);

void setupSteppers();
void setupEndstops();
void processSerialCommand(HardwareSerial *serial);
void moveMotor(int motorIndex, long steps);
void goTo(int motorIndex, long targetPos);
void stopMotor(int motorIndex);
void homeMotor(int motorIndex);
void setPosition(int motorIndex, long position);
void setDirectionInverted(int motorIndex, bool inverted);
bool isEndstopTriggered(int motorIndex);
void processMovement();
void processSerial();
void watchHoming();
void reportMotorPositions();

Task tProcessSerial(100, TASK_FOREVER, &processSerial, &ts, true);
Task tProcessMovement(TASK_IMMEDIATE, TASK_FOREVER, &processMovement, &ts, true);
Task tWatchHoming(TASK_IMMEDIATE, TASK_FOREVER, &watchHoming, &ts, false);
Task tReportMotorPositions(1000, TASK_FOREVER, &reportMotorPositions, &ts, true);

//---------------------------------------------------------
// Setup
//---------------------------------------------------------
void setup()
{
    Serial.begin(115200);
    while (!Serial)
    {
    }
    Log.begin(LOG_LEVEL_TRACE, &Serial);

    // Initialize secondary serial
    CommandSerial.begin(115200, SERIAL_8N1, RXD2, TXD2);

    // Register commands separately
    parser.registerCommand("MOVE", "id", &handleMove);
    parser.registerCommand("STOP", "i", &handleStop);
    parser.registerCommand("HOME", "i", &handleHome);
    parser.registerCommand("SETPOSITION", "i", &handleSetPosition);
    parser.registerCommand("DIR", "id", &handleDirection);
    parser.registerCommand("SPEED", "id", &handleSpeed); // ✅ New Command Added
    parser.registerCommand("GOTO", "id", &handleGoto);   // ✅ New Command

    setupSteppers();
    setupEndstops();

    Log.noticeln("Firmware started. Ready to receive commands on Serial lines.");
}

//---------------------------------------------------------
// Main loop
//---------------------------------------------------------
void loop()
{
    ts.execute();
}

void processMovement()
{
    // Keep stepper motors running smoothly (non-blocking)
    for (int i = 0; i < 5; i++)
    {
        steppers[i].processMovement();
    }
}

void processSerial()
{
    // Check both primary and secondary serial for commands
    // Process command from secondary serial
    processSerialCommand(&CommandSerial);
    // Process command from primary serial
    processSerialCommand(&Serial);
}

//---------------------------------------------------------
// Stepper Setup
//---------------------------------------------------------
void setupSteppers()
{
    for (int i = 0; i < 5; i++)
    {
        steppers[i].connectToPins(STEP_PINS[i], DIR_PINS[i]);
        if (ENABLE_PINS[i] != -1)
        {
            pinMode(ENABLE_PINS[i], OUTPUT);
            digitalWrite(ENABLE_PINS[i], LOW);
        }
        steppers[i].setStepsPerRevolution(200);
        steppers[i].setSpeedInStepsPerSecond(500);
        steppers[i].setAccelerationInStepsPerSecondPerSecond(800);
        steppers[i].setDecelerationInStepsPerSecondPerSecond(800);
        // steppers[i].setLimitPosition(MAX_STEP);

        // If needed, call startAsService(0) to run the stepper in a timed interrupt
        // steppers[i].startAsService(1);
    }
}

//---------------------------------------------------------
// Endstop Setup
//---------------------------------------------------------
void setupEndstops()
{
    for (int i = 0; i < 5; i++)
    {
        pinMode(ENDSTOP_PINS[i], INPUT_PULLUP);
    }
}

//---------------------------------------------------------
// Process Commands from a given HardwareSerial
//---------------------------------------------------------
void processSerialCommand(HardwareSerial *serial)
{
    // Optional debugging: see if data is available
    // Serial.print("Available bytes: ");
    // Serial.println(serial->available());

    if (serial->available())
    {
        // Read the incoming line
        String command = serial->readStringUntil('\n');
        Serial.print("Received: ");
        Serial.println(command);

        // Process the command
        char response[MyCommandParser::MAX_RESPONSE_SIZE];
        parser.processCommand(command.c_str(), response); // 'handleCommand' may be called here

        // Optionally, you can print the parser's response
        Serial.print("Response: ");
        Serial.println(response);
    }
}

//---------------------------------------------------------
// Command Handlers
//---------------------------------------------------------
void handleMove(MyCommandParser::Argument *args, char *response)
{
    int motorIndex = (int)args[0].asInt64;
    long steps = (long)args[1].asDouble;
    moveMotor(motorIndex, steps);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void handleGoto(MyCommandParser::Argument *args, char *response)
{
    int motorIndex = (int)args[0].asInt64;  // First argument: motor index
    long steps = (long)args[1].asDouble;
    goTo(motorIndex, steps);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void handleStop(MyCommandParser::Argument *args, char *response)
{
    int motorIndex = (int)args[0].asInt64;
    stopMotor(motorIndex);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void handleHome(MyCommandParser::Argument *args, char *response)
{
    int motorIndex = (int)args[0].asInt64;
    homeMotor(motorIndex);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void handleSetPosition(MyCommandParser::Argument *args, char *response)
{
    int motorIndex = (int)args[0].asInt64;
    long position = (long)args[1].asDouble;
    setPosition(motorIndex, position);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void handleDirection(MyCommandParser::Argument *args, char *response)
{
    int motorIndex = (int)args[0].asInt64;
    bool normalDir = (args[1].asInt64 != 0);
    setDirectionInverted(motorIndex, !normalDir);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void handleSpeed(MyCommandParser::Argument *args, char *response)
{
    int motorIndex = (int)args[0].asInt64; // First argument: motor index
    float speed = (float)args[1].asDouble; // Second argument: speed in steps per second

    if (motorIndex < 0 || motorIndex >= 5)
    {
        Log.errorln("Invalid motor index for SPEED: %d", motorIndex);
        strlcpy(response, "failure", MyCommandParser::MAX_RESPONSE_SIZE);
        return;
    }

    if (speed < 1)
    { // Prevent setting speed too low
        Log.warningln("Speed too low, setting minimum safe speed.");
        speed = 1.0;
    }

    // ✅ Set the speed of the motor
    steppers[motorIndex].setSpeedInStepsPerSecond(speed);

    Log.traceln("SPEED motor %d set to %.2f steps per second", motorIndex, speed);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void reportMotorPositions()
{
    StaticJsonDocument<200> jsonDoc; // Create a JSON document (size 200 bytes)

    // Add motor positions to JSON
    for (int i = 0; i < 5; i++)
    {
        jsonDoc["motor" + String(i + 1)] = steppers[i].getCurrentPositionInSteps();
    }

    // Convert JSON to a string and send it via CommandSerial
    String jsonString;
    serializeJson(jsonDoc, jsonString);
    CommandSerial.println(jsonString);
    Log.traceln(jsonString.c_str());
}

//---------------------------------------------------------
// Helper Functions
//---------------------------------------------------------
void moveMotor(int motorIndex, long steps)
{

    long currentPos = steppers[motorIndex].getCurrentPositionInSteps();
    long targetPos = currentPos + steps;

    goTo(motorIndex, targetPos);
}

void goTo(int motorIndex, long targetPos)
{
    if (motorIndex < 0 || motorIndex >= 5)
    {
        Log.errorln("Invalid motor index for MOVE: %d", motorIndex);
        return;
    }
    // ✅ Prevent moves beyond the max travel limit
    if (targetPos > MAX_STEP)
    {
        targetPos = MAX_STEP;
        Log.warningln("MOVE command exceeded limit. Setting motor %d to max position %d.", motorIndex, MAX_STEP);
    }
    else if (targetPos < 0)
    {
        targetPos = 0;
        Log.warningln("MOVE command exceeded limit. Setting motor %d to min position 0.", motorIndex);
    }

    Log.traceln("MOVE motor %d to position %l", motorIndex, targetPos);
    steppers[motorIndex].setTargetPositionInSteps(targetPos);
}

void stopMotor(int motorIndex)
{
    if (motorIndex < 0 || motorIndex >= 5)
    {
        Log.errorln("Invalid motor index for STOP: %d", motorIndex);
        return;
    }
    Log.traceln("STOP motor %d", motorIndex);

    long currentPos = steppers[motorIndex].getCurrentPositionInSteps();
    steppers[motorIndex].setTargetPositionInSteps(currentPos);
}

void homeMotor(int motorIndex)
{
    if (motorIndex < 0 || motorIndex >= 5)
    {
        Log.errorln("Invalid motor index for HOME: %d", motorIndex);
        return;
    }
    Log.traceln("HOME motor %d", motorIndex);

    int direction = (motorDirectionInverted[motorIndex]) ? 1 : -1;
    long bigMove = 20000; // enough steps to guarantee hitting the endstop
    steppers[motorIndex].setTargetPositionInSteps(
        steppers[motorIndex].getCurrentPositionInSteps() + direction * bigMove);
    isHoming[motorIndex] = true;
    tWatchHoming.enableIfNot();
}

void watchHoming()
{
    bool isAnyOfMotorsHoming = false;

    for (size_t motorIndex = 0; motorIndex < 5; motorIndex++)
    {

        if (isHoming[motorIndex] && isEndstopTriggered(motorIndex))
        {
            steppers[motorIndex].setCurrentPositionInSteps(LIMIT_SWITCH_POSITION);
            isHoming[motorIndex] = false;
            stopMotor(motorIndex);
            Log.traceln("Homing complete for motor %d, position set to 0", motorIndex);
        }
        // isAnyOfMotorsHoming |= isHoming[motorIndex];
        // Only set this flag **AFTER** checking all motors
        if (isHoming[motorIndex])
        {
            isAnyOfMotorsHoming = true;
        }
    }

    if (!isAnyOfMotorsHoming)
    {

        Log.traceln("Homing routine complete for all motor(s)");
        tWatchHoming.disable();
    }
}

void setPosition(int motorIndex, long position)
{
    if (motorIndex < 0 || motorIndex >= 5)
    {
        Log.errorln("Invalid motor index for SETPOSITION: %d", motorIndex);
        return;
    }
    Log.traceln("SETPOSITION motor %d to %l", motorIndex, position);
    steppers[motorIndex].setCurrentPositionInSteps(position);
}

void setDirectionInverted(int motorIndex, bool inverted)
{
    if (motorIndex < 0 || motorIndex >= 5)
    {
        Log.errorln("Invalid motor index for DIR: %d", motorIndex);
        return;
    }
    motorDirectionInverted[motorIndex] = inverted;
    Log.traceln("DIR motor %d set to %s", motorIndex, (inverted ? "INVERTED" : "NORMAL"));
}

bool isEndstopTriggered(int motorIndex)
{
    return (digitalRead(ENDSTOP_PINS[motorIndex]) == HIGH); // Adjust if needed
}
