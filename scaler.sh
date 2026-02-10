#!/bin/bash
# Autonomous Scaling Logic
UP_LIMIT=10
DOWN_LIMIT=5

echo "Autonomous Scaler Active. Monitoring http://localhost/nginx_status"

while true; do
    # Fetch the 3rd number from the 3rd line of the status output
    R1=$(curl -s http://localhost/nginx_status | sed -n '3p' | awk '{print $3}')
    sleep 1
    R2=$(curl -s http://localhost/nginx_status | sed -n '3p' | awk '{print $3}')
    
    # Calculate RPS
    RPS=$((R2 - R1))
    TS=$(date '+%H:%M:%S')

    # Log only if there is traffic or if we are scaling
    if [ "$RPS" -gt 0 ]; then echo "[$TS] Traffic: $RPS RPS"; fi

    if [ "$RPS" -gt "$UP_LIMIT" ]; then
        echo "--> ALERT: High Traffic ($RPS RPS). Scaling UP to 15 containers..."
        docker compose -f ~/prod-infra/docker-compose.yml up -d --scale web_a=5 --scale web_b=5 --scale web_c=5 > /dev/null 2>&1
    elif [ "$RPS" -lt "$DOWN_LIMIT" ]; then
        COUNT=$(docker ps -q --filter "name=web" | wc -l)
        if [ "$COUNT" -gt 3 ]; then
            echo "--> INFO: Traffic normalized ($RPS RPS). Scaling DOWN to baseline..."
            docker compose -f ~/prod-infra/docker-compose.yml up -d --scale web_a=1 --scale web_b=1 --scale web_c=1 > /dev/null 2>&1
        fi
    fi
    sleep 1
done
