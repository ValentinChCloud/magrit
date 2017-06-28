#!/bin/bash

sed -i "s|PROXY_PREFIX|${PROXY_PREFIX}|" /proxy.conf;
cp /proxy.conf /etc/nginx/sites-enabled/default;



#Magrit 
service redis-server start && gunicorn "magrit_app.app:create_app()" --bind 0.0.0.0:9999 --worker-class aiohttp.worker.GunicornUVLoopWebWorker --workers 1 --chdir /home/app/magrit/ &


#TODO :Chec k if magrit is up to work
#STATUS=$(curl --include 'http://127.0.0.1:3333' 2>&1)
#while [[ ${STATUS} =~ "refused" ]]
#do
#  echo "Waiting for openrefine: $STATUS \n"
#  STATUS=$(curl --include 'http://127.0.0.1:3333' 2>&1)
#  sleep 4
#done

# Launch traffic monitor which will automatically kill the container if traffic
# stops
/monitor_traffic.sh &
#And nginx in foreground mode.
nginx -g 'daemon off;'
