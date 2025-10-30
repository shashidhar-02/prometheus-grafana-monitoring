# Command Reference Guide

Quick reference for all commands to manage your monitoring system.

---

## 🚀 Starting & Stopping

### Start All Services
```powershell
.\start.ps1
# OR
docker-compose up -d
```

### Stop All Services
```powershell
.\stop.ps1
# OR
docker-compose down
```

### Restart All Services
```powershell
docker-compose restart
```

### Restart Specific Service
```powershell
docker-compose restart prometheus
docker-compose restart grafana
docker-compose restart alertmanager
```

---

## 📊 Status & Health Checks

### Check All Services Status
```powershell
.\status.ps1
# OR
docker-compose ps
```

### View Service Logs (All)
```powershell
docker-compose logs -f
```

### View Specific Service Logs
```powershell
docker-compose logs -f prometheus
docker-compose logs -f grafana
docker-compose logs -f alertmanager
docker-compose logs -f node-exporter
docker-compose logs -f cadvisor
docker-compose logs -f nginx
docker-compose logs -f app-exporter
```

### View Last 50 Log Lines
```powershell
docker-compose logs --tail=50 prometheus
```

### Check Docker Resource Usage
```powershell
docker stats
```

### Check Disk Usage
```powershell
docker system df
```

---

## 🔄 Updates & Maintenance

### Pull Latest Images
```powershell
docker-compose pull
```

### Update and Restart
```powershell
docker-compose pull
docker-compose up -d
```

### Rebuild Custom Exporter
```powershell
docker-compose build app-exporter
docker-compose up -d app-exporter
```

### Clean Up Unused Images
```powershell
docker system prune -a
```

### Remove Volumes (⚠️ Deletes Data!)
```powershell
docker-compose down -v
```

---

## 💾 Backup & Restore

### Backup Data
```powershell
.\backup.ps1
```

### Manual Backup - Grafana
```powershell
docker exec grafana tar czf /tmp/grafana-backup.tar.gz /var/lib/grafana
docker cp grafana:/tmp/grafana-backup.tar.gz ./backups/
```

### Manual Backup - Prometheus
```powershell
docker exec prometheus tar czf /tmp/prometheus-backup.tar.gz /prometheus
docker cp prometheus:/tmp/prometheus-backup.tar.gz ./backups/
```

### Restore Grafana Data
```powershell
docker cp ./backups/grafana-backup.tar.gz grafana:/tmp/
docker exec grafana tar xzf /tmp/grafana-backup.tar.gz -C /
docker-compose restart grafana
```

### Restore Prometheus Data
```powershell
docker cp ./backups/prometheus-backup.tar.gz prometheus:/tmp/
docker exec prometheus tar xzf /tmp/prometheus-backup.tar.gz -C /
docker-compose restart prometheus
```

---

## 🧪 Testing & Load Generation

### Generate Test Load
```powershell
.\generate-load.ps1
```

### Manual Load Generation
```powershell
# Generate 100 requests
for ($i=0; $i -lt 100; $i++) {
    Invoke-WebRequest -Uri "http://localhost:3001/api/users"
}
```

### Test Metrics Endpoint
```powershell
Invoke-WebRequest -Uri "http://localhost:9100/metrics"
Invoke-WebRequest -Uri "http://localhost:3001/metrics"
Invoke-WebRequest -Uri "http://localhost:9113/metrics"
```

### Check Service Health
```powershell
# Prometheus
Invoke-WebRequest -Uri "http://localhost:9090/-/healthy"

# Grafana
Invoke-WebRequest -Uri "http://localhost:3000/api/health"

# Alertmanager
Invoke-WebRequest -Uri "http://localhost:9093/-/healthy"

# App Exporter
Invoke-WebRequest -Uri "http://localhost:3001/health"
```

---

## 🔍 Debugging

### Enter Container Shell
```powershell
docker-compose exec prometheus sh
docker-compose exec grafana bash
docker-compose exec app-exporter sh
```

### Check Container Filesystem
```powershell
# List Prometheus data
docker-compose exec prometheus ls -lh /prometheus

# List Grafana data
docker-compose exec grafana ls -lh /var/lib/grafana
```

### Inspect Container
```powershell
docker inspect prometheus
docker inspect grafana
```

### Check Network Connectivity
```powershell
# From Grafana to Prometheus
docker-compose exec grafana ping prometheus

# From Prometheus to Node Exporter
docker-compose exec prometheus ping node-exporter
```

### View Container Environment Variables
```powershell
docker-compose exec grafana env
```

---

## ⚙️ Configuration

### Reload Prometheus Config
```powershell
# Method 1: Send signal
docker-compose exec prometheus kill -HUP 1

# Method 2: API call
Invoke-WebRequest -Method POST -Uri "http://localhost:9090/-/reload"

# Method 3: Restart
docker-compose restart prometheus
```

### Reload Alertmanager Config
```powershell
# Method 1: Send signal
docker-compose exec alertmanager kill -HUP 1

# Method 2: API call
Invoke-WebRequest -Method POST -Uri "http://localhost:9093/-/reload"

# Method 3: Restart
docker-compose restart alertmanager
```

### Edit Configuration Files
```powershell
# Edit Prometheus config
notepad prometheus\prometheus.yml

# Edit Alert rules
notepad prometheus\alerts.yml

# Edit Alertmanager config
notepad alertmanager\alertmanager.yml
```

### Validate Configuration
```powershell
# Check Prometheus config
docker-compose exec prometheus promtool check config /etc/prometheus/prometheus.yml

# Check Alert rules
docker-compose exec prometheus promtool check rules /etc/prometheus/alerts.yml
```

---

## 📈 Prometheus Commands

### Query API
```powershell
# Simple query
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=up"

# Query with time range
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=rate(http_requests_total[5m])"

# Query range
$body = @{
    query = "up"
    start = "2024-01-01T00:00:00Z"
    end = "2024-01-01T01:00:00Z"
    step = "15s"
}
Invoke-WebRequest -Method POST -Uri "http://localhost:9090/api/v1/query_range" -Body $body
```

### List Targets
```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/targets" | ConvertFrom-Json
```

### List Alert Rules
```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/rules" | ConvertFrom-Json
```

### List Active Alerts
```powershell
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/alerts" | ConvertFrom-Json
```

### View Metadata
```powershell
# List all metrics
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/label/__name__/values" | ConvertFrom-Json

# Get metric metadata
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/metadata?metric=up" | ConvertFrom-Json
```

---

## 📊 Grafana Commands

### Grafana API Calls
```powershell
# Create API token first in Grafana UI: Configuration → API Keys

# List dashboards
$headers = @{Authorization = "Bearer YOUR_API_TOKEN"}
Invoke-WebRequest -Uri "http://localhost:3000/api/search" -Headers $headers | ConvertFrom-Json

# Create snapshot
Invoke-WebRequest -Method POST -Uri "http://localhost:3000/api/snapshots" `
  -Headers $headers -ContentType "application/json" -Body '{"dashboard": {...}}'

# Get org details
Invoke-WebRequest -Uri "http://localhost:3000/api/org" -Headers $headers | ConvertFrom-Json
```

### Export Dashboard
```powershell
# Via UI: Dashboard → Settings → JSON Model → Copy

# Via API:
$headers = @{Authorization = "Bearer YOUR_API_TOKEN"}
Invoke-WebRequest -Uri "http://localhost:3000/api/dashboards/uid/DASHBOARD_UID" `
  -Headers $headers | ConvertFrom-Json
```

### Import Dashboard
```powershell
# Copy JSON file to grafana/dashboards/
# Restart Grafana or wait for auto-reload
docker-compose restart grafana
```

---

## 🚨 Alertmanager Commands

### View Active Alerts
```powershell
Invoke-WebRequest -Uri "http://localhost:9093/api/v2/alerts" | ConvertFrom-Json
```

### Silence Alert
```powershell
$body = @{
    matchers = @(
        @{name = "alertname"; value = "HighCPUUsage"; isRegex = $false}
    )
    startsAt = (Get-Date).ToString("o")
    endsAt = (Get-Date).AddHours(1).ToString("o")
    createdBy = "admin"
    comment = "Planned maintenance"
} | ConvertTo-Json

Invoke-WebRequest -Method POST -Uri "http://localhost:9093/api/v2/silences" `
  -ContentType "application/json" -Body $body
```

### List Silences
```powershell
Invoke-WebRequest -Uri "http://localhost:9093/api/v2/silences" | ConvertFrom-Json
```

### Delete Silence
```powershell
Invoke-WebRequest -Method DELETE -Uri "http://localhost:9093/api/v2/silence/SILENCE_ID"
```

---

## 🔧 Docker Compose Commands

### View Compose Config
```powershell
docker-compose config
```

### Scale Service
```powershell
# Not typically used for monitoring, but available
docker-compose up -d --scale app-exporter=3
```

### Remove Specific Service
```powershell
docker-compose rm -s -v prometheus
```

### Recreate Containers
```powershell
docker-compose up -d --force-recreate
```

### View Container Ports
```powershell
docker-compose port grafana 3000
docker-compose port prometheus 9090
```

---

## 📁 File Operations

### List Configuration Files
```powershell
Get-ChildItem -Recurse -Include *.yml,*.yaml,*.json
```

### Find in Files
```powershell
Get-ChildItem -Recurse | Select-String -Pattern "scrape_interval"
```

### Copy Configuration
```powershell
Copy-Item prometheus\prometheus.yml prometheus\prometheus.yml.backup
```

### Compare Configurations
```powershell
Compare-Object (Get-Content prometheus.yml) (Get-Content prometheus.yml.backup)
```

---

## 🌐 Network Commands

### Check Port Availability
```powershell
# Check if port is in use
netstat -ano | findstr :3000
netstat -ano | findstr :9090
```

### Test Network Connectivity
```powershell
Test-NetConnection -ComputerName localhost -Port 3000
Test-NetConnection -ComputerName localhost -Port 9090
```

### List Docker Networks
```powershell
docker network ls
docker network inspect prometheusgrafana_monitoring
```

---

## 🛠️ Troubleshooting Commands

### Fix: Grafana Won't Start
```powershell
# Check logs
docker-compose logs grafana

# Reset permissions
docker-compose down
docker volume rm prometheusgrafana_grafana_data
docker-compose up -d
```

### Fix: Prometheus Can't Scrape Targets
```powershell
# Check if target is accessible
curl http://localhost:9100/metrics

# Check Prometheus config
docker-compose exec prometheus promtool check config /etc/prometheus/prometheus.yml

# View targets status
Start-Process "http://localhost:9090/targets"
```

### Fix: Out of Disk Space
```powershell
# Check disk usage
docker system df

# Clean up
docker system prune -a --volumes

# Reduce Prometheus retention
# Edit docker-compose.yml: --storage.tsdb.retention.time=7d
docker-compose up -d
```

### Fix: High Memory Usage
```powershell
# Check container resource usage
docker stats

# Restart specific service
docker-compose restart prometheus

# Reduce scrape intervals in prometheus.yml
```

---

## 📝 Common PromQL Queries (Command Line)

### Query CPU Usage
```powershell
$query = "100 - (avg by(instance) (rate(node_cpu_seconds_total{mode='idle'}[5m])) * 100)"
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=$query"
```

### Query Memory Usage
```powershell
$query = "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=$query"
```

### Query Request Rate
```powershell
$query = "rate(http_requests_total[5m])"
Invoke-WebRequest -Uri "http://localhost:9090/api/v1/query?query=$query"
```

---

## 🎯 Quick Access URLs

### Open in Browser
```powershell
# Grafana
Start-Process "http://localhost:3000"

# Prometheus
Start-Process "http://localhost:9090"

# Prometheus Targets
Start-Process "http://localhost:9090/targets"

# Prometheus Alerts
Start-Process "http://localhost:9090/alerts"

# Alertmanager
Start-Process "http://localhost:9093"

# cAdvisor
Start-Process "http://localhost:8080"

# Node Exporter Metrics
Start-Process "http://localhost:9100/metrics"

# App Exporter Metrics
Start-Process "http://localhost:3001/metrics"

# Nginx
Start-Process "http://localhost"
```

---

## 📋 Installation Commands

### Install Docker (if not installed)
```powershell
# Download and run Docker Desktop installer
Start-Process "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
```

### Install Docker Compose (Usually included with Docker Desktop)
```powershell
# Verify installation
docker-compose --version
```

---

## 💡 Useful Aliases (Add to PowerShell Profile)

```powershell
# Edit your PowerShell profile
notepad $PROFILE

# Add these aliases:
function Start-Monitoring { Set-Location C:\Users\s9409\Downloads\prometheusgrafana; .\start.ps1 }
function Stop-Monitoring { Set-Location C:\Users\s9409\Downloads\prometheusgrafana; .\stop.ps1 }
function Check-Monitoring { Set-Location C:\Users\s9409\Downloads\prometheusgrafana; .\status.ps1 }
function Logs-Prometheus { docker-compose logs -f prometheus }
function Logs-Grafana { docker-compose logs -f grafana }

Set-Alias -Name mon-start -Value Start-Monitoring
Set-Alias -Name mon-stop -Value Stop-Monitoring
Set-Alias -Name mon-status -Value Check-Monitoring
```

Then use:
```powershell
mon-start
mon-stop
mon-status
```

---

**Pro Tip**: Save frequently used commands in a script file for quick access! 🚀
