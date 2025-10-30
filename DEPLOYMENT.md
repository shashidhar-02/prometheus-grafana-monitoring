# Deployment Guide for Cloud Servers

This guide will help you deploy the monitoring system on a cloud server (Digital Ocean, AWS, Azure, etc.).

## Prerequisites

- A cloud server (VPS/Droplet) with:
  - Ubuntu 22.04 LTS (or similar)
  - Minimum 2 CPU cores
  - 4GB RAM
  - 20GB disk space
  - Public IP address

## Step 1: Initial Server Setup

### Connect to your server

```bash
ssh root@your-server-ip
```

### Update system packages

```bash
apt update && apt upgrade -y
```

### Create a non-root user (recommended)

```bash
adduser monitoring
usermod -aG sudo monitoring
su - monitoring
```

## Step 2: Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group
sudo usermod -aG docker $USER

# Verify installation
docker --version
```

## Step 3: Install Docker Compose

```bash
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

## Step 4: Configure Firewall

```bash
# Allow SSH (important!)
sudo ufw allow 22/tcp

# Allow HTTP
sudo ufw allow 80/tcp

# Allow HTTPS (for SSL)
sudo ufw allow 443/tcp

# Allow Grafana
sudo ufw allow 3000/tcp

# Enable firewall
sudo ufw --force enable

# Check status
sudo ufw status
```

## Step 5: Deploy the Project

### Option A: Upload Files

Use SCP or SFTP to upload the project folder:

```bash
# From your local machine
scp -r prometheusgrafana monitoring@your-server-ip:~/
```

### Option B: Clone from Git

```bash
# If your project is on GitHub
git clone https://github.com/yourusername/prometheusgrafana.git
cd prometheusgrafana
```

### Option C: Manual Setup

```bash
# Create directory
mkdir -p ~/prometheusgrafana
cd ~/prometheusgrafana

# Create necessary directories
mkdir -p prometheus grafana/provisioning/{datasources,dashboards} \
  grafana/dashboards alertmanager nginx/html app-exporter
```

Then upload or create the configuration files.

## Step 6: Configure for Production

### Update docker-compose.yml

Edit the file to change default passwords:

```bash
nano docker-compose.yml
```

Change:
```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=your-secure-password-here
```

### Configure Alert Notifications

Edit alertmanager configuration:

```bash
nano alertmanager/alertmanager.yml
```

Add your email settings:
```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'your-email@gmail.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'
```

## Step 7: Start Services

```bash
cd ~/prometheusgrafana

# Pull images
docker-compose pull

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## Step 8: Access Your Monitoring System

Replace `your-server-ip` with your actual server IP:

- **Grafana**: http://your-server-ip:3000
- **Prometheus**: http://your-server-ip:9090
- **Alertmanager**: http://your-server-ip:9093
- **Nginx**: http://your-server-ip

## Step 9: Configure Domain (Optional)

### Point your domain to the server

Add an A record in your DNS settings:
```
monitoring.yourdomain.com -> your-server-ip
```

### Install Nginx as Reverse Proxy

```bash
sudo apt install nginx -y
```

Create configuration:

```bash
sudo nano /etc/nginx/sites-available/monitoring
```

Add:
```nginx
server {
    listen 80;
    server_name monitoring.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/monitoring /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Install SSL Certificate

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get certificate
sudo certbot --nginx -d monitoring.yourdomain.com

# Auto-renewal is configured automatically
```

## Step 10: Monitor Everything

### Set up automatic restarts

```bash
# Add to crontab
crontab -e
```

Add:
```
@reboot cd /home/monitoring/prometheusgrafana && /usr/local/bin/docker-compose up -d
```

### Create backup script

```bash
nano ~/backup-monitoring.sh
```

Add:
```bash
#!/bin/bash
BACKUP_DIR="/home/monitoring/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup Grafana
docker exec grafana tar czf /tmp/grafana-$DATE.tar.gz /var/lib/grafana
docker cp grafana:/tmp/grafana-$DATE.tar.gz $BACKUP_DIR/

# Backup Prometheus
docker exec prometheus tar czf /tmp/prometheus-$DATE.tar.gz /prometheus
docker cp prometheus:/tmp/prometheus-$DATE.tar.gz $BACKUP_DIR/

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup completed: $DATE"
```

Make executable:
```bash
chmod +x ~/backup-monitoring.sh
```

Schedule daily backups:
```bash
crontab -e
```

Add:
```
0 2 * * * /home/monitoring/backup-monitoring.sh >> /home/monitoring/backup.log 2>&1
```

## Monitoring Multiple Servers

### On remote servers (to be monitored):

Install Node Exporter:

```bash
# Download Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz

# Extract
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz

# Move binary
sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/

# Create systemd service
sudo nano /etc/systemd/system/node-exporter.service
```

Add:
```ini
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

Start service:
```bash
sudo systemctl daemon-reload
sudo systemctl start node-exporter
sudo systemctl enable node-exporter
```

### Update Prometheus configuration:

On your monitoring server, edit `prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'remote-server-1'
    static_configs:
      - targets: ['remote-server-ip:9100']
        labels:
          instance: 'web-server-1'

  - job_name: 'remote-server-2'
    static_configs:
      - targets: ['another-server-ip:9100']
        labels:
          instance: 'db-server-1'
```

Reload Prometheus:
```bash
docker-compose restart prometheus
```

## Security Hardening

### 1. Restrict access to ports

```bash
# Allow Grafana only from specific IPs
sudo ufw delete allow 3000
sudo ufw allow from your-office-ip to any port 3000

# Deny direct access to Prometheus
sudo ufw deny 9090
```

### 2. Enable authentication on Prometheus

Use basic auth with Nginx reverse proxy.

### 3. Regular updates

```bash
# Create update script
nano ~/update-monitoring.sh
```

Add:
```bash
#!/bin/bash
cd /home/monitoring/prometheusgrafana
docker-compose pull
docker-compose up -d
docker system prune -f
```

## Troubleshooting

### View logs
```bash
docker-compose logs -f [service-name]
```

### Restart services
```bash
docker-compose restart
```

### Check disk space
```bash
df -h
docker system df
```

### Clean up Docker
```bash
docker system prune -a
```

## Maintenance

### Weekly tasks
- Check disk usage
- Review alerts
- Check backup integrity

### Monthly tasks
- Update Docker images
- Review and optimize dashboards
- Clean old data

## Support

For issues or questions:
1. Check logs: `docker-compose logs`
2. Verify targets: http://your-server-ip:9090/targets
3. Review configuration files

---

**Your monitoring system is now production-ready! 🚀**
