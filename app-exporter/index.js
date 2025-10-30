const express = require('express');
const promClient = require('prom-client');

const app = express();
const PORT = 3001;

// Create a Registry to register the metrics
const register = new promClient.Registry();

// Add default metrics (CPU, memory, etc.)
promClient.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestCounter = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register]
});

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.5, 1, 2, 5],
  registers: [register]
});

const activeUsersGauge = new promClient.Gauge({
  name: 'active_users',
  help: 'Number of active users',
  registers: [register]
});

const databaseConnectionsGauge = new promClient.Gauge({
  name: 'database_connections',
  help: 'Number of active database connections',
  registers: [register]
});

const customBusinessMetric = new promClient.Gauge({
  name: 'business_transactions_total',
  help: 'Total number of business transactions',
  labelNames: ['type'],
  registers: [register]
});

// Middleware to track request duration
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration.labels(req.method, req.path, res.statusCode).observe(duration);
    httpRequestCounter.labels(req.method, req.path, res.statusCode).inc();
  });
  
  next();
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Simulate active users
setInterval(() => {
  const activeUsers = Math.floor(Math.random() * 100) + 50;
  activeUsersGauge.set(activeUsers);
}, 5000);

// Simulate database connections
setInterval(() => {
  const connections = Math.floor(Math.random() * 50) + 10;
  databaseConnectionsGauge.set(connections);
}, 10000);

// Simulate business transactions
setInterval(() => {
  const transactions = Math.floor(Math.random() * 10);
  customBusinessMetric.labels('purchase').inc(transactions);
  customBusinessMetric.labels('registration').inc(Math.floor(transactions / 2));
}, 15000);

// Sample API endpoints to generate metrics
app.get('/', (req, res) => {
  res.json({ 
    message: 'Custom Application Exporter',
    endpoints: ['/metrics', '/health', '/api/users', '/api/orders']
  });
});

app.get('/api/users', (req, res) => {
  // Simulate some processing time
  setTimeout(() => {
    res.json({ users: ['user1', 'user2', 'user3'] });
  }, Math.random() * 100);
});

app.get('/api/orders', (req, res) => {
  // Simulate some processing time
  setTimeout(() => {
    // Occasionally return an error to simulate error rate
    if (Math.random() > 0.9) {
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.json({ orders: ['order1', 'order2'] });
    }
  }, Math.random() * 200);
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`Custom exporter listening on port ${PORT}`);
  console.log(`Metrics available at http://localhost:${PORT}/metrics`);
});
