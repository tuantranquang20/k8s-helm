# Lab 6 Hands-On: Full-Stack Microservices Application (BONUS)

## Overview
This is an **advanced bonus lab** that combines everything you've learned into a complete full-stack application with:
- 🎯 Frontend service (nginx)
- 🔧 Backend API service
- 🗄️ PostgreSQL database
- ⚡ Redis cache
- 🌐 Ingress with path-based routing
- 🔐 Secrets management
- 📊 Multi-component architecture

## Architecture

```
Internet
   ↓
[Ingress]
   ├─→ /     → Frontend Service → Frontend Pods (2 replicas)
   └─→ /api  → Backend Service  → Backend Pods (3 replicas)
                                    ↓
                        ┌───────────┴──────────┐
                        ↓                      ↓
                  [PostgreSQL]            [Redis Cache]
```

## What's Included

### Deployments:
- `frontend-deployment.yaml` - Frontend (2 replicas)
- `backend-deployment.yaml` - Backend API (3 replicas)
- `deployment.yaml` - Base deployment (if needed)

### Services:
- `service.yaml` - Frontend & Backend services

### Configuration:
- `secret.yaml` - Database credentials
- `ingress.yaml` - Advanced path-based routing
- `Chart.yaml` - With PostgreSQL & Redis dependencies

### Features:
- Multi-component microservices
- Service-to-service communication
- Database connection via secrets
- Redis caching
- Environment-specific configurations
- Feature flags

## Quick Start

### 1. Install Dependencies
```bash
cd lab6-handons
helm dependency update
```

### 2. Preview the Stack
```bash
# See all resources that will be created
helm template fullstack .

# With PostgreSQL enabled
helm template fullstack . --set postgresql.enabled=true
```

### 3. Install Basic Stack (No Dependencies)
```bash
# Install frontend and backend only
helm install mystack . --set postgresql.enabled=false

# Check pods
kubectl get pods
kubectl get services
```

### 4. Install Full Stack with Database
```bash
# Install with PostgreSQL
helm install fullstack . --set postgresql.enabled=true

# Wait for all pods to be ready
kubectl get pods -w

# Check all components
kubectl get all
```

### 5. Test Service Communication
```bash
# Get backend pod
BACKEND_POD=$(kubectl get pods -l app.kubernetes.io/component=backend -o jsonpath='{.items[0].metadata.name}')

# Check environment variables
kubectl exec -it $BACKEND_POD -- env | grep -E '(DATABASE|REDIS|NODE_ENV)'

# Test frontend
FRONTEND_POD=$(kubectl get pods -l app.kubernetes.io/component=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $FRONTEND_POD -- env | grep BACKEND_API_URL
```

## Configuration Scenarios

### Scenario 1: Development Environment
```yaml
# dev-values.yaml
app:
  environment: development
  logLevel: debug

frontend:
  replicaCount: 1
  
backend:
  replicaCount: 1

postgresql:
  enabled: false  # Use SQLite in dev

features:
  enableAuth: false
  enableCache: false
```

Install:
```bash
helm install dev . -f dev-values.yaml
```

### Scenario 2: Production Environment
```yaml
# prod-values.yaml
app:
  environment: production
  logLevel: warning

frontend:
  replicaCount: 3
  service:
    type: LoadBalancer

backend:
  replicaCount: 5
  resources:
    limits:
      cpu: 500m
      memory: 512Mi

postgresql:
  enabled: true
  primary:
    persistence:
      enabled: true
      size: 20Gi

redis:
  enabled: true

features:
  enableAuth: true
  enableCache: true
  enableMetrics: true
```

Install:
```bash
helm install prod . -f prod-values.yaml
```

### Scenario 3: With Ingress
```bash
# Install with Ingress enabled
helm install webapp . \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=myapp.local \
  --set postgresql.enabled=true

# Add to /etc/hosts
echo "127.0.0.1 myapp.local" | sudo tee -a /etc/hosts

# Access via Ingress
curl http://myapp.local/
curl http://myapp.local/api
```

## Testing the Application

### 1. Check Frontend
```bash
# Port forward to frontend
kubectl port-forward service/fullstack-lab6-handons-frontend 8080:80

# Access in browser
open http://localhost:8080
```

### 2. Check Backend API
```bash
# Port forward to backend
kubectl port-forward service/fullstack-lab6-handons-backend 8081:8080

# Test API
curl http://localhost:8081
```

### 3. Check Database Connection
```bash
# Get PostgreSQL pod
POSTGRES_POD=$(kubectl get pods -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}')

# Connect to database
kubectl exec -it $POSTGRES_POD -- psql -U appuser -d appdb

# Inside psql:
# \dt    (list tables)
# \q     (quit)
```

### 4. Check Redis
```bash
# If Redis is enabled, connect to it
REDIS_POD=$(kubectl get pods -l app.kubernetes.io/name=redis -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it $REDIS_POD -- redis-cli -a redispass ping
# Should return: PONG
```

## Advanced Exercises

### Exercise 1: Add Monitoring
1. Enable Prometheus metrics
2. Add a metrics endpoint to backend
3. Create ServiceMonitor resource

### Exercise 2: Add Health Checks
1. Add liveness probes to frontend
2. Add readiness probes to backend
3. Configure startup probes

### Exercise 3: Horizontal Pod Autoscaling
```yaml
# Add to values.yaml
frontend:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
```

Create HPA template:
```yaml
{{- if .Values.frontend.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "lab6-handons.fullname" . }}-frontend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "lab6-handons.fullname" . }}-frontend
  minReplicas: {{ .Values.frontend.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.frontend.autoscaling.maxReplicas }}
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ .Values.frontend.autoscaling.targetCPUUtilizationPercentage }}
{{- end }}
```

### Exercise 4: Add Init Containers
Add database migration init container to backend:
```yaml
initContainers:
- name: migrate-db
  image: {{ .Values.backend.image.repository }}:{{ .Values.backend.image.tag }}
  command: ['npm', 'run', 'migrate']
  env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: {{ include "lab6-handons.fullname" . }}-db-secret
        key: database-url
```

### Exercise 5: Network Policies
Create network policy to control traffic:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-network-policy
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/component: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app.kubernetes.io/component: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: postgresql
    ports:
    - protocol: TCP
      port: 5432
```

## Useful Commands

### View All Resources
```bash
kubectl get all -l app.kubernetes.io/instance=fullstack
kubectl get configmaps,secrets -l app.kubernetes.io/instance=fullstack
```

### Logs
```bash
# Frontend logs
kubectl logs -l app.kubernetes.io/component=frontend --tail=50 -f

# Backend logs
kubectl logs -l app.kubernetes.io/component=backend --tail=50 -f

# PostgreSQL logs
kubectl logs -l app.kubernetes.io/name=postgresql --tail=50 -f
```

### Debug
```bash
# Describe deployments
kubectl describe deployment -l app.kubernetes.io/instance=fullstack

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods
```

## Troubleshooting

### Backend Can't Connect to Database
```bash
# Check secret exists
kubectl get secret fullstack-lab6-handons-db-secret

# Check secret contents (base64 encoded)
kubectl get secret fullstack-lab6-handons-db-secret -o yaml

# Check PostgreSQL service
kubectl get service -l app.kubernetes.io/name=postgresql

# Test connection from backend pod
kubectl exec -it <backend-pod> -- env | grep DATABASE_URL
```

### Frontend Can't Reach Backend
```bash
# Check backend service
kubectl get service fullstack-lab6-handons-backend

# Test from frontend pod
kubectl exec -it <frontend-pod> -- wget -qO- http://fullstack-lab6-handons-backend:8080
```

### Ingress Not Working
```bash
# Check ingress
kubectl get ingress
kubectl describe ingress fullstack-lab6-handons

# Check ingress controller
kubectl get pods -n ingress-nginx
```

## Cleanup
```bash
helm uninstall fullstack
helm uninstall dev
helm uninstall prod
helm uninstall webapp
```

## Key Takeaways

1. **Microservices Architecture**: Multiple services working together
2. **Service Discovery**: Services communicate by name
3. **Secrets Management**: Sensitive data in Kubernetes Secrets
4. **Path-Based Routing**: Ingress routes to different services
5. **Dependencies**: External charts for PostgreSQL & Redis
6. **Environment Parity**: Same chart for dev, staging, production
7. **Scalability**: Different replica counts per environment

## Congratulations! 🎉

You've completed all labs and built a production-ready full-stack application using Helm!

You now know:
- ✅ Kubernetes fundamentals
- ✅ Helm basics
- ✅ Custom chart creation
- ✅ Advanced templating
- ✅ Microservices deployment
- ✅ Production best practices

## Next Steps

1. Deploy a real application
2. Set up CI/CD with Helm
3. Explore Helm plugins
4. Contribute to public Helm charts
5. Learn about Helm operators
6. Implement GitOps with ArgoCD or Flux

Happy Helm-ing! 🚀
