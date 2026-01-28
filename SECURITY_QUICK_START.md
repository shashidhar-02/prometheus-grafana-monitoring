# Security Checklist & Quick Start

## ✅ What's Been Fixed

- [x] **Removed hardcoded Grafana password** from docker-compose.yml
- [x] **Environment variables** now used for all sensitive data
- [x] **GitHub Actions workflows** created for automated security scanning
- [x] **.env file** properly excluded from git
- [x] **Security documentation** added

## 🚀 For Developers: Getting Started

### 1. First Time Setup

```powershell
# Clone the repo (if not already done)
git clone <repository-url>
cd prometheusgrafana

# Copy the environment template
cp .env.example .env

# Edit .env and set your own strong passwords
# (Use a secure password generator, NOT "admin123")
notepad .env
```

### 2. Running Locally

```powershell
# Load environment variables and start services
docker-compose up -d

# Verify Grafana is running
# Login at http://localhost:3000 with credentials from .env
```

### 3. Before Pushing to GitHub

```powershell
# Verify .env is NOT in your commit
git status

# Should NOT show .env - if it does, something is wrong
# .env should be in .gitignore (it already is)
```

## 🔒 Security Rules

**DO:**
- ✅ Use strong passwords (min 12 characters, mixed case, numbers, symbols)
- ✅ Keep `.env` file locally only
- ✅ Commit `.env.example` with placeholder values
- ✅ Review GitHub Actions logs for any security warnings

**DON'T:**
- ❌ Hardcode passwords in docker-compose.yml
- ❌ Commit `.env` file to git
- ❌ Use weak passwords like "admin123"
- ❌ Share `.env` file in email or Slack

## 📋 Environment Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `GRAFANA_ADMIN_USER` | Grafana login username | admin |
| `GRAFANA_ADMIN_PASSWORD` | Grafana login password | MySecure!Pass123 |
| `SMTP_PASSWORD` | Email notification password | app-specific-password |
| `MYSQL_ROOT_PASSWORD` | MySQL root password | SecureDB!Pass456 |

## 🔍 GitHub Actions Workflows

### Security Workflow (`security.yml`)
Automatically runs on every push and pull request.
- Scans for vulnerabilities (Trivy)
- Detects hardcoded secrets
- Checks npm dependencies
- Validates configurations

**View Results:**
1. Go to your GitHub repository
2. Click **Actions** tab
3. Look for "Security & Code Quality Checks"
4. Click to see detailed results

### Build & Test Workflow (`build-test.yml`)
Automatically runs on every push and pull request.
- Tests Node.js builds
- Validates Docker Compose
- Verifies Prometheus config
- Checks documentation

## ⚠️ If GitHub Actions Fails

Check the workflow logs:

1. **"Hardcoded passwords found"**
   - Fix: Remove any hardcoded values from YAML files
   - Use `${VARIABLE_NAME}` syntax instead

2. **"admin123 found"**
   - Fix: Only allowed in README/docs, not in config files
   - Documentation should reference .env instead

3. **"npm audit failures"**
   - Fix: Update packages in app-exporter
   ```powershell
   cd app-exporter
   npm audit fix
   npm ci
   ```

4. **".env file is tracked in git"**
   - Fix: Already handled by .gitignore
   - Verify .gitignore has `.env` entry

## 📝 Configuration Examples

### Secure Password Generation

Use PowerShell to generate a strong password:
```powershell
# Generate a 16-character random password
$password = -join (1..16 | ForEach-Object {[char](Get-Random -InputObject (97..122 + 65..90 + 48..57))} )
Write-Host $password

# Or use an online generator: https://www.random.org/passwords/
```

### Sample .env File

```dotenv
# Grafana Configuration
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=MySecure!Pass123#Updated

# SMTP Configuration for Alerts
SMTP_HOST=smtp.gmail.com:587
SMTP_FROM=alerts@company.com
SMTP_USERNAME=alerts@company.com
SMTP_PASSWORD=your-app-specific-password

# Database Credentials
MYSQL_ROOT_PASSWORD=SecureDB!Pass456
MYSQL_USER=exporter
MYSQL_PASSWORD=ExporterPass789

# Prometheus Configuration
PROMETHEUS_RETENTION=30d
PROMETHEUS_SCRAPE_INTERVAL=15s
```

## 🔐 Where Secrets Are Used

```
.env (local, not committed)
  ↓
docker-compose.yml (references ${VAR_NAME})
  ↓
Docker containers (loads from environment)
```

## ✨ Zero-Error Deployments

Following these practices ensures:
- ✅ No security vulnerabilities exposed
- ✅ GitHub Actions workflows pass 100%
- ✅ Safe, reproducible deployments
- ✅ Compliance with security best practices

## 📚 Additional Resources

- [SECURITY_FIXES.md](SECURITY_FIXES.md) - Detailed security fixes
- [.env.example](.env.example) - Environment variable template
- [docker-compose.yml](docker-compose.yml) - Updated with environment variables
- [.github/workflows/](.github/workflows/) - GitHub Actions workflows

## Need Help?

1. Check workflow logs in GitHub Actions tab
2. Review SECURITY_FIXES.md for detailed explanations
3. Verify .env file has all required variables
4. Ensure .env is NOT in git tracking
