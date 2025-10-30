# Check status of all services
Write-Host "=== Monitoring System Status ===" -ForegroundColor Cyan

docker-compose ps

Write-Host "`n=== Checking Service Health ===" -ForegroundColor Cyan

# Check Prometheus
Write-Host "`nPrometheus:" -ForegroundColor Yellow -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -TimeoutSec 2 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host " ✓ Healthy" -ForegroundColor Green
    }
} catch {
    Write-Host " ✗ Not responding" -ForegroundColor Red
}

# Check Grafana
Write-Host "Grafana:" -ForegroundColor Yellow -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -TimeoutSec 2 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host " ✓ Healthy" -ForegroundColor Green
    }
} catch {
    Write-Host " ✗ Not responding" -ForegroundColor Red
}

# Check Node Exporter
Write-Host "Node Exporter:" -ForegroundColor Yellow -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9100/metrics" -TimeoutSec 2 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host " ✓ Healthy" -ForegroundColor Green
    }
} catch {
    Write-Host " ✗ Not responding" -ForegroundColor Red
}

# Check Alertmanager
Write-Host "Alertmanager:" -ForegroundColor Yellow -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9093/-/healthy" -TimeoutSec 2 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host " ✓ Healthy" -ForegroundColor Green
    }
} catch {
    Write-Host " ✗ Not responding" -ForegroundColor Red
}

# Check App Exporter
Write-Host "App Exporter:" -ForegroundColor Yellow -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/health" -TimeoutSec 2 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host " ✓ Healthy" -ForegroundColor Green
    }
} catch {
    Write-Host " ✗ Not responding" -ForegroundColor Red
}

Write-Host "`n=== Quick Access Links ===" -ForegroundColor Cyan
Write-Host "Grafana:      http://localhost:3000" -ForegroundColor White
Write-Host "Prometheus:   http://localhost:9090" -ForegroundColor White
Write-Host "Alertmanager: http://localhost:9093" -ForegroundColor White
