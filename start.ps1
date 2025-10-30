# Start the monitoring system
Write-Host "Starting Prometheus & Grafana Monitoring System..." -ForegroundColor Green

# Check if Docker is running
$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host "✓ Docker is running" -ForegroundColor Green

# Start services
Write-Host "Starting all services..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ All services started successfully!" -ForegroundColor Green
    
    Write-Host "`nWaiting for services to initialize (30 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    Write-Host "`n=== Access your monitoring system ===" -ForegroundColor Cyan
    Write-Host "Grafana:        http://localhost:3000 (admin/admin123)" -ForegroundColor White
    Write-Host "Prometheus:     http://localhost:9090" -ForegroundColor White
    Write-Host "Alertmanager:   http://localhost:9093" -ForegroundColor White
    Write-Host "cAdvisor:       http://localhost:8080" -ForegroundColor White
    Write-Host "Nginx:          http://localhost" -ForegroundColor White
    
    Write-Host "`nTo view logs: docker-compose logs -f" -ForegroundColor Gray
    Write-Host "To stop: docker-compose down" -ForegroundColor Gray
    
    # Check service status
    Write-Host "`n=== Service Status ===" -ForegroundColor Cyan
    docker-compose ps
} else {
    Write-Host "`nError: Failed to start services" -ForegroundColor Red
    Write-Host "Check logs with: docker-compose logs" -ForegroundColor Yellow
}
