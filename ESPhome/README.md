# Technical Documentation: Smart Irrigation System (v2.0)

## 1. System Architecture
This project is an IoT-based automated watering system using the **ESP32-C3 Super Mini**. It features a "Fail-Safe" logic design, where the watering process is managed by a timed script, ensuring the pump never stays on indefinitely.

## 2. Hardware Components
* **MCU:** ESP32-C3 Super Mini.
* **Relay:** 5V Single-Channel Relay Module (Low-Level Trigger).
* **Pump:** 3-5V DC Submersible Pump.
* **Safety Component:** 10k Ohm Pull-up Resistor (Recommended).

## 3. Electrical Connections

### 3.1 Control Side (Microcontroller)
| ESP32-C3 Pin | Relay Pin | Description |
| :--- | :--- | :--- |
| **5V** | **VCC** | Power for relay coil |
| **G (GND)** | **GND** | Common ground |
| **GPIO 8** | **IN** | Control signal (Open Drain mode) |

> **Hardware Safety Note:** Connect a **10kΩ resistor** between **GPIO 8** and **5V**. This acts as a Pull-up resistor to keep the relay OFF while the ESP32 is booting or being flashed.

### 3.2 Load Side (Power & Pump)
The system uses the **NO (Normally Open)** terminal to ensure the pump is disconnected by default.

* **Pump (+):** Connected directly to **5V**.
* **Pump (-):** Connected to Relay **NO**.
* **Relay COM:** Connected to **G (GND)**.

---

## 4. Logical Flow & UI
The device exposes only two entities to Home Assistant and Google Home to prevent UI clutter:

1.  **Watering Duration (Number Slider):** Sets the cycle length (Default: 3s, Range: 3-12s).
2.  **Sprinkler Switch (Template Switch):** A virtual toggle that triggers the internal watering script.

### Sequence of Operation:
1. User toggles the **Sprinkler Switch** to 'ON'.
2. The `water_cycle_script` starts:
    * Sets the Switch UI state to 'ON' immediately.
    * Activates the Relay.
    * Delays for the duration specified by the slider.
    * Deactivates the Relay.
    * Sets the Switch UI state back to 'OFF'.

---

## 5. Firmware Configuration (ESPHome)

```yaml
# Safety: Ensure pump is OFF immediately upon boot
on_boot:
  priority: 1000
  then:
    - output.turn_off: relay_pin
    - lambda: 'id(sprinkler_logic_switch).publish_state(false);'

# Output definition (Hidden from UI)
output:
  - platform: gpio
    pin: 
      number: 8
      mode:
        output: true
        open_drain: true
    id: relay_pin

# Timer setting
number:
  - platform: template
    name: "Watering Duration"
    id: water_duration
    initial_value: 3
    # ... (rest of config)

# Virtual switch for UI & Google Home
switch:
  - platform: template
    name: "Sprinkler Switch"
    id: sprinkler_logic_switch
    turn_on_action:
      - script.execute: water_cycle_script
    turn_off_action:
      - script.stop: water_cycle_script
      - output.turn_off: relay_pin
      - lambda: 'id(sprinkler_logic_switch).publish_state(false);'
