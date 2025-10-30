# Stop the monitoring system
Write-Host "Stopping Prometheus & Grafana Monitoring System..." -ForegroundColor Yellow

docker-compose down

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ All services stopped successfully!" -ForegroundColor Green
} else {
    Write-Host "Error: Failed to stop services" -ForegroundColor Red
}
