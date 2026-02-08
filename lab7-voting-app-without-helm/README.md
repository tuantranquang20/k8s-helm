# Lab 7: Voting App Microservices - WITHOUT Helm

## 🗳️ Overview
This is the **voting app microservices application** deployed using **plain Kubernetes YAML** instead of Helm.

**Same application, different approach!**

## 📁 File Structure

```
lab7-voting-app-without-helm/
├── 00-namespace.yaml      # Namespace
├── 01-redis.yaml          # Redis deployment + service
├── 02-postgresql.yaml     # PostgreSQL deployment + service + config
├── 03-vote.yaml           # Vote frontend deployment + service  
├── 04-result.yaml         # Result frontend deployment + service
├── 05-worker.yaml         # Worker deployment
└── README.md              # This file
```

**Total: 6 YAML files, ~250 lines of code**

Compare to Helm version: **1 command, managed dependencies**

## 🆚 Comparison: Helm vs Raw YAML

### With Helm (Lab 7):
```bash
# Single command!
cd lab7-voting-app
helm dependency update  # Auto-downloads Redis & PostgreSQL charts
helm install voteapp .  # Deploys everything

# All dependencies managed automatically
# All services configured and connected
# All environment variables set correctly
```

### Without Helm (This Lab):
```bash
# Must deploy each component manually
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-redis.yaml
kubectl apply -f 02-postgresql.yaml
# Wait for databases to be ready...
kubectl wait --for=condition=ready pod -l component=redis -n voting-app
kubectl wait --for=condition=ready pod -l component=postgresql -n voting-app
kubectl apply -f 05-worker.yaml
kubectl apply -f 03-vote.yaml
kubectl apply -f 04-result.yaml

# Must manually manage:
# - Service names
# - Environment variables
# - Connection strings
# - Port numbers
# - Credentials
```

## 🚀 Quick Start

### Deploy All Services
```bash
cd lab7-voting-app-without-helm

# Deploy everything
kubectl apply -f .

# Watch pods starting
kubectl get pods -n voting-app -w
```

### Step-by-Step Deployment (Recommended)
```bash
# 1. Create namespace
kubectl apply -f 00-namespace.yaml

# 2. Deploy databases first
kubectl apply -f 01-redis.yaml
kubectl apply -f 02-postgresql.yaml

# 3. Wait for databases to be ready
kubectl wait --for=condition=ready pod -l component=redis -n voting-app --timeout=60s
kubectl wait --for=condition=ready pod -l component=postgresql -n voting-app --timeout=60s

# 4. Deploy worker (connects to both databases)
kubectl apply -f 05-worker.yaml

# 5. Deploy frontends
kubectl apply -f 03-vote.yaml
kubectl apply -f 04-result.yaml

# 6. Check all pods are running
kubectl get pods -n voting-app
```

## ✅ Access the Application

### Get Service URLs
```bash
# Vote service
kubectl get service vote -n voting-app

# Result service
kubectl get service result -n voting-app

# For Minikube
minikube service vote -n voting-app
minikube service result -n voting-app

# Or port-forward
kubectl port-forward -n voting-app service/vote 5000:80
kubectl port-forward -n voting-app service/result 5001:80
```

### Use the App
1. **Vote**: http://localhost:5000 - Cast your vote (Cats vs Dogs)
2. **Results**: http://localhost:5001 - See real-time results

## 🔍 Verify Everything Works

```bash
# Check all pods
kubectl get pods -n voting-app

# Check all services
kubectl get services -n voting-app

# Check worker logs (should show vote processing)
kubectl logs -n voting-app -l component=worker -f

# Test voting flow
# 1. Vote on http://localhost:5000
# 2. Watch worker logs process the vote
# 3. See results update on http://localhost:5001
```

## 📊 What Did We Have to Do Manually?

### 1. Hard-code Service Names
```yaml
# In every file, we had to know exact service names:
env:
  - name: REDIS_HOST
    value: "redis"  # Must match service name in 01-redis.yaml
  - name: POSTGRES_HOST
    value: "postgresql"  # Must match service name in 02-postgresql.yaml
```

**With Helm**: Service names generated automatically and referenced via templates

### 2. Hard-code Credentials
```yaml
# PostgreSQL credentials in MULTIPLE places:
# 02-postgresql.yaml:
POSTGRES_PASSWORD: "postgres"

# 04-result.yaml:
- name: POSTGRES_PASSWORD
  value: "postgres"

# 05-worker.yaml:
- name: POSTGRES_PASSWORD
  value: "postgres"
```

**With Helm**: Defined once in `values.yaml`, used everywhere

### 3. No Dependency Management
- Had to manually find and deploy Redis
- Had to manually find and deploy PostgreSQL
- Had to ensure correct versions
- Had to configure everything ourselves

**With Helm**: Dependencies auto-downloaded from Bitnami charts

### 4. No Configuration Flexibility
To change replicas, image versions, or resources:
```bash
# Must edit each file individually
vim 03-vote.yaml     # Change replicas
vim 04-result.yaml   # Change replicas
vim 05-worker.yaml   # Change replicas
# ... etc

# Then reapply each file
kubectl apply -f 03-vote.yaml
kubectl apply -f 04-result.yaml
kubectl apply -f 05-worker.yaml
```

**With Helm**:
```bash
helm upgrade voteapp . --set vote.replicaCount=5 --set result.replicaCount=3
```

## 🎯 Key Differences

| Aspect | Helm | Raw YAML |
|--------|------|----------|
| **Files** | 1 values.yaml + templates | 6 separate files |
| **Lines of Code** | ~100 (reusable) | ~250 (hardcoded) |
| **Dependencies** | Auto-managed | Manual deployment |
| **Credentials** | Defined once | Repeated 3+ times |
| **Service Names** | Dynamic | Hard-coded everywhere |
| **Customization** | --set flags | Edit files |
| **Upgrade** | 1 command | Edit multiple files |
| **Rollback** | `helm rollback` | Manual restore |
| **Versioning** | Built-in | Manual Git tags |

## 📝 Common Issues & Solutions

### Issue: Vote or Result Can't Connect to Database
```bash
# Check if databases are running
kubectl get pods -n voting-app -l component=redis
kubectl get pods -n voting-app -l component=postgresql

# Check service names are correct
kubectl get services -n voting-app

# Verify environment variables
kubectl describe pod -n voting-app -l component=vote | grep -A 10 "Environment"
```

### Issue: Worker Not Processing Votes
```bash
# Check worker logs
kubectl logs -n voting-app -l component=worker

# Common issues:
# - Redis not ready
# - PostgreSQL not ready
# - Wrong credentials
# - Wrong service names
```

### Issue: Want to Change PostgreSQL Password
```bash
# Must update in 3 places!
vim 02-postgresql.yaml  # Update POSTGRES_PASSWORD
vim 04-result.yaml      # Update POSTGRES_PASSWORD env var
vim 05-worker.yaml      # Update POSTGRES_PASSWORD env var

# Reapply all 3 files
kubectl apply -f 02-postgresql.yaml
kubectl apply -f 04-result.yaml
kubectl apply -f 05-worker.yaml

# Restart pods to pick up new password
kubectl rollout restart deployment/result -n voting-app
kubectl rollout restart deployment/worker -n voting-app
```

**With Helm**: Change once in values.yaml, helm upgrade

## 🧪 Exercises

### Exercise 1: Scale Vote Service
```bash
# Edit file
vim 03-vote.yaml
# Change: replicas: 2 → replicas: 5

# Reapply
kubectl apply -f 03-vote.yaml

# Verify
kubectl get pods -n voting-app -l component=vote
```

Compare to Helm:
```bash
helm upgrade voteapp . --set vote.replicaCount=5
```

### Exercise 2: Change Database Password
Try to change the PostgreSQL password. Count how many files you need to edit!

Answer: **3 files** (postgresql.yaml, result.yaml, worker.yaml)

### Exercise 3: Add Persistent Storage for PostgreSQL
```bash
# 1. Create PersistentVolumeClaim
# 2. Update 02-postgresql.yaml to use PVC instead of emptyDir
# 3. Reapply

# With Helm: --set postgresql.primary.persistence.enabled=true
```

## 🧹 Cleanup

```bash
# Delete namespace (deletes everything)
kubectl delete namespace voting-app

# Or delete individual files
kubectl delete -f .
```

## 💡 Lessons Learned

###When Helm Shines:
1. **DRY Principle**: Password defined once, not 3 times
2. **Dependency Management**: Redis & PostgreSQL auto-deployed
3. **Parameterization**: Easy customization via --set
4. **Service Discovery**: Auto-generated service names
5. **Versioning**: Built-in release management

### When Raw YAML is Painful:
1. **Repetition**: Same values copied everywhere
2. **Manual Coordination**: Must deploy in correct order
3. **Error-Prone**: Typos in service names break everything
4. **Hard to Maintain**: Changes require editing multiple files
5. **No Rollback**: Can't easily revert to previous state

## 🎓 Conclusion

This lab demonstrates that for a **5-service microservices application**:

- **With Helm**: 1 command, auto-managed dependencies, easy customization
- **Without Helm**: 6 files, manual deployment, error-prone configuration

Imagine scaling this to 20+ microservices! 😱

**Helm isn't just convenient—it's essential for complex applications!**

---

**Next**: Try Lab 10 (E-Commerce) without Helm for the ultimate challenge! 🚀
