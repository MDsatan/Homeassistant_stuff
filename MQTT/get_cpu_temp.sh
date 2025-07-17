#!/bin/bash

# Путь к файлу температуры CPU на хосте Raspberry Pi
CPU_TEMP_FILE="/sys/class/thermal/thermal_zone0/temp"

# MQTT брокер (теперь это localhost, так как скрипт запускается на хосте)
MQTT_BROKER="localhost" # Если Mosquitto в Docker на том же хосте
MQTT_PORT="1883"
MQTT_USER="mqtt_user" # Замените на своего пользователя MQTT
MQTT_PASSWORD="password" # Замените на свой пароль MQTT

# MQTT топик для данных
MQTT_STATE_TOPIC="homeassistant/sensor/raspberry_pi_server/cpu_temperature/state"

# MQTT топик для Discovery
DISCOVERY_TOPIC="homeassistant/sensor/raspberry_pi_server_cpu_temp/config"

# MQTT топик для доступности устройства
AVAILABILITY_TOPIC="homeassistant/sensor/raspberry_pi_server/availability"

# Читаем температуру и форматируем
RAW_TEMP=$(cat "$CPU_TEMP_FILE")
TEMP_C=$(echo "scale=1; $RAW_TEMP / 1000" | bc)

# Публикуем состояние "онлайн" для доступности устройства
mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$AVAILABILITY_TOPIC" -m "online"

# Публикуем текущее значение температуры
mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$MQTT_STATE_TOPIC" -m "$TEMP_C"

# JSON-payload для MQTT Discovery
DISCOVERY_PAYLOAD='{
    "name": "CPU Temperature",
    "unique_id": "raspberry_pi_cpu_temperature",
    "state_topic": "'"$MQTT_STATE_TOPIC"'",
    "unit_of_measurement": "°C",
    "device_class": "temperature",
    "state_class": "measurement",
    "availability_topic": "'"$AVAILABILITY_TOPIC"'",
    "payload_available": "online",
    "payload_not_available": "offline",
    "device": {
        "identifiers": ["raspberry_pi_server_id"],
        "name": "Raspberry Pi Server",
        "model": "Raspberry Pi",
        "manufacturer": "Raspberry Pi Foundation",
        "sw_version": "'$(uname -r)'"
    }
}'

# Публикуем конфигурацию для Discovery (это нужно сделать только один раз или при изменении конфигурации)
mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$DISCOVERY_TOPIC" -m "$DISCOVERY_PAYLOAD" --retain