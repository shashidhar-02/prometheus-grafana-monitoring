# Backup Prometheus and Grafana data
$BackupDir = "backups"
$Date = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "Creating backup..." -ForegroundColor Green

# Create backup directory
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

# Backup Grafana
Write-Host "Backing up Grafana data..." -ForegroundColor Yellow
docker exec grafana tar czf /tmp/grafana-$Date.tar.gz /var/lib/grafana 2>$null
docker cp grafana:/tmp/grafana-$Date.tar.gz "$BackupDir/grafana-$Date.tar.gz"

# Backup Prometheus
Write-Host "Backing up Prometheus data..." -ForegroundColor Yellow
docker exec prometheus tar czf /tmp/prometheus-$Date.tar.gz /prometheus 2>$null
docker cp prometheus:/tmp/prometheus-$Date.tar.gz "$BackupDir/prometheus-$Date.tar.gz"

Write-Host "`n✓ Backup complete!" -ForegroundColor Green
Write-Host "Backup files saved in: $BackupDir" -ForegroundColor Cyan
Get-ChildItem $BackupDir -Filter "*$Date*" | Format-Table Name, Length, LastWriteTime
