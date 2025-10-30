# Custom Exporters Guide

This guide explains how to create custom Prometheus exporters for your applications.

## What is a Custom Exporter?

A custom exporter is an application that:
1. Collects application-specific metrics
2. Exposes them in Prometheus format
3. Can be scraped by Prometheus

## When to Create Custom Exporters

- Monitor business-specific metrics (sales, user signups, etc.)
- Track custom application performance metrics
- Monitor third-party APIs or services
- Instrument your application code

## Exporter Types

### 1. **Application Integration** (Recommended)
Directly instrument your application code.

### 2. **Sidecar Exporter**
Separate service that reads from logs, databases, or APIs.

### 3. **Gateway Pattern**
For short-lived jobs or batch processes.

## Example: Node.js Custom Exporter

### Installation

```bash
npm install express prom-client
```

### Basic Exporter

```javascript
const express = require('express');
const promClient = require('prom-client');

const app = express();
const register = new promClient.Registry();

// Add default metrics (CPU, memory)
promClient.collectDefaultMetrics({ register });

// Custom counter
const requestCounter = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'endpoint', 'status'],
  registers: [register]
});

// Custom histogram
const responseTime = new promClient.Histogram({
  name: 'http_response_time_seconds',
  help: 'HTTP response time in seconds',
  labelNames: ['method', 'endpoint'],
  buckets: [0.1, 0.5, 1, 2, 5],
  registers: [register]
});

// Custom gauge
const activeUsers = new promClient.Gauge({
  name: 'active_users',
  help: 'Number of currently active users',
  registers: [register]
});

// Middleware to track metrics
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    responseTime.labels(req.method, req.path).observe(duration);
    requestCounter.labels(req.method, req.path, res.statusCode).inc();
  });
  
  next();
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Your application routes
app.get('/api/data', (req, res) => {
  // Update gauge
  activeUsers.set(Math.random() * 100);
  res.json({ data: 'example' });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
  console.log('Metrics available at http://localhost:3000/metrics');
});
```

## Example: Python Custom Exporter

### Installation

```bash
pip install prometheus-client flask
```

### Basic Exporter

```python
from flask import Flask, Response
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY
import time
import random

app = Flask(__name__)

# Define metrics
request_count = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

request_duration = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint'],
    buckets=[0.1, 0.5, 1, 2, 5]
)

active_users = Gauge(
    'active_users',
    'Number of active users'
)

# Middleware
@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    duration = time.time() - request.start_time
    request_duration.labels(
        method=request.method,
        endpoint=request.endpoint
    ).observe(duration)
    
    request_count.labels(
        method=request.method,
        endpoint=request.endpoint,
        status=response.status_code
    ).inc()
    
    return response

# Metrics endpoint
@app.route('/metrics')
def metrics():
    return Response(generate_latest(REGISTRY), mimetype='text/plain')

# Application routes
@app.route('/api/data')
def get_data():
    active_users.set(random.randint(50, 150))
    return {'data': 'example'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
```

## Metric Types

### 1. Counter
For values that only increase (requests, errors, sales).

```javascript
const counter = new promClient.Counter({
  name: 'total_sales',
  help: 'Total number of sales',
  labelNames: ['product', 'region']
});

counter.labels('widget', 'us').inc();
counter.labels('widget', 'us').inc(5); // Increment by 5
```

### 2. Gauge
For values that can go up or down (temperature, memory, active users).

```javascript
const gauge = new promClient.Gauge({
  name: 'room_temperature_celsius',
  help: 'Current room temperature'
});

gauge.set(23.5);
gauge.inc(); // Increment by 1
gauge.dec(2); // Decrement by 2
```

### 3. Histogram
For tracking distributions (response times, request sizes).

```javascript
const histogram = new promClient.Histogram({
  name: 'api_response_time_seconds',
  help: 'API response time',
  buckets: [0.1, 0.5, 1, 2, 5] // Define buckets
});

histogram.observe(0.234); // Observe a value
```

### 4. Summary
Similar to histogram but calculates quantiles.

```javascript
const summary = new promClient.Summary({
  name: 'api_response_time_summary',
  help: 'API response time summary',
  percentiles: [0.5, 0.9, 0.99]
});

summary.observe(0.234);
```

## Best Practices

### 1. Metric Naming

Follow Prometheus naming conventions:
- Use `snake_case`
- Use descriptive names
- Add unit suffix: `_seconds`, `_bytes`, `_total`

```javascript
// Good
http_requests_total
response_time_seconds
memory_usage_bytes

// Bad
httpRequests
responseTime
mem
```

### 2. Use Labels Wisely

```javascript
// Good - consistent labels
http_requests_total{method="GET", endpoint="/api/users", status="200"}

// Bad - too many labels (high cardinality)
http_requests_total{user_id="12345", session_id="abcdef", ...}
```

### 3. Document Your Metrics

```javascript
const counter = new promClient.Counter({
  name: 'api_requests_total',
  help: 'Total number of API requests received', // Clear description
  labelNames: ['method', 'endpoint', 'status']
});
```

### 4. Avoid High Cardinality

Don't use labels with many unique values:
- ❌ User IDs
- ❌ Email addresses
- ❌ Timestamps
- ✅ HTTP methods
- ✅ Status codes
- ✅ Service names

### 5. Initialize Metrics

```javascript
// Initialize with zero values
['GET', 'POST', 'PUT', 'DELETE'].forEach(method => {
  [200, 400, 500].forEach(status => {
    requestCounter.labels(method, status).inc(0);
  });
});
```

## Database Metrics Example

### MongoDB Exporter

```javascript
const { MongoClient } = require('mongodb');
const promClient = require('prom-client');

const dbConnections = new promClient.Gauge({
  name: 'mongodb_connections',
  help: 'Number of MongoDB connections'
});

const dbOperations = new promClient.Counter({
  name: 'mongodb_operations_total',
  help: 'Total MongoDB operations',
  labelNames: ['operation']
});

// Collect metrics
async function collectMongoMetrics() {
  const client = await MongoClient.connect('mongodb://localhost:27017');
  const db = client.db('admin');
  
  const serverStatus = await db.command({ serverStatus: 1 });
  
  dbConnections.set(serverStatus.connections.current);
  dbOperations.labels('insert').inc(serverStatus.opcounters.insert);
  dbOperations.labels('query').inc(serverStatus.opcounters.query);
  
  await client.close();
}

setInterval(collectMongoMetrics, 15000); // Every 15 seconds
```

## API Monitoring Example

```javascript
const axios = require('axios');

const apiAvailable = new promClient.Gauge({
  name: 'external_api_available',
  help: 'External API availability (1=up, 0=down)',
  labelNames: ['api_name']
});

const apiResponseTime = new promClient.Histogram({
  name: 'external_api_response_time_seconds',
  help: 'External API response time',
  labelNames: ['api_name'],
  buckets: [0.5, 1, 2, 5, 10]
});

async function checkExternalAPI() {
  const start = Date.now();
  try {
    await axios.get('https://api.example.com/health');
    apiAvailable.labels('example-api').set(1);
  } catch (error) {
    apiAvailable.labels('example-api').set(0);
  }
  
  const duration = (Date.now() - start) / 1000;
  apiResponseTime.labels('example-api').observe(duration);
}

setInterval(checkExternalAPI, 30000); // Check every 30 seconds
```

## Business Metrics Example

```javascript
// Track business KPIs
const salesTotal = new promClient.Counter({
  name: 'business_sales_total',
  help: 'Total sales amount',
  labelNames: ['product_category', 'region']
});

const activeSubscriptions = new promClient.Gauge({
  name: 'business_active_subscriptions',
  help: 'Number of active subscriptions',
  labelNames: ['plan_type']
});

const userSignups = new promClient.Counter({
  name: 'business_user_signups_total',
  help: 'Total user signups',
  labelNames: ['signup_source']
});

// When a sale occurs
function recordSale(amount, category, region) {
  salesTotal.labels(category, region).inc(amount);
}

// Update subscription count
function updateSubscriptions() {
  // Query your database
  const premiumCount = 150;
  const basicCount = 500;
  
  activeSubscriptions.labels('premium').set(premiumCount);
  activeSubscriptions.labels('basic').set(basicCount);
}
```

## Testing Your Exporter

### 1. Check Metrics Endpoint

```bash
curl http://localhost:3000/metrics
```

Expected output:
```
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",endpoint="/api/users",status="200"} 42

# HELP active_users Number of active users
# TYPE active_users gauge
active_users 127
```

### 2. Add to Prometheus

Edit `prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'my-custom-exporter'
    static_configs:
      - targets: ['localhost:3000']
```

### 3. Verify in Prometheus

1. Go to http://localhost:9090/targets
2. Check if your exporter appears
3. Query your metrics in the Graph tab

## Deployment

### Docker

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

### Docker Compose

```yaml
my-exporter:
  build: ./my-exporter
  ports:
    - "3000:3000"
  networks:
    - monitoring
```

## Advanced: Push Gateway

For short-lived jobs (batch processes, cron jobs):

```javascript
const promClient = require('prom-client');
const gateway = new promClient.Pushgateway('http://pushgateway:9091');

const jobCounter = new promClient.Counter({
  name: 'batch_job_processed_total',
  help: 'Total items processed in batch job'
});

async function runBatchJob() {
  // Process items
  for (let i = 0; i < 1000; i++) {
    jobCounter.inc();
  }
  
  // Push metrics to gateway
  await gateway.pushAdd({ jobName: 'batch-processor' });
}
```

## Monitoring Checklist

- ✅ Metrics follow naming conventions
- ✅ Labels have low cardinality
- ✅ Metrics are well documented
- ✅ Default metrics are included
- ✅ Exporter is tested
- ✅ Added to Prometheus config
- ✅ Dashboards created in Grafana
- ✅ Alerts configured

---

**Now you can monitor anything! 📊**
