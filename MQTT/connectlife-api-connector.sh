docker run -it \
-p 8000:8000 \
-e CONNECTLIFE_LOGIN='myemail' \
-e CONNECTLIFE_PASSWORD='mypassword' \
-e LOG_LEVEL=info \
-e MQTT_HOST=172.17.0.1 \
-e MQTT_USER=mqtt_user  \
-e MQTT_PASSWORD='mqtt_password'  \
-e MQTT_PORT=1883 \
-e MQTT_SSL=false \
-e DEVICES_CONFIG='{"117":{"t_work_mode":["fan only","heat","cool","dry","auto"],"t_fan_speed":{"0":"auto","5":"super low","6":"low","7":"medium","8":"high","9":"super high"},"t_swing_direction":["straight","right","both sides","swing","left"],"t_swing_angle":{"0":"swing","2":"bottom 1\/6 ","3":"bottom 2\/6","4":"bottom 3\/6","5":"top 4\/6","6":"top 5\/6","7":"top 6\/6"},"t_eco":{"0":"off","1":"on"}}}' \
ha-connectlife-addon /bin/ash -c '/usr/bin/supervisord -c /home/app/docker-files/supervisord.conf'