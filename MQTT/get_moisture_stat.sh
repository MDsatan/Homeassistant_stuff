#!/bin/bash

# URL источника данных о влажности
SOIL_MOISTURE_URL="http://192.168.100.14"

# MQTT брокер
MQTT_BROKER="localhost" # Если Mosquitto в Docker на том же хосте
MQTT_PORT="1883"
MQTT_USER="mqtt_user" # Замените на своего пользователя MQTT
MQTT_PASSWORD="password" # Замените на свой пароль MQTT

# MQTT топик для данных
MQTT_STATE_TOPIC="homeassistant/sensor/soil_moisture_sensor/humidity/state"

# MQTT топик для Discovery
DISCOVERY_TOPIC="homeassistant/sensor/soil_moisture_sensor_humidity/config"

# MQTT топик для доступности устройства
AVAILABILITY_TOPIC="homeassistant/sensor/soil_moisture_sensor/availability"

# --- Получаем и парсим данные о влажности ---
# Используем wget для скачивания страницы и grep/sed для извлечения значения
# Загружаем страницу, ищем строку с классом "moisture-value",
# затем извлекаем числовое значение и удаляем символ '%'
HUMIDITY_VALUE=$(wget -qO- "$SOIL_MOISTURE_URL" | \
                  grep -oP '<p class="moisture-value">\K[^<]+' | \
                  sed 's/%//')

# Проверяем, удалось ли получить значение
if [ -z "$HUMIDITY_VALUE" ]; then
    echo "Ошибка: Не удалось получить значение влажности с $SOIL_MOISTURE_URL"
    # Публикуем состояние "оффлайн" или просто выходим
    mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$AVAILABILITY_TOPIC" -m "offline"
    exit 1
fi

# Публикуем состояние "онлайн" для доступности устройства
mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$AVAILABILITY_TOPIC" -m "online"

# Публикуем текущее значение влажности
mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$MQTT_STATE_TOPIC" -m "$HUMIDITY_VALUE"

# JSON-payload для MQTT Discovery
DISCOVERY_PAYLOAD='{
    "name": "Soil Moisture",
    "unique_id": "soil_moisture_sensor_humidity",
    "state_topic": "'"$MQTT_STATE_TOPIC"'",
    "unit_of_measurement": "%",
    "device_class": "humidity",
    "state_class": "measurement",
    "availability_topic": "'"$AVAILABILITY_TOPIC"'",
    "payload_available": "online",
    "payload_not_available": "offline",
    "device": {
        "identifiers": ["soil_moisture_device_id"],
        "name": "My Soil Moisture Sensor",
        "model": "Web-Based Sensor",
        "manufacturer": "Sergei Zelentsov",
        "sw_version": "1.0"
    }
}'

# Публикуем конфигурацию для Discovery (это нужно сделать только один раз или при изменении конфигурации)
mosquitto_pub -h "$MQTT_BROKER" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" -t "$DISCOVERY_TOPIC" -m "$DISCOVERY_PAYLOAD" --retain

echo "Опубликовано значение влажности: $HUMIDITY_VALUE%"