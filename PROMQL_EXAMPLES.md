# PromQL Query Examples

This document contains useful PromQL queries for monitoring your infrastructure.

## System Metrics

### CPU Usage
```promql
# CPU usage percentage
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# CPU usage by mode
rate(node_cpu_seconds_total[5m]) * 100

# Top 5 CPU consuming processes
topk(5, rate(node_cpu_seconds_total{mode!="idle"}[5m]))
```

### Memory
```promql
# Memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Available memory in GB
node_memory_MemAvailable_bytes / 1024 / 1024 / 1024

# Memory used
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

# Swap usage
node_memory_SwapTotal_bytes - node_memory_SwapFree_bytes
```

### Disk
```promql
# Disk usage percentage
(1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100

# Free disk space in GB
node_filesystem_avail_bytes{mountpoint="/"} / 1024 / 1024 / 1024

# Disk I/O rate
rate(node_disk_read_bytes_total[5m])
rate(node_disk_written_bytes_total[5m])

# Disk utilization percentage
rate(node_disk_io_time_seconds_total[5m]) * 100
```

### Network
```promql
# Network receive rate (bytes/sec)
rate(node_network_receive_bytes_total[5m])

# Network transmit rate (bytes/sec)
rate(node_network_transmit_bytes_total[5m])

# Total bandwidth usage
rate(node_network_receive_bytes_total[5m]) + rate(node_network_transmit_bytes_total[5m])

# Network errors
rate(node_network_receive_errs_total[5m])
rate(node_network_transmit_errs_total[5m])

# Packets per second
rate(node_network_receive_packets_total[5m])
```

## Application Metrics

### HTTP Requests
```promql
# Request rate (requests per second)
rate(http_requests_total[5m])

# Request rate by status code
sum by(status) (rate(http_requests_total[5m]))

# Request rate by endpoint
sum by(endpoint) (rate(http_requests_total[5m]))

# Total requests in last hour
sum(increase(http_requests_total[1h]))
```

### Error Rates
```promql
# Error rate percentage
(rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])) * 100

# 4xx error rate
rate(http_requests_total{status=~"4.."}[5m])

# Error count by status
sum by(status) (rate(http_requests_total{status=~"[45].."}[5m]))
```

### Response Times
```promql
# Average response time
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])

# 95th percentile response time
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# 99th percentile response time
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))

# Median response time
histogram_quantile(0.5, rate(http_request_duration_seconds_bucket[5m]))
```

## Container Metrics

### CPU
```promql
# Container CPU usage
rate(container_cpu_usage_seconds_total{container!=""}[5m]) * 100

# Top 5 CPU consuming containers
topk(5, rate(container_cpu_usage_seconds_total{container!=""}[5m]))
```

### Memory
```promql
# Container memory usage
container_memory_usage_bytes{container!=""}

# Container memory percentage
(container_memory_usage_bytes{container!=""} / container_spec_memory_limit_bytes{container!=""}) * 100

# Containers near memory limit
(container_memory_usage_bytes{container!=""} / container_spec_memory_limit_bytes{container!=""}) > 0.8
```

### Network
```promql
# Container network receive
rate(container_network_receive_bytes_total{container!=""}[5m])

# Container network transmit
rate(container_network_transmit_bytes_total{container!=""}[5m])
```

## Aggregation Functions

### Sum
```promql
# Total requests across all instances
sum(rate(http_requests_total[5m]))

# Requests by method
sum by(method) (rate(http_requests_total[5m]))
```

### Average
```promql
# Average CPU across instances
avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))

# Average response time
avg(rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m]))
```

### Min/Max
```promql
# Highest CPU usage
max(100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100))

# Lowest available memory
min(node_memory_MemAvailable_bytes)
```

### Count
```promql
# Number of running instances
count(up{job="node-exporter"} == 1)

# Number of containers
count(container_last_seen{container!=""})
```

## Time Functions

### Rate
```promql
# Rate over 5 minutes
rate(http_requests_total[5m])

# Rate over different time periods
rate(http_requests_total[1m])  # 1 minute
rate(http_requests_total[15m]) # 15 minutes
```

### Increase
```promql
# Increase over last hour
increase(http_requests_total[1h])

# Requests in last 24 hours
increase(http_requests_total[24h])
```

### Delta
```promql
# Change in value
delta(node_memory_MemAvailable_bytes[5m])
```

## Filtering

### By Label
```promql
# Specific instance
up{instance="localhost:9090"}

# Multiple instances
up{instance=~"localhost:.*"}

# Exclude labels
up{instance!~"localhost:.*"}

# Multiple conditions
http_requests_total{method="GET", status="200"}
```

### Regex
```promql
# Match pattern
http_requests_total{endpoint=~"/api/.*"}

# Error status codes (4xx or 5xx)
http_requests_total{status=~"[45].."}

# Not matching pattern
http_requests_total{endpoint!~"/health|/metrics"}
```

## Alert Queries

### High CPU
```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
```

### High Memory
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 80
```

### Low Disk Space
```promql
(node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 20
```

### High Error Rate
```promql
(rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])) * 100 > 5
```

### Instance Down
```promql
up == 0
```

### Slow Responses
```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
```

## Mathematical Operations

### Arithmetic
```promql
# Addition
node_memory_MemTotal_bytes + node_memory_SwapTotal_bytes

# Subtraction
node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes

# Multiplication
rate(http_requests_total[5m]) * 60  # Requests per minute

# Division
http_request_duration_seconds_sum / http_request_duration_seconds_count

# Percentage
(value / total) * 100
```

### Comparison
```promql
# Greater than
node_memory_MemAvailable_bytes > 1000000000

# Less than
disk_free_bytes < 10000000000

# Equal
up == 1

# Not equal
up != 1
```

## Advanced Queries

### Predict Linear
```promql
# Predict disk full in 4 hours
predict_linear(node_filesystem_avail_bytes[1h], 4*3600) < 0
```

### Absent
```promql
# Alert if metric is missing
absent(up{job="node-exporter"})
```

### Changes
```promql
# Number of times value changed
changes(container_restart_count[15m])
```

### Resets
```promql
# Counter resets
resets(http_requests_total[1h])
```

### Sort
```promql
# Sort descending
sort_desc(rate(http_requests_total[5m]))

# Sort ascending
sort(node_memory_MemAvailable_bytes)
```

## Tips

1. **Use appropriate time ranges**: Short ranges for real-time, longer for trends
2. **Combine with `by` for grouping**: `sum by(label) (...)`
3. **Use `rate()` for counters**: Counters always increase
4. **Use `irate()` for instant rate**: More sensitive to spikes
5. **Test queries in Prometheus**: Before using in alerts or dashboards
6. **Use recording rules**: For expensive queries used frequently
7. **Avoid high cardinality labels**: Don't use unique values as labels

---

**Practice these queries in Prometheus UI at http://localhost:9090** 🎯
