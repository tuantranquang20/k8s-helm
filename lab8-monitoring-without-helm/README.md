# Lab 8: Monitoring Stack - WITHOUT Helm 💀

## 📊 Overview

Deploy Prometheus + Grafana monitoring stack using **raw Kubernetes YAML**.

**SPOILER ALERT**: This is PAINFUL! You'll appreciate Helm after this! 😱

## 📁 Files

```
lab8-monitoring-without-helm/
├── 00-namespace.yaml      # Namespace
├── 01-prometheus.yaml     # Prometheus + RBAC + ConfigMap + ServiceAccount
├── 02-grafana.yaml        # Grafana + Secret + Datasource ConfigMap
└── README.md              # This survival guide
```

**Total: 3 files, ~300 lines of complex YAML**

Compare to Helm: **1 command** 🎯

## 🆚 The Brutal Reality

### With Helm (Lab 8):
```bash
# One command to rule them all
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack

# Includes:
# ✅ Prometheus
# ✅ Grafana
# ✅ AlertManager
# ✅ Node Exporter
# ✅ Kube State Metrics
# ✅ Pre-configured dashboards
# ✅ Pre-configured alerts
# ✅ ServiceMonitors
# ✅ PrometheusRules

# Total: 1 command, 30+ components, 100% configured
```

### Without Helm (This Lab):
```bash
# Just Prometheus and Grafana (basic setup)
# NO AlertManager
# NO Node Exporter
# NO Kube State Metrics
# NO Pre-configured dashboards
# NO Pre-configured alerts
# NO ServiceMonitors
# Manual RBAC configuration
# Manual datasource configuration
# Manual scrape config
# Manual everything!

# And you still need to apply files in correct order...
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-prometheus.yaml
kubectl wait --for=condition=ready pod -l component=prometheus -n monitoring --timeout=120s
kubectl apply -f 02-grafana.yaml

# Total: Multiple commands, 2 components, 20% configured
```

## 😱 What's Missing?

### 1. **No AlertManager**
```yaml
# With Helm: Included automatically
# Without Helm: Must deploy manually:
# - Create AlertManager config (YAML)
# - Create AlertManager deployment
# - Create AlertManager service
# - Configure Prometheus to use it
# - Configure alert routes
# - Configure receivers (email, Slack, etc.)
```

### 2. **No Node Exporter** (No node metrics!)
```yaml
# With Helm: DaemonSet deployed automatically
# Without Helm: Must create:
# - DaemonSet manifest
# - Service for node-exporter
# - ServiceMonitor for Prometheus
# - Update Prometheus scrape config
```

### 3. **No Kube State Metrics** (No cluster metrics!)
```yaml
# With Helm: Deployment + RBAC automatic
# Without Helm: Must create:
# - Deployment
# - Service
# - ServiceAccount
# - ClusterRole
# - ClusterRoleBinding
# - Update Prometheus config
```

### 4. **No Pre-built Dashboards**
```bash
# With Helm:
# - Kubernetes cluster overview
# - Node metrics
# - Pod metrics
# - Namespace metrics
# - Persistent volume metrics
# All pre-loaded!

# Without Helm:
# - Manually import dashboard JSON
# - Configure each panel
# - Set up variables
# - Configure data sources
# Hours of work!
```

### 5. **No ServiceMonitor CRDs**
```yaml
# With Helm: Prometheus Operator installed
# Can use ServiceMonitor CRD:
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
spec:
  selector:
    matchLabels:
      app: my-app

# Without Helm: Must update Prometheus config manually EVERY TIME!
```

## 🚀 Deployment (Good Luck!)

### Step 1: Deploy Namespace
```bash
cd lab8-monitoring-without-helm
kubectl apply -f 00-namespace.yaml
```

### Step 2: Deploy Prometheus
```bash
kubectl apply -f 01-prometheus.yaml

# Wait for Prometheus
kubectl wait --for=condition=ready pod -l component=prometheus -n monitoring --timeout=120s

# Verify Prometheus
kubectl port-forward -n monitoring service/prometheus 9090:9090 &
curl http://localhost:9090/-/healthy
```

### Step 3: Deploy Grafana
```bash
kubectl apply -f 02-grafana.yaml

# Wait for Grafana
kubectl wait --for=condition=ready pod -l component=grafana -n monitoring --timeout=120s

# Access Grafana
kubectl port-forward -n monitoring service/grafana 3000:80
```

### Step 4: Manual Configuration 💀
```bash
# 1. Login to Grafana (http://localhost:3000)
#    Username: admin
#    Password: admin123

# 2. Verify Prometheus datasource
#    Settings > Data Sources > Prometheus
#    Should show: http://prometheus:9090

# 3. Import dashboards manually
#    Copy dashboard JSON from Grafana.com
#    Paste into Grafana
#    Repeat 10+ times for each dashboard you want

# 4. Create alerts manually
#    Alerting > Alert rules
#    Create each rule one by one
#    No templates!

# 5. Realize you're missing metrics
#    Deploy Node Exporter manually
#    Deploy Kube State Metrics manually
#    Update Prometheus config
#    Restart Prometheus
#    Import more dashboards

# Total time: HOURS 😭
```

## 🔧 Manual Prometheus Configuration

The `prometheus.yml` in the ConfigMap is **COMPLEX**:

```yaml
prometheus.yml: |
  global:
    scrape_interval: 15s
    evaluation_interval: 15s
  
  scrape_configs:
    # Must manually define each job
    - job_name: 'prometheus'
      static_configs:
        - targets: ['localhost:9090']
    
    # Manual Kubernetes service discovery
    - job_name: 'kubernetes-nodes'
      kubernetes_sd_configs:
        - role: node
      relabel_configs:  # Complex relabeling rules!
        - source_labels: [__address__]
          regex: '(.*):10250'
          replacement: '${1}:9100'
          target_label: __address__
    
    # More manual configs for pods, services, etc.
```

**With Helm**: ServiceMonitors handle this automatically!

## 🎯 RBAC Nightmare

Prometheus needs permissions to discover services:

```yaml
# Must manually create:
apiVersion: v1
kind: ServiceAccount  # 1. Service account

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole  # 2. Cluster role with specific permissions
rules:
- apiGroups: [""]
  resources: ["nodes", "pods", "services", "endpoints"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding  # 3. Binding
roleRef:
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
```

**Forget one resource?** Prometheus won't scrape it!

**With Helm**: RBAC created automatically with correct permissions!

## 📊 Missing Dashboards

### What You DON'T Get:

1. **Kubernetes Cluster Overview**
   - Cluster resource usage
   - Node status
   - Pod distribution

2. **Node Metrics**
   - CPU utilization
   - Memory usage
   - Disk I/O
   - Network traffic

3. **Pod Metrics**
   - Container restarts
   - Resource limits
   - Resource requests

4. **Namespace Metrics**
   - Resource quotas
   - Limit ranges

### To Get These:
```bash
# 1. Go to grafana.com/dashboards
# 2. Find dashboard ID (e.g., 315 for Kubernetes cluster)
# 3. Copy JSON
# 4. Import to Grafana
# 5. Repeat for each dashboard
# 6. Realize metrics are missing (need Node Exporter!)
# 7. Deploy Node Exporter
# 8. Try again
# 9. Still missing metrics (need Kube State Metrics!)
# 10. Give up, use Helm 😭
```

**With Helm**: 20+ dashboards pre-loaded!

## 🔥 What Could Go Wrong?

### 1. Prometheus Can't Scrape Targets
```bash
# Check Prometheus GUI
kubectl port-forward -n monitoring service/prometheus 9090:9090

# Visit: http://localhost:9090/targets
# All targets show: ERROR

# Common causes:
# - Wrong RBAC permissions
# - Wrong service discovery config
# - Wrong relabel configs
# - Services don't have /metrics endpoint
# - Firewall blocking scrapes
```

### 2. Grafana Can't Connect to Prometheus
```bash
# Check Grafana datasource
# Error: "Bad Gateway"

# Causes:
# - Wrong Prometheus service name
# - Wrong namespace
# - Prometheus service port mismatch
# - Prometheus not ready yet
```

### 3. No Metrics Showing Up
```bash
# Dashboards imported but show "No Data"

# Causes:
# - Missing Node Exporter (no node metrics)
# - Missing Kube State Metrics (no K8s metrics)
# - Wrong PromQL queries in dashboard
# - Data source not selected
# - Time range too short
```

## 📦 Adding Node Exporter (Manual Pain)

Want node metrics? Deploy Node Exporter manually:

```yaml
# Create DaemonSet (not shown here, ~100 lines)
# Create Service
# Update Prometheus config to scrape it
# Restart Prometheus
# Verify scraping works
# Import node dashboard
# Cross fingers
```

**With Helm**: `--set nodeExporter.enabled=true` ✨

## 🎓 Comparison Table

| Feature | Helm (kube-prometheus-stack) | Raw YAML |
|---------|------------------------------|----------|
| **Prometheus** | ✅ Auto-configured | ✅ Manual config |
| **Grafana** | ✅ Pre-configured | ✅ Manual config |
| **AlertManager** | ✅ Included | ❌ Must deploy manually |
| **Node Exporter** | ✅ Included | ❌ Must deploy manually |
| **Kube State Metrics** | ✅ Included | ❌ Must deploy manually |
| **Dashboards** | ✅ 20+ pre-loaded | ❌ Import manually |
| **Alerts** | ✅ Pre-configured | ❌ Create manually |
| **ServiceMonitors** | ✅ CRD available | ❌ Manual config changes |
| **RBAC** | ✅ Auto-created | ✅ Manual creation |
| **Deploy Time** | 2 minutes | 2+ hours |
| **Maintenance** | Easy | Nightmare |

## 💡 Real-World Impact

### With Helm:
```bash
# Deploy complete stack
helm install monitoring prometheus-community/kube-prometheus-stack

# Add custom metrics
kubectl apply -f servicemonitor.yaml  # Done!

# Upgrade
helm upgrade monitoring prometheus-community/kube-prometheus-stack

# Total work: 10 minutes
```

### Without Helm:
```bash
# Deploy basic stack
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-prometheus.yaml
kubectl apply -f 02-grafana.yaml

# Realize you need more components
# Spend hours deploying Node Exporter, Kube State Metrics, AlertManager

# Add custom metrics
vim 01-prometheus.yaml  # Edit ConfigMap
kubectl apply -f 01-prometheus.yaml
kubectl rollout restart deployment/prometheus -n monitoring

# Upgrade Prometheus
vim 01-prometheus.yaml  # Change image version
kubectl apply -f 01-prometheus.yaml
# Check for compatibility issues
# Fix broken configs
# Restart

# Total work: Days
```

## 🧹 Cleanup

```bash
kubectl delete namespace monitoring

# If you deployed Node Exporter/Kube State Metrics:
kubectl delete clusterrole prometheus
kubectl delete clusterrolebinding prometheus
# ... and more manual cleanup
```

## 🎯 Final Verdict

**Deploying monitoring without Helm is:**
- ❌ Time-consuming (hours vs minutes)
- ❌ Error-prone (manual RBAC, configs)
- ❌ Incomplete (missing critical components)
- ❌ Hard to maintain (manual updates)
- ❌ Not production-ready (missing alerts, exporters)

**With Helm:**
- ✅ One command deployment
- ✅ Complete monitoring stack
- ✅ Pre-configured dashboards
- ✅ Production-ready
- ✅ Easy to maintain
- ✅ Community-supported

## 🚨 IMPORTANT LESSON

**This lab demonstrates why the Prometheus community created the `kube-prometheus-stack` Helm chart!**

They tried deploying manually.  
It was painful.  
They created Helm charts.  
Everyone wins! 🎉

## 🎓 Conclusion

If you're deploying Prometheus + Grafana **WITHOUT Helm**, you're either:
1. A masochist
2. Learning the hard way
3. About to use Helm real soon

**Don't do this in production!** Use Helm! 🙏

---

**Congratulations on understanding WHY Helm exists!** 🎉

Go forth and `helm install` with confidence! 🚀
