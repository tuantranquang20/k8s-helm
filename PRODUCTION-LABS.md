# 🚀 Complete Kubernetes & Helm Labs - Production Applications

## Overview

This repository contains **complete, production-ready lab exercises** for learning Kubernetes and Helm by deploying real applications!

## 📚 Learning Path

### Phase 1: Fundamentals (Labs 1-3)
Basic Kubernetes concepts and operations

### Phase 2: Helm Basics (Labs 4-6)
Custom charts, advanced features, and microservices

### Phase 3: Production Applications (Labs 7-9) ⭐ **NEW!**
Real-world deployments with complete applications

---

## 🎯 Production Application Labs

### **Lab 7: Voting App Microservices** 🗳️
**Deploy a complete microservices application**

**What You'll Build:**
- Vote frontend (Python/Flask)
- Result frontend (Node.js)
- Worker service (Java)
- Redis message queue
- PostgreSQL database

**Architecture:** 5-service microservices application

**Learn:**
- Microservices communication
- Message queues
- Multi-tier applications
- Service discovery
- Independent scaling

**Quick Start:**
```bash
cd lab7-voting-app
helm dependency update
helm install voteapp .
kubectl port-forward service/voteapp-voting-app-vote 5000:80
kubectl port-forward service/voteapp-voting-app-result 5001:80
```

**Access:**
- Vote: http://localhost:5000
- Results: http://localhost:5001

---

### **Lab 8: Monitoring Stack** 📊
**Deploy production-grade monitoring with Prometheus & Grafana**

**What You'll Build:**
- Prometheus metrics collection
- Grafana dashboards
- AlertManager
- Node Exporter
- Kube State Metrics

**Pre-configured Dashboards:**
- Kubernetes Cluster Overview
- Node Metrics  
- Pod Resource Usage

**Learn:**
- Metrics collection
- PromQL queries
- Dashboard creation
- Alert configuration
- Observability best practices

**Quick Start:**
```bash
cd lab8-monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm dependency update
helm install monitoring .
kubectl port-forward service/monitoring-kube-prometheus-stack-grafana 3000:80
kubectl port-forward service/monitoring-kube-prometheus-stack-prometheus 9090:9090
```

**Access:**
- Grafana: http://localhost:3000 (admin/admin123)
- Prometheus: http://localhost:9090

---

### **Lab 9: WordPress CMS** 📝
**Deploy a complete content management system**

**What You'll Build:**
- WordPress application
- MySQL database
- Redis cache
- Persistent storage
- LoadBalancer access

**Features:**
- Full CMS platform
- Plugin management
- Database persistence
- Performance caching
- WP-CLI management

**Learn:**
- Stateful applications
- Persistent storage
- Database integration
- Caching layers
- CMS deployment
- Backup/restore

**Quick Start:**
```bash
cd lab9-wordpress
helm repo add bitnami https://charts.bitnami.com/bitnami
helm dependency update
helm install myblog .
kubectl port-forward service/myblog-wordpress 8080:80
```

**Access:**
- WordPress: http://localhost:8080
- Login: admin/admin123

---

### **Lab 10: E-Commerce Platform** 🛒
**Deploy a complete online store with microservices**

**What You'll Build:**
- Frontend storefront
- Product catalog service
- Shopping cart service
- Order processing service
- Payment service (mock)
- User authentication service
- PostgreSQL database
- Redis cache
- RabbitMQ message queue

**Architecture:** 9-service e-commerce platform

**Learn:**
- E-commerce microservices
- Message queues (RabbitMQ)
- Async order processing
- Payment integration
- Session management
- Distributed transactions

**Quick Start:**
```bash
cd lab10-ecommerce
helm repo add bitnami https://charts.bitnami.com/bitnami
helm dependency update
helm install myshop .
kubectl port-forward service/myshop-ecommerce-platform-frontend 8080:80
```

**Access:**
- Storefront: http://localhost:8080
- Individual Services: Port 8001-8006

---

## 📊 Lab Comparison

| Lab | Application | Services | Complexity | Time | Best For |
|-----|-------------|----------|------------|------|----------|
| **Lab 7** | Voting App | 5 (Vote, Result, Worker, Redis, PostgreSQL) | ⭐⭐⭐⭐ | 45min | Microservices architecture |
| **Lab 8** | Monitoring | 6+ (Prometheus, Grafana, AlertManager, Exporters) | ⭐⭐⭐⭐⭐ | 60min | Observability & metrics |
| **Lab 9** | WordPress | 3 (WordPress, MySQL, Redis) | ⭐⭐⭐ | 30min | Stateful apps & CMS |
| **Lab 10** | E-Commerce | 9 (Frontend, 6 Microservices, DB, Queue) | ⭐⭐⭐⭐⭐ | 60min | Complete microservices platform |

---

## 🎓 What You'll Learn

### Lab 7: Microservices
- ✅ Service-to-service communication
- ✅ Message queues (Redis)
- ✅ Background workers
- ✅ Multi-language services
- ✅ Scaling individual services
- ✅ Real-time data flow

### Lab 8: Monitoring
- ✅ Prometheus metrics collection
- ✅ Grafana dashboard creation
- ✅ PromQL query language
- ✅ Alert configuration
- ✅ Custom metrics
- ✅ ServiceMonitor & PrometheusRule CRDs

### Lab 9: WordPress
- ✅ Stateful application deployment
- ✅ Persistent volumes
- ✅ Database management
- ✅ Application caching
- ✅ CMS platform operation
- ✅ Backup/restore procedures

### Lab 10: E-Commerce
- ✅ Complex microservices architecture
- ✅ Message queues (RabbitMQ)
- ✅ Async processing patterns
- ✅ Shopping cart state management
- ✅ Payment gateway integration
- ✅ Order workflow orchestration
- ✅ Multi-service transactions

---

## 🚀 Getting Started

### Prerequisites
```bash
# Verify installations
kubectl version --client
helm version
minikube status  # or your K8s cluster

# Add required repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Quick Deploy All Labs

```bash
# Lab 7: Voting App
cd lab7-voting-app && helm dependency update && helm install voteapp . && cd ..

# Lab 8: Monitoring
cd lab8-monitoring && helm dependency update && helm install monitoring . && cd ..

# Lab 9: WordPress
cd lab9-wordpress && helm dependency update && helm install myblog . && cd ..

# Lab 10: E-Commerce
cd lab10-ecommerce && helm dependency update && helm install myshop . && cd ..

# View all deployments
kubectl get all
```

---

## 📖 Detailed Lab Guides

Each lab includes:
- **README.md** - Complete guide with:
  - Architecture diagrams
  - Step-by-step deployment
  - Configuration options
  - Testing procedures
  - Exercises
  - Troubleshooting
  - Production tips

- **Chart.yaml** - Helm chart metadata with dependencies
- **values.yaml** - Configuration with sensible defaults
- **templates/** - Kubernetes manifests

---

## 💡 Lab Exercises

### Beginner Exercises
1. **Deploy each lab** following the README
2. **Access all services** via port-forward or LoadBalancer  
3. **View logs** for each component
4. **Scale applications** up and down

### Intermediate Exercises
1. **Combine labs**: Monitor voting app with Lab 8
2. **Create dashboards**: Custom Grafana dashboard for WordPress
3. **Load testing**: Test performance under load
4. **Backup/Restore**: Practice disaster recovery

### Advanced Exercises
1. **High Availability**: Deploy multi-replica setups
2. **Custom metrics**: Add Prometheus metrics to voting app
3. **Auto-scaling**: Implement HPA based on metrics
4. **CI/CD**: Set up automated deployment pipelines
5. **E-Commerce Integration**: Monitor e-commerce platform with Lab 8

---

## 🔧 Common Commands

### Deploy
```bash
cd labX-name
helm dependency update
helm install myrelease .
```

### Access Services
```bash
# Port forward
kubectl port-forward service/myservice 8080:80

# Minikube
minikube service myservice --url

# Get LoadBalancer IP
kubectl get service myservice
```

### Monitor
```bash
# Watch pods
kubectl get pods -w

# View logs
kubectl logs -f -l app=myapp

# Resource usage
kubectl top pods
kubectl top nodes
```

### Manage
```bash
# Upgrade
helm upgrade myrelease . -f new-values.yaml

# Rollback
helm rollback myrelease

# Uninstall
helm uninstall myrelease
```

---

## 🎯 Real-World Scenarios

### Scenario 1: Company Voting System
Deploy Lab 7 for internal polls and surveys

### Scenario 2: Infrastructure Monitoring
Use Lab 8 to monitor your entire K8s cluster

### Scenario 3: Company Blog/Website
Deploy Lab 9 for corporate content management

### Scenario 4: Online Store
Deploy Lab 10 for e-commerce operations

---

## 📊 Resource Requirements

| Lab | Pods | CPU (total) | Memory (total) | Storage |
|-----|------|-------------|----------------|---------|
| Lab 7 | 7-8 | 1.5 CPU | 3 GB | 20 GB |
| Lab 8 | 10+ | 2-3 CPU | 4-6 GB | 30 GB |
| Lab 9 | 3-4 | 1 CPU | 2 GB | 20 GB |
| Lab 10 | 12-15 | 3-4 CPU | 6-8 GB | 40 GB |

**Recommended Cluster:** 4-8 CPU, 16GB RAM for running all labs

---

## 🐛 Troubleshooting

### Pods Not Starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Services Not Accessible
```bash
kubectl get service
kubectl port-forward service/<name> 8080:80
```

### Persistent Volumes Pending
```bash
kubectl get pvc
kubectl describe pvc <pvc-name>
# May need to configure storage class
```

### Dependencies Not Installing
```bash
helm repo update
helm dependency update
rm -rf charts/
helm dependency build
```

---

## 🎓 Learning Outcomes

After completing these labs, you will be able to:

1. **Deploy Production Applications**
   - Microservices architectures
   - Stateful applications
   - Monitoring stacks

2. **Manage Complex Systems**
   - Multi-component applications
   - Service dependencies
   - Data persistence

3. **Operate at Scale**
   - Horizontal/vertical scaling
   - Resource optimization
   - Performance tuning

4. **Monitor & Debug**
   - Metrics collection
   - Log aggregation
   - Troubleshooting

5. **Production Best Practices**
   - High availability
   - Backup/restore
   - Security hardening

---

## 🔄 Integration Examples

### Monitor Voting App with Prometheus
```bash
# Deploy both labs
cd lab7-voting-app && helm install voteapp . && cd ..
cd lab8-monitoring && helm install monitoring . && cd ..

# Create ServiceMonitor for voting app
kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: voting-app
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

# View in Grafana
kubectl port-forward service/monitoring-kube-prometheus-stack-grafana 3000:80
```

### Deploy WordPress with Monitoring
```bash
# Deploy WordPress
cd lab9-wordpress && helm install myblog . && cd ..

# Add WordPress metrics to Prometheus
# Create dashboard in Grafana for WordPress performance
```

---

## 📚 Additional Resources

- **Kubernetes Docs**: https://kubernetes.io/docs/
- **Helm Docs**: https://helm.sh/docs/
- **Prometheus Docs**: https://prometheus.io/docs/
- **Grafana Docs**: https://grafana.com/docs/

---

## 🎉 Congratulations!

You now have production-ready deployments of:
- ✅ Microservices application (Voting App)
- ✅ Complete monitoring stack (Prometheus + Grafana)
- ✅ Content management system (WordPress)
- ✅ Full e-commerce platform (Online Store)

You're ready to:
- Deploy real applications to Kubernetes
- Manage production workloads
- Monitor system health
- Scale and optimize services
- Build complete microservices platforms

## Next Steps
1. Customize these deployments for your needs
2. Add CI/CD pipelines
3. Implement GitOps with ArgoCD
4. Explore service meshes (Istio, Linkerd)
5. Learn about Kubernetes operators
6. Add API gateway (Kong, Ambassador)
7. Implement distributed tracing (Jaeger)

**Happy deploying!** 🚀
