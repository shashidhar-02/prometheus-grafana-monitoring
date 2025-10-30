# System Architecture

## Overview

This monitoring system follows a multi-tier architecture designed for scalability, reliability, and ease of use.

```
┌─────────────────────────────────────────────────────────────────────┐
│                         VISUALIZATION LAYER                         │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                        Grafana :3000                          │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │ │
│  │  │   System     │  │ Application  │  │   Docker     │       │ │
│  │  │  Dashboard   │  │  Dashboard   │  │  Dashboard   │       │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘       │ │
│  └───────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 │ Queries (PromQL)
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    METRICS STORAGE & PROCESSING                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                     Prometheus :9090                          │ │
│  │                                                               │ │
│  │  ┌────────────────┐        ┌──────────────────┐             │ │
│  │  │  Time Series   │        │  Recording Rules │             │ │
│  │  │    Database    │        │   (Pre-compute)  │             │ │
│  │  └────────────────┘        └──────────────────┘             │ │
│  │                                                               │ │
│  │  ┌────────────────────────────────────────────┐             │ │
│  │  │         Alert Evaluation Engine            │             │ │
│  │  └────────────────────────────────────────────┘             │ │
│  └───────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                 │                           │
                 │ Scrapes                   │ Alerts
                 ▼                           ▼
┌─────────────────────────────┐   ┌──────────────────────────┐
│   METRICS COLLECTION        │   │   ALERT MANAGEMENT       │
│                             │   │                          │
│  ┌─────────────────────┐   │   │  ┌──────────────────┐   │
│  │  Node Exporter      │   │   │  │  Alertmanager    │   │
│  │     :9100           │   │   │  │     :9093        │   │
│  │  ┌──────────────┐   │   │   │  │                  │   │
│  │  │ CPU Metrics  │   │   │   │  │ ┌──────────────┐ │   │
│  │  │ Mem Metrics  │   │   │   │  │ │ Email Alerts │ │   │
│  │  │ Disk Metrics │   │   │   │  │ │ Slack Alerts │ │   │
│  │  │ Net Metrics  │   │   │   │  │ └──────────────┘ │   │
│  │  └──────────────┘   │   │   │  └──────────────────┘   │
│  └─────────────────────┘   │   └──────────────────────────┘
│                             │
│  ┌─────────────────────┐   │
│  │  cAdvisor           │   │
│  │     :8080           │   │
│  │  ┌──────────────┐   │   │
│  │  │  Container   │   │   │
│  │  │   Metrics    │   │   │
│  │  └──────────────┘   │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  Nginx Exporter     │   │
│  │     :9113           │   │
│  │  ┌──────────────┐   │   │
│  │  │   Nginx      │   │   │
│  │  │   Metrics    │   │   │
│  │  └──────────────┘   │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  App Exporter       │   │
│  │     :3001           │   │
│  │  ┌──────────────┐   │   │
│  │  │  Custom App  │   │   │
│  │  │   Metrics    │   │   │
│  │  └──────────────┘   │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
         │
         │ Monitors
         ▼
┌─────────────────────────────┐
│   TARGET SYSTEMS            │
│                             │
│  ┌─────────────────────┐   │
│  │  Host System        │   │
│  │  CPU, RAM, Disk     │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  Docker Containers  │   │
│  │  Running Services   │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  Nginx Web Server   │   │
│  │     :80             │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  Your Application   │   │
│  │  Custom Metrics     │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

## Data Flow

### 1. Metric Collection (Pull Model)
```
Prometheus → Scrape → Exporters → Return Metrics → Store in TSDB
  (15s)                 /metrics
```

### 2. Metric Processing
```
Raw Metrics → Recording Rules → Pre-computed Metrics → Stored
                  (every 30s)
```

### 3. Alert Evaluation
```
Prometheus → Evaluate Rules → Trigger Alert → Alertmanager → Notify
              (every 15s)        (if threshold met)
```

### 4. Visualization
```
Grafana → PromQL Query → Prometheus → Return Data → Display Dashboard
           (every 30s)
```

## Component Interactions

### Prometheus ↔ Exporters
- **Protocol**: HTTP Pull
- **Interval**: 10-15 seconds (configurable)
- **Format**: Prometheus text format
- **Endpoint**: `/metrics`

### Prometheus ↔ Grafana
- **Protocol**: HTTP (REST API)
- **Format**: JSON
- **Query Language**: PromQL
- **Connection**: Configured datasource

### Prometheus ↔ Alertmanager
- **Protocol**: HTTP Push
- **Format**: JSON alerts
- **Trigger**: When alert rules fire
- **Deduplication**: Handled by Alertmanager

### Alertmanager ↔ Notification Channels
- **Protocol**: SMTP (Email), HTTP (Slack/Webhooks)
- **Format**: Configurable templates
- **Grouping**: By alert labels

## Network Architecture

```
┌─────────────────────────────────────────────────────┐
│            Docker Network: monitoring               │
│                  (Bridge Mode)                      │
│                                                     │
│  ┌──────────────┐      ┌──────────────┐           │
│  │  Prometheus  │◄────►│   Grafana    │           │
│  │    :9090     │      │    :3000     │           │
│  └──────┬───────┘      └──────────────┘           │
│         │                                          │
│         ├────────────┬──────────────┬─────────┐   │
│         │            │              │         │   │
│         ▼            ▼              ▼         ▼   │
│  ┌──────────┐ ┌──────────┐  ┌──────────┐ ┌─────┐│
│  │   Node   │ │ cAdvisor │  │  Nginx   │ │ App ││
│  │ Exporter │ │          │  │ Exporter │ │ Exp ││
│  │  :9100   │ │  :8080   │  │  :9113   │ │:3001││
│  └──────────┘ └──────────┘  └──────────┘ └─────┘│
│                                                   │
│  ┌──────────────┐                                │
│  │ Alertmanager │                                │
│  │    :9093     │                                │
│  └──────────────┘                                │
│                                                   │
│  ┌──────────────┐                                │
│  │    Nginx     │                                │
│  │     :80      │                                │
│  └──────────────┘                                │
└───────────────────────────────────────────────────┘
         │
         │ Exposed Ports to Host
         ▼
┌─────────────────────────────────────────────────┐
│              Windows Host                       │
│  localhost:80    → Nginx                       │
│  localhost:3000  → Grafana                     │
│  localhost:8080  → cAdvisor                    │
│  localhost:9090  → Prometheus                  │
│  localhost:9093  → Alertmanager                │
└─────────────────────────────────────────────────┘
```

## Persistence Layer

```
┌─────────────────────────────────────────────┐
│          Docker Volumes (Host)              │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │    prometheus_data                  │   │
│  │  - Time series database             │   │
│  │  - 30 days retention                │   │
│  │  - Mounted to /prometheus           │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │    grafana_data                     │   │
│  │  - Dashboards                       │   │
│  │  - User settings                    │   │
│  │  - Mounted to /var/lib/grafana      │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │    alertmanager_data                │   │
│  │  - Alert state                      │   │
│  │  - Silences                         │   │
│  │  - Mounted to /alertmanager         │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Scalability Model

### Horizontal Scaling

```
Multiple Servers to Monitor:
┌──────────────────────────────────────────┐
│         Central Monitoring Server        │
│  ┌────────────┐      ┌────────────┐     │
│  │ Prometheus │      │  Grafana   │     │
│  └────────────┘      └────────────┘     │
│         │                                │
└─────────┼────────────────────────────────┘
          │
          ├─────────────┬─────────────┬─────────────
          │             │             │
    ┌─────▼───┐   ┌─────▼───┐   ┌─────▼───┐
    │ Server  │   │ Server  │   │ Server  │
    │   #1    │   │   #2    │   │   #3    │
    │         │   │         │   │         │
    │ Node    │   │ Node    │   │ Node    │
    │ Exporter│   │ Exporter│   │ Exporter│
    └─────────┘   └─────────┘   └─────────┘
```

### Federation (Multi-level)

```
┌────────────────────────────────────────────┐
│      Global Prometheus (Federation)        │
│         Aggregated Metrics                 │
└──────────────┬─────────────────────────────┘
               │
       ┌───────┴────────┬──────────────┐
       │                │              │
┌──────▼─────┐   ┌──────▼─────┐  ┌────▼─────┐
│Regional    │   │Regional    │  │Regional  │
│Prometheus  │   │Prometheus  │  │Prometheus│
│  US-EAST   │   │  US-WEST   │  │   EU     │
└────────────┘   └────────────┘  └──────────┘
```

## Security Layers

```
┌─────────────────────────────────────────────┐
│           Security Architecture             │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │  Layer 1: Network Firewall            │ │
│  │  - Restrict access to monitoring ports│ │
│  │  - Allow only necessary IPs           │ │
│  └───────────────────────────────────────┘ │
│                   │                         │
│  ┌───────────────────────────────────────┐ │
│  │  Layer 2: Reverse Proxy + SSL        │ │
│  │  - Nginx with TLS termination        │ │
│  │  - Basic authentication              │ │
│  └───────────────────────────────────────┘ │
│                   │                         │
│  ┌───────────────────────────────────────┐ │
│  │  Layer 3: Application Auth            │ │
│  │  - Grafana user authentication       │ │
│  │  - Prometheus basic auth             │ │
│  └───────────────────────────────────────┘ │
│                   │                         │
│  ┌───────────────────────────────────────┐ │
│  │  Layer 4: Docker Network Isolation    │ │
│  │  - Internal container network         │ │
│  │  - Exposed ports only as needed      │ │
│  └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## High Availability Setup (Advanced)

```
┌──────────────────────────────────────────────────┐
│              Load Balancer                       │
│         (HAProxy / Nginx)                        │
└───────────┬─────────────────┬────────────────────┘
            │                 │
    ┌───────▼──────┐   ┌──────▼─────┐
    │  Prometheus  │   │ Prometheus │
    │  Instance 1  │   │ Instance 2 │
    │              │   │            │
    │  (Active)    │   │  (Standby) │
    └──────────────┘   └────────────┘
            │                 │
            └────────┬────────┘
                     │
            ┌────────▼────────┐
            │  Shared Storage │
            │   (NFS/EBS)     │
            └─────────────────┘
```

## Monitoring Flow Example

### User Request → Metrics → Alert → Dashboard

```
1. User accesses application
   └─► App Exporter records metrics
       └─► Prometheus scrapes every 15s
           └─► Stores in time series DB
               └─► Recording rules pre-compute
                   └─► Alert rules evaluate
                       │
                       ├─► If threshold exceeded
                       │   └─► Alertmanager notified
                       │       └─► Email/Slack sent
                       │
                       └─► Grafana queries metrics
                           └─► Dashboard updates
                               └─► User views charts
```

## Configuration Hierarchy

```
docker-compose.yml (Root)
    │
    ├─► Prometheus
    │   ├─► prometheus.yml (Main config)
    │   ├─► alerts.yml (Alert rules)
    │   └─► recording_rules.yml (Recording rules)
    │
    ├─► Grafana
    │   ├─► provisioning/
    │   │   ├─► datasources/ (Auto-config Prometheus)
    │   │   └─► dashboards/ (Auto-load dashboards)
    │   └─► dashboards/ (JSON dashboard files)
    │
    ├─► Alertmanager
    │   └─► alertmanager.yml (Routing & notifications)
    │
    ├─► Nginx
    │   ├─► nginx.conf (Web server config)
    │   └─► html/ (Static files)
    │
    └─► App Exporter
        ├─► index.js (Custom metrics)
        ├─► package.json (Dependencies)
        └─► Dockerfile (Container definition)
```

---

**This architecture provides**:
- ✅ Scalability for growing infrastructure
- ✅ High availability options
- ✅ Security at multiple layers
- ✅ Easy maintenance and updates
- ✅ Clear separation of concerns
- ✅ Extensibility for custom requirements

---
