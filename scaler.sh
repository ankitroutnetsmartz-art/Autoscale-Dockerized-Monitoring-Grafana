#!/bin/bash

# Configuration
PROM_URL="http://localhost:9090/api/v1/query"
QUERY="rate(nginx_http_requests_total[1m])"
UP_THRESHOLD=0.1
DOWN_THRESHOLD=0.05

while true; do
  # Fetch RPS from Prometheus
  RPS=$(curl -s -G "$PROM_URL" --data-urlencode "query=$QUERY" | jq -r '.data.result[0].value[1] // 0')
  
  # Handle empty/null results
  if [ "$RPS" == "null" ] || [ -z "$RPS" ]; then RPS=0; fi

  echo "$(date +%H:%M:%S) - Current RPS: $RPS"

  # Scaling Logic
  if (( $(echo "$RPS > $UP_THRESHOLD" | bc -l) )); then
    echo "ALERT: High Traffic detected ($RPS RPS). Scaling up to 15 replicas..."
    docker compose up -d --scale web_a=5 --scale web_b=5 --scale web_c=5
  elif (( $(echo "$RPS < $DOWN_THRESHOLD" | bc -l) )); then
    echo "Traffic low ($RPS RPS). Scaling down to baseline..."
    docker compose up -d --scale web_a=1 --scale web_b=1 --scale web_c=1
  fi

  sleep 5
done