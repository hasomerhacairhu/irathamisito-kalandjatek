Here is the **README.md** in Markdown format:  

```markdown
# ESP32 Stepper Motor Controller Firmware

This firmware controls **5 stepper motors** using an **ESP32** with **DRV8825 drivers**.  
It receives commands via **serial communication** and supports **non-blocking movement, homing, speed control, and real-time position reporting in JSON format**.

## 🚀 Features
- **Control up to 5 stepper motors** using `ESP_FlexyStepper`
- **Non-blocking task scheduling** with `TaskScheduler`
- **Serial command interface** for real-time control
- **JSON status reporting** via `ArduinoJson`
- **Homing with limit switches**
- **Max travel limit enforced (8000 steps)**

---

## 🔧 **Hardware Setup**
### Required Components:
- **ESP32 DevKit V1**
- **5x Stepper Motors (SM-28BYJ-48-12V)**
- **5x DRV8825 Stepper Drivers**
- **5x Limit Switches**

### Pin Assignments:
| Motor | STEP Pin | DIR Pin | ENABLE Pin | ENDSTOP Pin |
|--------|---------|--------|------------|------------|
| 1      | 22      | 21     | 23         | 25         |
| 2      | 4       | 0      | 2          | 34         |
| 3      | 18      | 19     | 5          | 35         |
| 4      | 13      | 12     | 14         | 32         |
| 5      | 26      | 15     | 27         | 33         |

---

## 📥 **Installation**
### 1️⃣ **PlatformIO (Recommended)**
Add the following to your `platformio.ini`:
```ini
lib_deps =
    pkerspe/ESP-FlexyStepper
    thijse/ArduinoLog
    uberi/CommandParser
    arkhipenko/TaskScheduler
    bblanchon/ArduinoJson
```

### 2️⃣ **Arduino IDE**
- Install the following libraries from **Library Manager**:
  - `ESP-FlexyStepper`
  - `ArduinoLog`
  - `CommandParser`
  - `TaskScheduler`
  - `ArduinoJson`

---

## 🎮 **Serial Commands**
You can control the motors by sending **serial commands** via the ESP32's **USB serial** or **secondary serial (RX2/TX2)**.

### ✅ **Available Commands**
| Command         | Syntax                        | Description |
|----------------|--------------------------------|-------------|
| **MOVE**       | `MOVE [motor] [steps]`        | Moves motor relative to its current position |
| **GOTO**       | `GOTO [motor] [step]`        | Moves motor to a specific absolute step |
| **STOP**       | `STOP [motor]`               | Immediately stops the motor |
| **HOME**       | `HOME [motor]`               | Moves motor to its endstop and sets position to 1000 |
| **SETPOSITION**| `SETPOSITION [motor] [step]` | Sets the current position of the motor |
| **DIR**        | `DIR [motor] [0/1]`          | Sets the direction (0 = inverted, 1 = normal) |
| **SPEED**      | `SPEED [motor] [steps/sec]`  | Sets the motor speed |
| **STATUS**     | -                            | Prints current motor positions in JSON format |

---

## 📌 **Usage Examples**
### 1️⃣ **Move Motor 1 Forward 500 Steps**
```bash
MOVE 1 500
```

### 2️⃣ **Move Motor 2 Backward 300 Steps**
```bash
MOVE 2 -300
```

### 3️⃣ **Move Motor 3 to Absolute Position 6000**
```bash
GOTO 3 6000
```

### 4️⃣ **Stop Motor 4 Immediately**
```bash
STOP 4
```

### 5️⃣ **Home Motor 5**
```bash
HOME 5
```

### 6️⃣ **Set Current Position of Motor 1 to 0**
```bash
SETPOSITION 1 0
```

### 7️⃣ **Reverse Direction of Motor 3**
```bash
DIR 3 0
```

### 8️⃣ **Set Speed of Motor 2 to 1000 Steps/sec**
```bash
SPEED 2 1000
```

### 9️⃣ **Get Live Motor Positions (JSON)**
```bash
{ "motor1": 320, "motor2": 1200, "motor3": 550, "motor4": 0, "motor5": -800 }
```
🚀 **This updates every second!**

---

## 🛠 **Configuration**
| Setting              | Value |
|----------------------|-------|
| **Max Travel Steps** | 8000 |
| **Homing Position**  | 1000 |

🔧 **To modify these values, update the following in `#define` macros**:
```cpp
#define MAX_STEP 8000
#define LIMIT_SWITCH_POSITION 1000
```

---

## 🛠 **Development & Debugging**
- Serial logging is enabled with **ArduinoLog**.
- Use a **serial monitor** (115200 baud) to debug.
- Motors run **non-blocking** to avoid delays.

---

## 📜 **License**
MIT License

📢 **Contributions are welcome!**  
Feel free to **fork** and improve this project. 🚀  

---

## 🎯 **Next Steps**
🔹 Implement acceleration profiles  
🔹 Add external control via **WiFi/WebSockets**  
🔹 Expand to more stepper motors  

---

🚀 **Happy Coding & Motor Control!** 🎮  
```

---

### 🔥 **What This README Includes**
✅ **Project Overview**  
✅ **Hardware Setup & Pinout**  
✅ **Installation Guide (PlatformIO & Arduino IDE)**  
✅ **List of Serial Commands**  
✅ **Usage Examples**  
✅ **Live Motor Position Reporting (JSON Output)**  
✅ **Configuration Options**  

📌 **This README is fully ready for GitHub and provides complete documentation for your project!** 🚀🔥  

Let me know if you need any tweaks! 🎯