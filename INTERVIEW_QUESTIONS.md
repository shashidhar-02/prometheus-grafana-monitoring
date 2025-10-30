# DevOps Interview Questions - Prometheus & Grafana Monitoring Stack

Based on the complete monitoring project with Prometheus, Grafana, Node Exporter, Alertmanager, and Docker Compose.

---

## 🟢 BEGINNER LEVEL (0-2 Years Experience)

### 📊 Monitoring Basics
1. **What is monitoring and why is it important in DevOps?**
2. **What is the difference between Prometheus and Grafana?**
3. **What is a metrics exporter? Name 3 exporters in this project.**
4. **What metrics does Node Exporter collect?**
5. **What port does Prometheus run on by default?**
6. **What is a time-series database?**
7. **What is the purpose of Alertmanager?**
8. **What is cAdvisor used for?**

### 🐳 Docker Basics
9. **What is Docker Compose and why use it?**
10. **Explain the difference between `docker-compose up` and `docker-compose up -d`**
11. **What is a Docker volume and why is it used?**
12. **How do you check running containers?**
13. **What is a Docker network?**
14. **What command stops all containers in docker-compose?**
15. **What is the purpose of `ports` section in docker-compose.yml?**
16. **Explain what `restart: unless-stopped` means**

### ⚙️ Configuration
17. **What is a YAML file and why is it popular in DevOps?**
18. **What is the purpose of prometheus.yml file?**
19. **What is a scrape interval in Prometheus?**
20. **What is data retention in Prometheus?**
21. **How do you access Grafana dashboard?**
22. **What are the default credentials for Grafana?**
23. **What is a datasource in Grafana?**

### 📁 Project Structure
24. **Why do we need separate folders for prometheus, grafana, and alertmanager?**
25. **What is the purpose of .gitignore file?**
26. **Why exclude data folders from Git?**

---

## 🟡 INTERMEDIATE LEVEL (2-5 Years Experience)

### 📈 Prometheus Deep Dive
27. **Explain the pull model used by Prometheus**
28. **What is PromQL? Write a query to get CPU usage over 80%**
29. **What are scrape configs in Prometheus?**
30. **Explain static_configs vs service discovery**
31. **What are labels in Prometheus metrics?**
32. **How does Prometheus handle metric cardinality?**
33. **What is the difference between Counter and Gauge metrics?**
34. **Explain Histogram and Summary metric types**
35. **What are recording rules and why use them?**
36. **What is the purpose of the `/metrics` endpoint?**

### ⚠️ Alerting System
37. **What is the difference between alerting rules and recording rules?**
38. **Explain alert states: Pending, Firing, Resolved**
39. **How do you configure email alerts in Alertmanager?**
40. **What is alert routing in Alertmanager?**
41. **Explain alert grouping and why it's useful**
42. **What is alert inhibition?**
43. **How do you set alert severity levels?**
44. **Write an alert rule for high memory usage (>85%)**

### 📊 Grafana Advanced
45. **How does dashboard provisioning work?**
46. **What is the difference between provisioned vs manually created dashboards?**
47. **Explain Grafana panel types (Graph, Gauge, Stat, Table)**
48. **What are Grafana variables/templates?**
49. **How do you share dashboards between teams?**
50. **What is the purpose of `jsonData` in datasource configuration?**
51. **How do you import community dashboards from grafana.com?**

### 🐳 Docker Advanced
52. **Explain Docker networking modes (bridge, host, none)**
53. **What is the purpose of `depends_on` in docker-compose?**
54. **Why use named volumes vs bind mounts?**
55. **What are health checks in Docker and how to configure them?**
56. **Explain Docker resource limits (CPU, memory)**
57. **How do you debug a container that keeps restarting?**
58. **What is the difference between CMD and ENTRYPOINT?**

### 🔧 Exporters
59. **How does Node Exporter expose system metrics?**
60. **What is the difference between blackbox exporter and node exporter?**
61. **How do you create a custom metrics exporter?**
62. **Explain the prom-client library for Node.js**
63. **What metrics does nginx-exporter provide?**
64. **How does cAdvisor collect container metrics?**

---

## 🔴 ADVANCED LEVEL (5+ Years Experience)

### 🏗️ Architecture & Design
65. **Design a monitoring architecture for microservices with 50+ services**
66. **How do you implement Prometheus federation?**
67. **Explain Prometheus remote write and remote read**
68. **Design a highly available Prometheus setup**
69. **How do you handle Prometheus scalability issues?**
70. **Explain the Prometheus TSDB (Time Series Database) storage engine**
71. **What are chunks and blocks in Prometheus storage?**
72. **How do you implement multi-tenancy in Prometheus?**

### 🔍 Service Discovery
73. **What service discovery mechanisms does Prometheus support?**
74. **How do you implement Kubernetes service discovery?**
75. **Explain file-based service discovery**
76. **What is relabeling in Prometheus?**
77. **How do you use meta labels for dynamic configuration?**

### 📊 Performance & Optimization
78. **How do you optimize Prometheus queries?**
79. **What causes high cardinality issues and how to solve them?**
80. **Explain Prometheus memory management**
81. **How do you tune Prometheus storage retention?**
82. **What is WAL (Write-Ahead Log) in Prometheus?**
83. **How do you reduce scrape duration?**
84. **Explain query caching in Prometheus**

### 🚀 Production Best Practices
85. **How do you implement blue-green deployment monitoring?**
86. **Design an alerting strategy for production systems**
87. **How do you prevent alert fatigue?**
88. **Explain SLI, SLO, and SLA in monitoring context**
89. **How do you monitor the monitoring system itself?**
90. **What is alert silencing and when to use it?**

### 🔐 Security
91. **How do you secure Prometheus endpoints?**
92. **Implement authentication for Grafana**
93. **How do you use TLS/SSL with Prometheus?**
94. **Explain secrets management in monitoring stack**
95. **How do you secure metrics data?**

### 🌐 Integration & Ecosystem
96. **How do you integrate Prometheus with Kubernetes?**
97. **Explain Prometheus Operator**
98. **How do you send alerts to Slack/PagerDuty?**
99. **Integrate Prometheus with ELK stack**
100. **How do you export Prometheus metrics to other systems?**

### 🔄 CI/CD & Automation
101. **How do you automate dashboard deployment?**
102. **Implement GitOps for monitoring configuration**
103. **How do you test alert rules before deployment?**
104. **Create a CI/CD pipeline for monitoring stack**
105. **How do you validate Prometheus configuration?**

---

## 💼 SCENARIO-BASED QUESTIONS (All Levels)

### 🔥 Troubleshooting
106. **Prometheus shows target as DOWN - how do you troubleshoot?**
107. **Grafana dashboard shows "No Data" - what are possible causes?**
108. **Alert is not firing even though condition is met - debug steps?**
109. **Prometheus is consuming too much memory - what do you check?**
110. **Container metrics not appearing in Prometheus - troubleshoot**

### 📋 Real-World Scenarios
111. **Setup monitoring for a new microservice**
112. **Create dashboard for database performance monitoring**
113. **Configure alerts for disk space on multiple servers**
114. **Monitor API response times and error rates**
115. **Setup alerting for SSL certificate expiration**
116. **Implement monitoring for Docker Swarm cluster**
117. **Monitor application deployment and rollback**
118. **Create custom business metrics dashboard**

### 🎯 Design Questions
119. **Design monitoring for multi-region deployment**
120. **Implement cost-effective monitoring at scale**
121. **Design disaster recovery for monitoring stack**
122. **Create monitoring strategy for serverless applications**
123. **Implement unified monitoring for hybrid cloud**

---

## 🔧 HANDS-ON PRACTICAL QUESTIONS

### Based on This Project
124. **Modify docker-compose.yml to add a new exporter**
125. **Write a PromQL query to show network traffic by interface**
126. **Create an alert rule for container restart count**
127. **Build a custom Grafana dashboard for Nginx metrics**
128. **Add Slack webhook to Alertmanager**
129. **Configure Prometheus to scrape a new target**
130. **Create recording rules for commonly used queries**
131. **Implement dashboard variables for multi-instance monitoring**
132. **Setup blackbox exporter for HTTP endpoint monitoring**
133. **Create alert rule with different severity levels**
134. **Export and import Grafana dashboard**
135. **Configure alert routing to different teams**

### Infrastructure as Code
136. **Convert docker-compose to Kubernetes manifests**
137. **Create Terraform module for this monitoring stack**
138. **Write Ansible playbook to deploy monitoring**
139. **Create Helm chart for Prometheus stack**
140. **Implement configuration management with Chef/Puppet**

---

## 📝 CODE REVIEW QUESTIONS

141. **Review this alert rule - what's wrong?**
```yaml
- alert: HighCPU
  expr: cpu_usage > 80
  for: 1m
```

142. **What's the issue with this PromQL query?**
```promql
rate(http_requests[5m])
```

143. **Review this docker-compose volume configuration**
```yaml
volumes:
  - ./prometheus:/prometheus
```

144. **What's inefficient about this query?**
```promql
sum(rate(container_cpu_usage_seconds_total[1m])) by (name)
```

145. **Review this Grafana panel query - can it be optimized?**

---

## 🎓 CONCEPTUAL DEEP-DIVE QUESTIONS

146. **Explain the four golden signals of monitoring**
147. **What is observability and how is it different from monitoring?**
148. **Explain RED method (Rate, Errors, Duration)**
149. **What is USE method (Utilization, Saturation, Errors)?**
150. **Explain the concept of whitebox vs blackbox monitoring**
151. **What is distributed tracing and how does it relate to metrics?**
152. **Explain the difference between logs, metrics, and traces**
153. **What is OpenTelemetry and how does it relate to Prometheus?**

---

## 🌟 BONUS: DEVOPS PHILOSOPHY QUESTIONS

154. **Why is monitoring considered a DevOps practice?**
155. **How does monitoring support CI/CD pipelines?**
156. **Explain shift-left approach in monitoring**
157. **How does monitoring relate to SRE practices?**
158. **What role does monitoring play in incident management?**
159. **How do you measure the effectiveness of your monitoring?**
160. **Explain the concept of progressive delivery and monitoring**

---

## 💡 PROJECT-SPECIFIC QUESTIONS

### Based on Your GitHub Repository

161. **Explain the architecture of this monitoring stack**
162. **Why did you choose these specific exporters?**
163. **How would you scale this setup for production?**
164. **What improvements would you make to this project?**
165. **How do you handle secrets (email passwords) in production?**
166. **Explain your choice of scrape intervals**
167. **Why use dashboard provisioning instead of manual creation?**
168. **How would you backup this monitoring setup?**
169. **What's your disaster recovery plan for this stack?**
170. **How do you version control monitoring configuration?**

---

## 🎯 RAPID FIRE QUESTIONS

171. Default Prometheus port?
172. Default Grafana port?
173. Node Exporter port?
174. Alertmanager port?
175. What language is Prometheus written in?
176. What is PromQL?
177. Name 3 Prometheus metric types
178. What file format does Prometheus use for config?
179. What database does Grafana use by default?
180. What is the file extension for Grafana dashboards?

---

## 📚 STUDY GUIDE

### Key Topics to Master:
- ✅ Prometheus Architecture & TSDB
- ✅ PromQL Query Language
- ✅ Alert Rules & Alertmanager
- ✅ Grafana Dashboard Creation
- ✅ Docker & Container Monitoring
- ✅ Metrics Types & Best Practices
- ✅ Service Discovery Mechanisms
- ✅ High Availability & Scalability
- ✅ Security Best Practices
- ✅ Integration with Cloud Platforms

### Recommended Resources:
1. Official Prometheus Documentation
2. Official Grafana Documentation
3. This GitHub Project: https://github.com/shashidhar-02/prometheus-grafana-monitoring
4. Prometheus: Up & Running (Book)
5. Site Reliability Engineering (Google)

---

**Total Questions: 180+**

Good luck with your DevOps interviews! 🚀
