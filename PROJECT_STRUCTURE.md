# Project Structure

```
prometheusgrafana/
│
├── docker-compose.yml              # Main orchestration file for all services
│
├── prometheus/                     # Prometheus configuration
│   ├── prometheus.yml             # Main Prometheus config with scrape jobs
│   ├── alerts.yml                 # Alert rules for monitoring
│   └── recording_rules.yml        # Pre-computed recording rules
│
├── grafana/                       # Grafana configuration
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   └── prometheus.yml     # Auto-configure Prometheus datasource
│   │   └── dashboards/
│   │       └── default.yml        # Dashboard provisioning config
│   └── dashboards/                # Pre-built dashboards (JSON)
│       ├── system-overview.json   # System metrics dashboard
│       ├── application-metrics.json
│       └── docker-containers.json
│
├── alertmanager/                  # Alert management
│   └── alertmanager.yml          # Alert routing and notifications
│
├── nginx/                        # Nginx web server
│   ├── nginx.conf               # Nginx configuration with stub_status
│   └── html/
│       └── index.html           # Landing page with quick links
│
├── app-exporter/                # Custom Node.js exporter
│   ├── index.js                # Main exporter application
│   ├── package.json            # Node.js dependencies
│   └── Dockerfile              # Container image definition
│
├── scripts/                     # Utility scripts (PowerShell)
│   ├── start.ps1               # Start all services
│   ├── stop.ps1                # Stop all services
│   ├── status.ps1              # Check service health
│   ├── generate-load.ps1       # Generate test traffic
│   └── backup.ps1              # Backup data volumes
│
├── docs/                        # Documentation
│   ├── README.md               # Main documentation
│   ├── QUICKSTART.md           # Quick start guide
│   ├── DEPLOYMENT.md           # Cloud deployment guide
│   ├── CUSTOM_EXPORTERS.md     # Exporter development guide
│   └── PROMQL_EXAMPLES.md      # PromQL query examples
│
├── .env.example                # Environment variables template
├── .gitignore                  # Git ignore rules
│
└── backups/                    # Backup storage (created automatically)
```

## Service Ports

| Service | Port | Purpose |
|---------|------|---------|
| Nginx | 80 | Web server / Landing page |
| Grafana | 3000 | Visualization dashboards |
| App Exporter | 3001 | Custom application metrics |
| cAdvisor | 8080 | Container metrics UI |
| Prometheus | 9090 | Metrics collection & queries |
| Alertmanager | 9093 | Alert management |
| Node Exporter | 9100 | System metrics |
| Nginx Exporter | 9113 | Nginx metrics |

## Docker Volumes

| Volume | Purpose |
|--------|---------|
| prometheus_data | Persistent storage for Prometheus time-series data |
| grafana_data | Persistent storage for Grafana dashboards and settings |
| alertmanager_data | Persistent storage for Alertmanager state |

## Configuration Files Explained

### docker-compose.yml
Defines all services, their dependencies, networking, and volumes.

### prometheus/prometheus.yml
- Global configuration (scrape interval, retention)
- Alert manager integration
- Scrape job definitions for all exporters
- Service discovery configuration

### prometheus/alerts.yml
Alert rules organized by category:
- System alerts (CPU, memory, disk)
- Application alerts (errors, latency)
- Container alerts
- Service availability alerts

### prometheus/recording_rules.yml
Pre-computed metrics for:
- Faster dashboard queries
- Complex aggregations
- Frequently used calculations

### alertmanager/alertmanager.yml
- Alert routing logic
- Notification channels (email, Slack)
- Alert grouping and deduplication
- Inhibition rules

### grafana/provisioning/
Auto-configuration files that Grafana reads on startup:
- Datasources: Connects to Prometheus automatically
- Dashboards: Loads pre-built dashboards

### app-exporter/index.js
Custom Node.js application that:
- Exposes /metrics endpoint
- Tracks HTTP requests, response times
- Simulates business metrics
- Provides example instrumentation

## Data Flow

```
[System] → [Node Exporter] → [Prometheus] → [Grafana]
                                    ↓
[Containers] → [cAdvisor] ──────→ [Prometheus]
                                    ↓
[Nginx] → [Nginx Exporter] ─────→ [Prometheus]
                                    ↓
[App] → [App Exporter] ─────────→ [Prometheus]
                                    ↓
                            [Alertmanager] → [Notifications]
```

## Metric Types in Use

### Counters (always increase)
- `http_requests_total`
- `container_restart_count`

### Gauges (can go up or down)
- `active_users`
- `node_memory_MemAvailable_bytes`
- `container_memory_usage_bytes`

### Histograms (distributions)
- `http_request_duration_seconds`
- Response time buckets

## Key Features

✅ **System Monitoring**: CPU, Memory, Disk, Network
✅ **Container Monitoring**: Docker containers via cAdvisor
✅ **Application Monitoring**: Custom metrics and HTTP tracing
✅ **Web Server Monitoring**: Nginx performance metrics
✅ **Alerting**: Comprehensive alert rules with notifications
✅ **Visualization**: Pre-built Grafana dashboards
✅ **Recording Rules**: Optimized query performance
✅ **Auto-Configuration**: Grafana datasources and dashboards
✅ **Custom Exporters**: Example exporter for custom metrics
✅ **Backup Scripts**: Automated backup utilities

## Customization Points

### Add New Services to Monitor
1. Add service to `docker-compose.yml`
2. Add scrape job to `prometheus/prometheus.yml`
3. Create dashboard in Grafana
4. Add alerts to `prometheus/alerts.yml`

### Add Database Monitoring
Uncomment relevant sections in:
- `docker-compose.yml` (MySQL/MongoDB/Redis exporter)
- `prometheus/prometheus.yml` (scrape configuration)

### Modify Alert Rules
Edit `prometheus/alerts.yml`:
- Adjust thresholds
- Add new alert rules
- Modify alert duration

### Configure Notifications
Edit `alertmanager/alertmanager.yml`:
- Add email settings
- Configure Slack webhooks
- Set up PagerDuty integration

### Create Custom Dashboards
1. Design in Grafana UI
2. Export as JSON
3. Save to `grafana/dashboards/`

## Security Considerations

🔐 **Change default passwords** in docker-compose.yml
🔐 **Configure firewall** rules for production
🔐 **Use HTTPS** with reverse proxy
🔐 **Enable authentication** on Prometheus
🔐 **Restrict network access** to monitoring ports
🔐 **Regular backups** of data volumes
🔐 **Update images** regularly for security patches

## Troubleshooting Quick Reference

**Service won't start:**
```powershell
docker-compose logs <service-name>
```

**Prometheus can't scrape target:**
```powershell
# Check if target is accessible
curl http://localhost:9100/metrics
```

**Grafana can't connect to Prometheus:**
```powershell
# Verify network connectivity
docker-compose exec grafana ping prometheus
```

**No metrics appearing:**
1. Check Prometheus targets: http://localhost:9090/targets
2. Verify exporter is running: `docker-compose ps`
3. Check exporter endpoint: `curl http://localhost:9100/metrics`

**Reset everything:**
```powershell
docker-compose down -v
docker-compose up -d
```

## Next Steps

1. ✅ **Start services**: `.\start.ps1`
2. ✅ **Access Grafana**: http://localhost:3000
3. ✅ **View dashboards**: Explore pre-built dashboards
4. ✅ **Generate load**: `.\generate-load.ps1`
5. ✅ **Configure alerts**: Edit alertmanager.yml
6. ✅ **Deploy to cloud**: Follow DEPLOYMENT.md
7. ✅ **Create custom metrics**: Follow CUSTOM_EXPORTERS.md

---

**Happy Monitoring! 📊**
