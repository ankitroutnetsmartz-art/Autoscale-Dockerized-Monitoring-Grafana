Autoscale-Dockerized: Dynamic Web Tier Scaling
This project implements a self-healing, auto-scaling web infrastructure using Docker Compose, Prometheus, and a custom Bash-based Scaler. It monitors incoming traffic in real-time and scales the Nginx web tier horizontally to maintain performance during load spikes.

1. System Architecture
The stack consists of a three-tier observability-driven architecture:
Traffic Layer: Nginx Load Balancer (Round-robin distribution).
Web Tier: Multiple Nginx instances (Scalable from 3 to 15 replicas).
Observability: Nginx Exporter, Prometheus (Metrics), and Grafana (Visualization).
Management: Portainer (GUI) and the Scaler Script (The Brain).

2. Prerequisites
Ubuntu 22.04/24.04 LTS
Docker & Docker Compose V2
jq and bc (for the scaling script logic)
Apache Benchmark (ab) for load testing
