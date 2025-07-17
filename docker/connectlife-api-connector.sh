#!/bin/bash
#https://github.com/bilan/connectlife-api-connector?tab=readme-ov-file#
git clone https://github.com/bilan/connectlife-api-connector.git
cd connectlife-api-connector
docker build . --build-arg='BUILD_FROM=alpine:3.20' -t ha-connectlife-addon

docker run -it \
-p 8000:8000 \
-e CONNECTLIFE_LOGIN=connectlife-login-email \
-e CONNECTLIFE_PASSWORD=your-password \
-e LOG_LEVEL=info \
-e MQTT_HOST=localhost \
-e MQTT_USER=mqtt_user  \
-e MQTT_PASSWORD=mqtt_pass  \
-e MQTT_PORT=1883 \
-e MQTT_SSL=false \
-e DEVICES_CONFIG='{"117":{"t_work_mode":["fan only","heat","cool","dry","auto"],"t_fan_speed":{"0":"auto","5":"super low","6":"low","7":"medium","8":"high","9":"super high"},"t_swing_direction":["straight","right","both sides","swing","left"],"t_swing_angle":{"0":"swing","2":"bottom 1\/6 ","3":"bottom 2\/6","4":"bottom 3\/6","5":"top 4\/6","6":"top 5\/6","7":"top 6\/6"}}}' \
ha-connectlife-addon /bin/ash -c '/usr/bin/supervisord -c /home/app/docker-files/supervisord.conf'