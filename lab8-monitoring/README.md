# Lab 8: Complete Monitoring Stack

## 📊 Overview
Deploy a production-grade monitoring stack with:
- **Prometheus** - Metrics collection and storage
- **Grafana** - Metrics visualization and dashboards
- **AlertManager** - Alert routing and management
- **Node Exporter** - Hardware and OS metrics
- **Kube State Metrics** - Kubernetes cluster state metrics
- **Prometheus Operator** - Kubernetes-native Prometheus management

## Architecture

```
┌──────────────┐
│   Grafana    │ ← Users access dashboards
│  (Port 80)   │
└──────┬───────┘
       │ Query metrics
       ↓
┌──────────────┐      ┌─────────────────┐
│  Prometheus  │────→ │  AlertManager   │
│  (Port 9090) │      │   (Port 9093)   │
└──────┬───────┘      └─────────────────┘
       │ Scrape metrics
       ├────────────────┬──────────────────┐
       ↓                ↓                  ↓
┌─────────────┐  ┌──────────────┐  ┌─────────────┐
│ Node        │  │ Kube State   │  │ Your Apps   │
│ Exporter    │  │ Metrics      │  │ /metrics    │
└─────────────┘  └──────────────┘  └─────────────┘
```

## What's  Included

### Components:
- Prometheus server for metrics collection
- Grafana with pre-configured dashboards
- AlertManager for alert handling
- Node Exporter on every node
- Kube State Metrics for cluster insights
- Prometheus Operator for CRD management

### Pre-configured Dashboards:
1. **Kubernetes Cluster** (ID: 7249) - Overall cluster health
2. **Node Exporter** (ID: 1860) - Node-level metrics
3. **Pods** (ID: 6417) - Pod resource usage

## Quick Start

### 1. Add Prometheus Helm Repository
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 2. Install Dependencies
```bash
cd lab8-monitoring
helm dependency update
```

### 3. Deploy the Monitoring Stack
```bash
# Install (this will take a few minutes)
helm install monitoring .

# Watch pods coming up
kubectl get pods -w
```

### 4. Access the Dashboards

#### Grafana
```bash
# Get Grafana service
kubectl get service monitoring-kube-prometheus-stack-grafana

# Port forward
kubectl port-forward service/monitoring-kube-prometheus-stack-grafana 3000:80

# Access at: http://localhost:3000
# Username: admin
# Password: admin123
```

#### Prometheus
```bash
# Port forward Prometheus
kubectl port-forward service/monitoring-kube-prometheus-stack-prometheus 9090:9090

# Access at: http://localhost:9090
```

#### AlertManager
```bash
# Port forward AlertManager
kubectl port-forward service/monitoring-kube-prometheus-stack-alertmanager 9093:9093

# Access at: http://localhost:9093
```

## Using Grafana

### 1. Login
- URL: http://localhost:3000
- Username: `admin`
- Password: `admin123`

### 2. Explore Dashboards
```
Home → Dashboards → Browse

Available dashboards:
- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Namespace (Pods)
- Kubernetes / Compute Resources / Node (Pods)
- Node Exporter / Nodes
- USE Method / Cluster
```

### 3. Create Custom Dashboard
```
1. Click "+" → Create Dashboard
2. Add Panel
3. Select Prometheus as data source
4. Enter PromQL query (examples below)
5. Configure visualization
6. Save dashboard
```

## Useful PromQL Queries

### CPU Usage
```promql
# CPU usage by pod
rate(container_cpu_usage_seconds_total[5m])

# Node CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### Memory Usage
```promql
# Memory usage by pod
container_memory_usage_bytes

# Node memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

### Pod Count
```promql
# Total number of pods
sum(kube_pod_info)

# Pods by namespace
count by (namespace) (kube_pod_info)
```

### Disk Usage
```promql
# Disk usage percentage
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100
```

### Network Traffic
```promql
# Network receive bytes
rate(node_network_receive_bytes_total[5m])

# Network transmit bytes
rate(node_network_transmit_bytes_total[5m])
```

## Monitoring Your Applications

### Add Metrics to Your App

Create a ServiceMonitor:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
  labels:
    release: monitoring
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: metrics
    interval: 30s
```

### Example: Monitor Nginx
```bash
# Deploy nginx with exporter
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80

# Deploy nginx-prometheus-exporter
kubectl create deployment nginx-exporter \
  --image=nginx/nginx-prometheus-exporter:latest

# Create ServiceMonitor
kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: nginx-metrics
  labels:
    release: monitoring
spec:
  selector:
    matchLabels:
      app: nginx
  endpoints:
  - port: metrics
    interval: 30s
EOF
```

## Setting Up Alerts

### Create PrometheusRule
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: custom-alerts
  labels:
    release: monitoring
spec:
  groups:
  - name: custom_alerts
    interval: 30s
    rules:
    - alert: HighPodMemory
      expr: container_memory_usage_bytes > 500000000
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage detected"
        description: "Pod {{ $labels.pod }} is using {{ $value }} bytes of memory"
    
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Pod is crash looping"
        description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is restarting frequently"
```

Apply:
```bash
kubectl apply -f prometheusrule.yaml
```

## Exercises

### Exercise 1: Explore Metrics
```bash
# Port forward Prometheus
kubectl port-forward service/monitoring-kube-prometheus-stack-prometheus 9090:9090

# Go to: http://localhost:9090/graph
# Try these queries:
# - up
# - kube_pod_info
# - node_cpu_seconds_total
# - container_memory_usage_bytes
```

### Exercise 2: Create a Dashboard
1. Open Grafana
2. Create new dashboard
3. Add panel for CPU usage
4. Add panel for memory usage
5. Add panel for pod count
6. Save as "My Custom Dashboard"

### Exercise 3: Generate Load
```bash
# Deploy a test app
kubectl create deployment stress --image=polinux/`stress

# Generate CPU load
kubectl exec -it deployment/stress -- stress --cpu 4 --timeout 60s

# Watch metrics in Grafana
```

### Exercise 4: Test Alerts
```bash
# Deploy high-memory pod
kubectl run memory-hog --image=polinux/stress -- stress --vm 1 --vm-bytes 512M

# Check AlertManager for alerts
# Go to: http://localhost:9093
```

### Exercise 5: Monitor the Voting App
If you did Lab 7:
```bash
# Create ServiceMonitor for voting app
kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: voting-app-metrics
  labels:
    release: monitoring
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: voting-app
  endpoints:
  - port: http
    interval: 30s
EOF

# View voting app metrics in Grafana
```

## Production Configuration

Create `production-values.yaml`:
```yaml
kube-prometheus-stack:
  prometheus:
    prometheusSpec:
      retention: 30d
      storageSpec:
        volumeClaimTemplate:
          spec:
            resources:
              requests:
                storage: 100Gi
      resources:
        limits:
          cpu: 2000m
          memory: 4Gi
  
  grafana:
    persistence:
      enabled: true
      size: 20Gi
    resources:
      limits:
        cpu: 1000m
        memory: 1Gi
  
  alertmanager:
    config:
      receivers:
      - name: 'slack'
        slack_configs:
        - api_url: 'YOUR_SLACK_WEBHOOK_URL'
          channel: '#alerts'
```

## Troubleshooting

### Prometheus Not Scraping Metrics
```bash
# Check Prometheus targets
# Go to: http://localhost:9090/targets

# Check ServiceMonitor
kubectl get servicemonitor

# Check if labels match
kubectl describe servicemonitor <name>
```

### Grafana Can't Connect to Prometheus
```bash
# Check Grafana datasources
# Grafana UI → Configuration → Data Sources

# Verify Prometheus service
kubectl get service monitoring-kube-prometheus-stack-prometheus

# Check Grafana logs
kubectl logs -l app.kubernetes.io/name=grafana
```

### High Resource Usage
```bash
# Check resource consumption
kubectl top pods

# Reduce retention period
helm upgrade monitoring . --set kube-prometheus-stack.prometheus.prometheusSpec.retention=5d

# Reduce scrape frequency
# Edit ServiceMonitor interval from 30s to 60s
```

## Useful Commands

```bash
# View all monitoring resources
kubectl get pods,svc,pvc -l release=monitoring

# Check Prometheus config
kubectl get secret monitoring-kube-prometheus-stack-prometheus -o yaml

# View ServiceMonitors
kubectl get servicemonitor

# View PrometheusRules
kubectl get prometheusrule

# Check AlertManager config
kubectl get secret alertmanager-monitoring-kube-prometheus-stack-alertmanager -o yaml
```

## Metrics to Monitor

### Cluster Health
- Node CPU/Memory/Disk
- Pod status and restarts
- API server latency
- etcd performance

### Application Performance
- Request rate
- Error rate
- Response time
- Resource usage

### Resource Utilization
- CPU usage per namespace
- Memory usage per pod
- Disk I/O
- Network bandwidth

## Cleanup
```bash
helm uninstall monitoring

# Remove CRDs (optional, permanent!)
kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd probes.monitoring.coreos.com
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd thanosrulers.monitoring.coreos.com
```

## Learning Objectives

After this lab, you should understand:
- ✅ Prometheus metrics collection
- ✅ Grafana dashboard creation
- ✅ PromQL query language
- ✅ Alert configuration
- ✅ ServiceMonitor usage
- ✅ Monitoring Kubernetes clusters
- ✅ Custom metrics and exporters

## Next Steps
- Configure Slack/Email alerts
- Add custom exporters
- Create application-specific dashboards
- Set up long-term storage
- Implement Prometheus federation
- Deploy Thanos for multi-cluster monitoring

🎉 **Congratulations!** You now have a production-grade monitoring stack!
