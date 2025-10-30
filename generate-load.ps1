# Generate test load for the monitoring system
Write-Host "Generating test load..." -ForegroundColor Green
Write-Host "This will generate HTTP requests to create metrics`n" -ForegroundColor Yellow

$iterations = 100

# Test App Exporter
Write-Host "Sending requests to custom app..." -ForegroundColor Cyan
for ($i = 1; $i -le $iterations; $i++) {
    try {
        Invoke-WebRequest -Uri "http://localhost:3001/api/users" -UseBasicParsing -TimeoutSec 1 | Out-Null
        Invoke-WebRequest -Uri "http://localhost:3001/api/orders" -UseBasicParsing -TimeoutSec 1 | Out-Null
        
        if ($i % 10 -eq 0) {
            Write-Host "Progress: $i/$iterations requests sent" -ForegroundColor Gray
        }
    } catch {
        # Ignore errors, some are expected for error rate testing
    }
    
    Start-Sleep -Milliseconds 50
}

Write-Host "`n✓ Load generation complete!" -ForegroundColor Green
Write-Host "View metrics in:" -ForegroundColor Yellow
Write-Host "  - Grafana: http://localhost:3000" -ForegroundColor White
Write-Host "  - Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "`nTip: Wait 15-30 seconds for metrics to appear in dashboards" -ForegroundColor Gray
