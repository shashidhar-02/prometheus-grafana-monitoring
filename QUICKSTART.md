# Quick Start Guide

## Step 1: Start the Monitoring System

```bash
docker-compose up -d
```

Wait for all services to start (about 1-2 minutes).

## Step 2: Verify Services

Check if all containers are running:

```bash
docker-compose ps
```

You should see all services with "Up" status.

## Step 3: Access Grafana

1. Open your browser and go to: **http://localhost:3000**
2. Login with:
   - Username: `admin`
   - Password: `admin123`
3. You may be prompted to change the password (optional)

## Step 4: View Dashboards

1. Click on the menu icon (☰) in the top-left
2. Go to **Dashboards** → **Browse**
3. You'll see two pre-configured dashboards:
   - **System Overview Dashboard** - CPU, Memory, Disk, Network metrics
   - **Application Metrics Dashboard** - Request rate, error rate, response times

## Step 5: Explore Prometheus

1. Open **http://localhost:9090**
2. Try some queries in the "Graph" tab:
   ```promql
   # CPU Usage
   100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
   
   # Memory Usage
   (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
   
   # Disk Usage
   (1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100
   ```

## Step 6: Check Targets

1. In Prometheus, go to **Status** → **Targets**
2. Verify all targets are "UP":
   - prometheus
   - node-exporter
   - cadvisor
   - nginx
   - alertmanager
   - app-metrics

## Step 7: View Alerts

1. In Prometheus, go to **Alerts**
2. You'll see all configured alert rules
3. Alerts will fire when thresholds are exceeded

## Step 8: Check Alertmanager

1. Open **http://localhost:9093**
2. You'll see active alerts here when they fire
3. Configure notification channels in `alertmanager/alertmanager.yml`

## Step 9: Generate Some Load (Optional)

Generate traffic to see metrics in action:

```bash
# On Windows PowerShell
for ($i=0; $i -lt 100; $i++) { Invoke-WebRequest -Uri "http://localhost:3001/api/users" }
for ($i=0; $i -lt 100; $i++) { Invoke-WebRequest -Uri "http://localhost:3001/api/orders" }
```

## Step 10: Customize

### Change Grafana Password

Edit `docker-compose.yml`:
```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=your-new-password
```

Then restart:
```bash
docker-compose restart grafana
```

### Add Email Alerts

Edit `alertmanager/alertmanager.yml`:
```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'your-email@gmail.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'
```

Reload alertmanager:
```bash
docker-compose restart alertmanager
```

## Troubleshooting

### Services not starting?

```bash
# Check logs
docker-compose logs -f

# Restart specific service
docker-compose restart prometheus
```

### Can't access Grafana?

```bash
# Check if container is running
docker-compose ps grafana

# Check port availability
netstat -ano | findstr :3000
```

### No metrics showing?

1. Check Prometheus targets: http://localhost:9090/targets
2. Verify exporters are running: `docker-compose ps`
3. Check exporter metrics directly:
   - http://localhost:9100/metrics (Node Exporter)
   - http://localhost:3001/metrics (App Exporter)

## Stop Everything

```bash
docker-compose down
```

## Reset Everything (including data)

```bash
docker-compose down -v
docker-compose up -d
```

---

**You're all set! 🎉**

Check the main README.md for advanced configuration and more details.
