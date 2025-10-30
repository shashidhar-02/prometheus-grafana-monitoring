# Prometheus & Grafana Monitoring System

A comprehensive monitoring solution using Prometheus for metrics collection and Grafana for visualization. This setup provides real-time insights into server performance, resource utilization, and application health.

## 🎯 Features

- **System Monitoring**: CPU, Memory, Disk, and Network metrics
- **Application Monitoring**: Custom application metrics with HTTP requests, response times, and error rates
- **Container Monitoring**: Docker container metrics via cAdvisor
- **Web Server Monitoring**: Nginx metrics and performance monitoring
- **Alerting System**: Comprehensive alerting rules with multiple notification channels
- **Custom Exporters**: Example custom exporter for application-specific metrics
- **Beautiful Dashboards**: Pre-configured Grafana dashboards for system and application metrics

## 📋 Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- Ports available: 80, 3000, 3001, 8080, 9090, 9093, 9100, 9113

## 🚀 Quick Start

### 1. Clone or Navigate to the Project Directory

```bash
cd prometheusgrafana
```

### 2. Start All Services

```bash
docker-compose up -d
```

This will start:
- ✅ Prometheus (port 9090)
- ✅ Grafana (port 3000)
- ✅ Node Exporter (port 9100)
- ✅ cAdvisor (port 8080)
- ✅ Alertmanager (port 9093)
- ✅ Nginx (port 80)
- ✅ Nginx Exporter (port 9113)
- ✅ Custom App Exporter (port 3001)

### 3. Access the Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | http://localhost:3000 | admin / admin123 |
| **Prometheus** | http://localhost:9090 | - |
| **Alertmanager** | http://localhost:9093 | - |
| **cAdvisor** | http://localhost:8080 | - |
| **Node Exporter** | http://localhost:9100/metrics | - |
| **Nginx** | http://localhost | - |
| **App Exporter** | http://localhost:3001/metrics | - |

### 4. View Dashboards

1. Open Grafana: http://localhost:3000
2. Login with: `admin` / `admin123`
3. Navigate to Dashboards → Browse
4. Open pre-configured dashboards:
   - System Overview Dashboard
   - Application Metrics Dashboard

## 📊 Dashboards

### System Overview Dashboard
Displays:
- CPU Usage (%)
- Memory Usage (%)
- Disk Usage (%)
- Network Traffic (receive/transmit)
- System Information (cores, memory, disk, uptime)

### Application Metrics Dashboard
Displays:
- Request Rate (requests/second)
- Error Rate (%)
- Response Time (95th percentile)
- Active Users
- Database Connections
- Business Transactions

## 🔔 Alerting

### Configured Alerts

**System Alerts:**
- High CPU Usage (>80% for 5 minutes)
- Critical CPU Usage (>95% for 2 minutes)
- High Memory Usage (>80% for 5 minutes)
- Critical Memory Usage (>95% for 2 minutes)
- Low Disk Space (<20%)
- Critical Disk Space (<10%)
- Instance Down

**Application Alerts:**
- High Request Rate (>1000 req/s)
- High Error Rate (>5%)
- Slow Response Time (>2 seconds)

**Container Alerts:**
- High Container CPU
- High Container Memory
- Container Restarts

### Configure Email Notifications

Edit `alertmanager/alertmanager.yml`:

```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'your-email@gmail.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'
```

### Configure Slack Notifications

Uncomment and configure in `alertmanager/alertmanager.yml`:

```yaml
slack_configs:
  - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
    channel: '#alerts'
```

## 🔧 Configuration

### Prometheus Configuration

Main configuration: `prometheus/prometheus.yml`

**Scraping Intervals:**
- Default: 15 seconds
- Node Exporter: 10 seconds
- Custom App: 10 seconds

**Retention Policy:**
- 30 days (configurable in docker-compose.yml)

### Adding New Exporters

#### MySQL Exporter

Add to `docker-compose.yml`:

```yaml
mysql-exporter:
  image: prom/mysqld-exporter
  environment:
    - DATA_SOURCE_NAME=user:password@(mysql:3306)/
  ports:
    - "9104:9104"
  networks:
    - monitoring
```

Add to `prometheus/prometheus.yml`:

```yaml
- job_name: 'mysql'
  static_configs:
    - targets: ['mysql-exporter:9104']
```

#### MongoDB Exporter

Add to `docker-compose.yml`:

```yaml
mongodb-exporter:
  image: percona/mongodb_exporter:latest
  environment:
    - MONGODB_URI=mongodb://mongodb:27017
  ports:
    - "9216:9216"
  networks:
    - monitoring
```

#### Redis Exporter

Add to `docker-compose.yml`:

```yaml
redis-exporter:
  image: oliver006/redis_exporter:latest
  environment:
    - REDIS_ADDR=redis:6379
  ports:
    - "9121:9121"
  networks:
    - monitoring
```

## 📈 Custom Metrics

### Creating Custom Exporters

The `app-exporter` directory contains a sample Node.js application that exposes custom metrics:

**Available Metrics:**
- `http_requests_total` - Counter for HTTP requests
- `http_request_duration_seconds` - Histogram for request duration
- `active_users` - Gauge for active users
- `database_connections` - Gauge for database connections
- `business_transactions_total` - Counter for business transactions

**Example in Node.js:**

```javascript
const promClient = require('prom-client');

const counter = new promClient.Counter({
  name: 'my_custom_metric_total',
  help: 'Description of my custom metric'
});

counter.inc(); // Increment the counter
```

**Example in Python:**

```python
from prometheus_client import Counter, start_http_server

counter = Counter('my_custom_metric_total', 'Description')
counter.inc()

start_http_server(8000)
```

## 🎯 Advanced Features

### Recording Rules

Pre-computed metrics for performance optimization. Configured in `prometheus/recording_rules.yml`.

**Benefits:**
- Faster dashboard queries
- Reduced Prometheus load
- Pre-aggregated data

### Service Discovery

For dynamic environments, configure Prometheus service discovery:

```yaml
scrape_configs:
  - job_name: 'dynamic-services'
    consul_sd_configs:
      - server: 'consul:8500'
```

### Log Aggregation with Loki

Add Loki for log aggregation:

```yaml
loki:
  image: grafana/loki:latest
  ports:
    - "3100:3100"
  networks:
    - monitoring
```

## 🔐 Security Best Practices

### 1. Change Default Passwords

Edit Grafana password in `docker-compose.yml`:

```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=your-secure-password
```

### 2. Enable Authentication

For Prometheus, use a reverse proxy with authentication:

```yaml
nginx:
  image: nginx:latest
  volumes:
    - ./nginx-auth.conf:/etc/nginx/nginx.conf
```

### 3. Use HTTPS

Configure SSL certificates in your reverse proxy.

### 4. Network Segmentation

Keep monitoring on a separate network with restricted access.

## 📊 Querying with PromQL

### Useful Queries

**CPU Usage:**
```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Memory Usage:**
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

**Request Rate:**
```promql
rate(http_requests_total[5m])
```

**Error Percentage:**
```promql
(rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])) * 100
```

**95th Percentile Response Time:**
```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

## 🛠️ Troubleshooting

### Check Service Status

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f prometheus
docker-compose logs -f grafana
```

### Restart Services

```bash
docker-compose restart
```

### Reset Everything

```bash
docker-compose down -v
docker-compose up -d
```

### Common Issues

**Grafana can't connect to Prometheus:**
- Check if Prometheus is running: `docker-compose ps prometheus`
- Verify network connectivity: `docker-compose exec grafana ping prometheus`

**No metrics showing:**
- Verify exporters are running: `curl http://localhost:9100/metrics`
- Check Prometheus targets: http://localhost:9090/targets

**Alerts not firing:**
- Check alert rules: http://localhost:9090/alerts
- Verify Alertmanager: http://localhost:9093

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)

## 🚀 Production Deployment

### On Digital Ocean / Cloud Providers

1. **Create a Droplet/VM**
   - Minimum 2 CPUs, 4GB RAM
   - Ubuntu 22.04 LTS recommended

2. **Install Docker**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```

3. **Install Docker Compose**
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

4. **Clone/Upload Project**
   ```bash
   git clone <your-repo>
   cd prometheusgrafana
   ```

5. **Configure Firewall**
   ```bash
   sudo ufw allow 22
   sudo ufw allow 80
   sudo ufw allow 3000
   sudo ufw enable
   ```

6. **Start Services**
   ```bash
   docker-compose up -d
   ```

7. **Configure Domain & SSL**
   - Point your domain to the server IP
   - Use Certbot for SSL certificates
   - Configure reverse proxy

## 📝 Maintenance

### Backup Configuration

```bash
# Backup Grafana data
docker-compose exec grafana tar czf /tmp/grafana-backup.tar.gz /var/lib/grafana
docker cp grafana:/tmp/grafana-backup.tar.gz ./backups/

# Backup Prometheus data
docker-compose exec prometheus tar czf /tmp/prometheus-backup.tar.gz /prometheus
docker cp prometheus:/tmp/prometheus-backup.tar.gz ./backups/
```

### Update Services

```bash
docker-compose pull
docker-compose up -d
```

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is open-source and available under the MIT License.

---

**Happy Monitoring! 📊🔥**
