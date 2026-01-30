# Technical Documentation: Smart Irrigation System (ESP32-C3)

## 1. System Overview
This project is an automated water pump controller based on the **ESP32-C3 Super Mini** and a **5V Relay Module**. It is designed to be integrated into Home Assistant via ESPHome, providing a fail-safe mechanism for indoor plant watering.

## 2. Component List
* **Controller:** ESP32-C3 Super Mini.
* **Actuator:** 5V Single-Channel Relay Module (Low Level Trigger).
* **Load:** DC Water Pump (3-5V).
* **Power Source:** 5V via ESP32 USB-C port.

## 3. Wiring Diagram

### 3.1 Control Logic (Low Voltage)
Connections between the microcontroller and the relay module.

| ESP32-C3 Pin | Relay Module Pin | Description |
| :--- | :--- | :--- |
| **5V (VCC)** | **VCC** | Power for the relay coil (Direct from USB) |
| **G (GND)** | **GND** | Common Ground |
| **GPIO 8** | **IN** | Control signal (Configured as Open Drain) |

### 3.2 Power Load (High Voltage/Pump)
The pump's power line is interrupted by the relay to act as a switch. 

* **Positive Line (+):**
    * Connect **5V** from ESP32 directly to the **Positive (+)** wire of the pump.
* **Negative Line (-):**
    * Connect **G (GND)** from ESP32 to the Relay **COM** (Center terminal).
    * Connect the **Negative (-)** wire of the pump to the Relay **NO** (Normally Open) terminal.

> **Safety Note:** Always use the **NO** terminal. In the event of a power failure or controller reset, the circuit will remain open, preventing accidental flooding.



---

## 4. Software Configuration (ESPHome)

To ensure the 3.3V logic of the ESP32-C3 can effectively switch the 5V relay coil without "latching" issues, the `open_drain` mode is utilized.

```yaml
switch:
  - platform: gpio
    pin: 
      number: 8
      mode:
        output: true
        open_drain: true  # Essential for 3.3V to 5V signal stability
    id: pump_relay
    name: "Water Pump"
    inverted: false       # Set to match your relay's trigger logic
    restore_mode: ALWAYS_OFF
