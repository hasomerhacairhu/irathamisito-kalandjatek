#include <Arduino.h>
#include <ESP_FlexyStepper.h>
#include <ArduinoLog.h>
#include <CommandParser.h>

// HardwareSerial for Commands
#define RXD2 16
#define TXD2 17
HardwareSerial CommandSerial(1);

// Constants & Pin Assignments
static const int STEP_PINS[5] =    {4,  22, 13, 18, 25};
static const int DIR_PINS[5]  =    {2,  21, 12, 15, 26};
static const int ENABLE_PINS[5] =  {5,  23, 14, 19, 27};
static const int ENDSTOP_PINS[5] = {32, 33, 34, 35, 36};

// Stepper Motor Objects
ESP_FlexyStepper steppers[5];

// Global Configuration
bool motorDirectionInverted[5] = { false, false, false, false, false };

// CommandParser object
typedef CommandParser<16, 4, 10, 32, 64> MyCommandParser;
MyCommandParser parser;

// Function Prototypes
void handleMove(MyCommandParser::Argument *args, char *response);
void handleStop(MyCommandParser::Argument *args, char *response);
void handleHome(MyCommandParser::Argument *args, char *response);
void handleSetPosition(MyCommandParser::Argument *args, char *response);
void handleDirection(MyCommandParser::Argument *args, char *response);

void setupSteppers();
void setupEndstops();
void processSerialCommand(HardwareSerial* serial);
void moveMotor(int motorIndex, long steps);
void stopMotor(int motorIndex);
void homeMotor(int motorIndex);
void setPosition(int motorIndex, long position);
void setDirectionInverted(int motorIndex, bool inverted);
bool isEndstopTriggered(int motorIndex);

//---------------------------------------------------------
// Setup
//---------------------------------------------------------
void setup() {
  Serial.begin(115200);
  while (!Serial) { }
  Log.begin(LOG_LEVEL_TRACE, &Serial);

  // Initialize secondary serial
  CommandSerial.begin(115200, SERIAL_8N1, RXD2, TXD2);

  // Register each command with the same callback (handleCommand).
  // In handleCommand(), we distinguish them by the first argument.
    // Register commands separately
    parser.registerCommand("MOVE", "ii",       &handleMove);
    parser.registerCommand("STOP", "i",        &handleStop);
    parser.registerCommand("HOME", "i",        &handleHome);
    parser.registerCommand("SETPOSITION", "i", &handleSetPosition);
    parser.registerCommand("DIR", "ii",        &handleDirection);

  setupSteppers();
  setupEndstops();

  Log.noticeln("Firmware started. Ready to receive commands on Serial lines.");
}

//---------------------------------------------------------
// Main loop
//---------------------------------------------------------
void loop() {
  // Keep stepper motors running smoothly (non-blocking)
  for (int i = 0; i < 5; i++) {
    steppers[i].processMovement(); 
  }

  // Check both primary and secondary serial for commands
  // Process command from secondary serial
  processSerialCommand(&CommandSerial);
  // Process command from primary serial
  processSerialCommand(&Serial);

}

//---------------------------------------------------------
// Stepper Setup
//---------------------------------------------------------
void setupSteppers() {
  for (int i = 0; i < 5; i++) {
    steppers[i].connectToPins(STEP_PINS[i], DIR_PINS[i]);
    if (ENABLE_PINS[i] != -1) {
      pinMode(ENABLE_PINS[i], OUTPUT);
      digitalWrite(ENABLE_PINS[i], LOW);
    }
    steppers[i].setStepsPerRevolution(200);
    steppers[i].setSpeedInStepsPerSecond(800);
    steppers[i].setAccelerationInStepsPerSecondPerSecond(800);

    // If needed, call startAsService(0) to run the stepper in a timed interrupt
    steppers[i].startAsService(0);
  }
}

//---------------------------------------------------------
// Endstop Setup
//---------------------------------------------------------
void setupEndstops() {
  for (int i = 0; i < 5; i++) {
    pinMode(ENDSTOP_PINS[i], INPUT_PULLUP);
  }
}

//---------------------------------------------------------
// Process Commands from a given HardwareSerial
//---------------------------------------------------------
void processSerialCommand(HardwareSerial* serial) {
  //Optional debugging: see if data is available
  //Serial.print("Available bytes: ");
  //Serial.println(serial->available());

  if (serial->available()) {
    // Read the incoming line
    String command = serial->readStringUntil('\n');
    Serial.print("Received: ");
    Serial.println(command);


    // Process the command
    char response[MyCommandParser::MAX_RESPONSE_SIZE];
    parser.processCommand(command.c_str(), response);  // 'handleCommand' may be called here

    // Optionally, you can print the parser's response
    Serial.print("Response: ");
    Serial.println(response);
  }
}






//---------------------------------------------------------
// Command Handlers
//---------------------------------------------------------
void handleMove(MyCommandParser::Argument *args, char *response) {
    int motorIndex = (int)args[0].asInt64;
    long steps = (long)args[1].asInt64;
    moveMotor(motorIndex, steps);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void handleStop(MyCommandParser::Argument *args, char *response) {
    int motorIndex = (int)args[0].asInt64;
    stopMotor(motorIndex);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void handleHome(MyCommandParser::Argument *args, char *response) {
    int motorIndex = (int)args[0].asInt64;
    homeMotor(motorIndex);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void handleSetPosition(MyCommandParser::Argument *args, char *response) {
    int motorIndex = (int)args[0].asInt64;
    long position = (long)args[1].asInt64;
    setPosition(motorIndex, position);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}

void handleDirection(MyCommandParser::Argument *args, char *response) {
    int motorIndex = (int)args[0].asInt64;
    bool normalDir = (args[1].asInt64 != 0);
    setDirectionInverted(motorIndex, !normalDir);
    strlcpy(response, "success", MyCommandParser::MAX_RESPONSE_SIZE);
}






//---------------------------------------------------------
// Helper Functions
//---------------------------------------------------------
void moveMotor(int motorIndex, long steps) {
  if (motorIndex < 0 || motorIndex >= 5) {
    Log.errorln("Invalid motor index for MOVE: %d", motorIndex);
    return;
  }
  Log.traceln("MOVE motor %d by %d steps", motorIndex, steps);

  // Check if direction is inverted
  if (motorDirectionInverted[motorIndex]) {
    steps = -steps;
  }

  long currentPos = steppers[motorIndex].getCurrentPositionInSteps();
  long targetPos  = currentPos + steps;
  steppers[motorIndex].setTargetPositionInSteps(targetPos);
}

void stopMotor(int motorIndex) {
  if (motorIndex < 0 || motorIndex >= 5) {
    Log.errorln("Invalid motor index for STOP: %d", motorIndex);
    return;
  }
  Log.traceln("STOP motor %d", motorIndex);

  long currentPos = steppers[motorIndex].getCurrentPositionInSteps();
  steppers[motorIndex].setTargetPositionInSteps(currentPos);
}

void homeMotor(int motorIndex) {
  if (motorIndex < 0 || motorIndex >= 5) {
    Log.errorln("Invalid motor index for HOME: %d", motorIndex);
    return;
  }
  Log.traceln("HOME motor %d", motorIndex);

  int direction = (motorDirectionInverted[motorIndex]) ? 1 : -1;
  long bigMove  = 20000;  // enough steps to guarantee hitting the endstop
  steppers[motorIndex].setTargetPositionInSteps(
      steppers[motorIndex].getCurrentPositionInSteps() + direction * bigMove
  );

  // Blocking homing approach (simple example):
  while (!isEndstopTriggered(motorIndex)) {
    steppers[motorIndex].processMovement();
  }

  stopMotor(motorIndex);
  steppers[motorIndex].setCurrentPositionInSteps(0);
  Log.traceln("Homing complete for motor %d, position set to 0", motorIndex);
}

void setPosition(int motorIndex, long position) {
  if (motorIndex < 0 || motorIndex >= 5) {
    Log.errorln("Invalid motor index for SETPOSITION: %d", motorIndex);
    return;
  }
  Log.traceln("SETPOSITION motor %d to %ld", motorIndex, position);
  steppers[motorIndex].setCurrentPositionInSteps(position);
}

void setDirectionInverted(int motorIndex, bool inverted) {
  if (motorIndex < 0 || motorIndex >= 5) {
    Log.errorln("Invalid motor index for DIR: %d", motorIndex);
    return;
  }
  motorDirectionInverted[motorIndex] = inverted;
  Log.traceln("DIR motor %d set to %s", motorIndex, (inverted ? "INVERTED" : "NORMAL"));
}

bool isEndstopTriggered(int motorIndex) {
  return (digitalRead(ENDSTOP_PINS[motorIndex]) == LOW);  // Adjust if needed
}
