# Lab 10: E-Commerce Platform - WITHOUT Helm 😱

## 🛒 Overview

This is the **ULTIMATE COMPLEXITY SHOWCASE** - deploying a complete 9-service e-commerce platform using **plain Kubernetes YAML**.

**WARNING**: This demonstrates why Helm exists!

## 📁 File Structure (The Horror!)

```
lab10-ecommerce-without-helm/
├── 00-namespace.yaml          # Namespace
├── 01-postgresql.yaml         # PostgreSQL + Secret + PVC
├── 02-redis.yaml              # Redis
├── 03-rabbitmq.yaml           # RabbitMQ + Secret
├── 04-frontend.yaml           # Frontend storefront
├── 05-catalog.yaml            # Catalog microservice
├── 06-cart.yaml               # Cart microservice
├── 07-order.yaml              # Order microservice
├── 08-payment.yaml            # Payment microservice
├── 09-user.yaml               # User microservice
└── README.md                  # This file (survival guide)
```

**Total: 10 files, 800+ lines of YAML**

Compare to Helm: **1 command, managed dependencies** 🎯

## 🆚 The Brutal Comparison

### With Helm (Lab 10):
```bash
cd lab10-ecommerce
helm repo add bitnami https://charts.bitnami.com/bitnami
helm dependency update  # Auto-downloads PostgreSQL, Redis, RabbitMQ
helm install myshop .   # Deploys all 9 services perfectly

# Total time: 2 minutes
# Total commands: 3
# Total brain damage: 0
```

### Without Helm (This Lab):
```bash
# Deploy in exact order or everything breaks!
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-postgresql.yaml
kubectl apply -f 02-redis.yaml
kubectl apply -f 03-rabbitmq.yaml

# Wait for databases...
kubectl wait --for=condition=ready pod -l component=database -n ecommerce --timeout=120s
kubectl wait --for=condition=ready pod -l component=redis -n ecommerce --timeout=60s
kubectl wait --for=condition=ready pod -l component=rabbitmq -n ecommerce --timeout=60s

# Deploy microservices (must be in order!)
kubectl apply -f 05-catalog.yaml    # Catalog depends on PostgreSQL & Redis
kubectl apply -f 09-user.yaml       # User depends on PostgreSQL
kubectl apply -f 06-cart.yaml       # Cart depends on Redis
kubectl apply -f 07-order.yaml      # Order depends on PostgreSQL & RabbitMQ
kubectl apply -f 08-payment.yaml    # Payment depends on PostgreSQL
kubectl apply -f 04-frontend.yaml   # Frontend depends on ALL services

# Manual verification needed
kubectl get pods -n ecommerce
kubectl logs -n ecommerce -l component=catalog --tail=50
kubectl logs -n ecommerce -l component=order --tail=50
... (check each service individually)

# Total time: 15-30 minutes
# Total commands: 20+
# Total brain damage: Maximum
# Chance of errors: 95%
```

## 🔥 What Could Go Wrong? (Everything!)

### 1. **Wrong Service Names** (Most Common)
```yaml
# In 04-frontend.yaml:
env:
  - name: CATALOG_SERVICE_URL
    value: "http://catalog:8001"  # Must exactly match service name in 05-catalog.yaml

# In 05-catalog.yaml:
apiVersion: v1
kind: Service
metadata:
  name: catalog  # Typo here? Frontend can't connect!
```

**One typo = Everything breaks**

With Helm: Service names generated from templates, can't typo!

### 2. **Credentials Repeated Everywhere**
```yaml
# PostgreSQL password appears in:
# 01-postgresql.yaml: POSTGRES_PASSWORD
# 05-catalog.yaml:    DATABASE_URL (includes password)
# 07-order.yaml:      DATABASE_URL (includes password)
# 08-payment.yaml:    DATABASE_URL (includes password)
# 09-user.yaml:       DATABASE_URL (includes password)

# Change password? Edit 5 files!
# Miss one? Security vulnerability!
```

With Helm: Password in 1 place (values.yaml)

### 3. **Connection String Hell**
```yaml
# Must manually construct connection strings:
DATABASE_URL: "postgresql://ecommerce:ecommerce-password@postgresql:5432/ecommerce"
#                           ^^^^^^^^  ^^^^^^^^^^^^^^^^^^  ^^^^^^^^^^       ^^^^^^^^
#                           username  password (hardcoded!) service name   database

# Redis URL:
REDIS_URL: "redis://redis:6379"
#                   ^^^^^ Must match service name

# RabbitMQ URL:
RABBITMQ_URL: "amqp://admin:admin123@rabbitmq:5672"
#                     ^^^^^  ^^^^^^^^ ^^^^^^^^
#                     user   password  service name
```

With Helm: URLs generated from values automatically

### 4. **Port Numbers Everywhere**
```yaml
# Frontend needs to know ALL service ports:
- name: CATALOG_SERVICE_URL
  value: "http://catalog:8001"  # Port 8001
- name: CART_SERVICE_URL
  value: "http://cart:8002"     # Port 8002
- name: ORDER_SERVICE_URL
  value: "http://order:8003"    # Port 8003
- name: PAYMENT_SERVICE-URL
  value: "http://payment:8004"  # Port 8004
- name: USER_SERVICE_URL
  value: "http://user:8005"     # Port 8005

# Change a port? Update frontend + service definition
```

With Helm: Ports referenced from values

### 5. **No Dependency Management**
```yaml
# Must manually:
# 1. Find PostgreSQL chart/YAML
# 2. Find Redis chart/YAML
# 3. Find RabbitMQ chart/YAML
# 4. Ensure compatible versions
# 5. Configure each manually
# 6. Deploy in correct order
```

With Helm: `dependencies:` in Chart.yaml, done!

## 🚀 Deployment (Good Luck!)

### Prerequisites
```bash
# Make sure you have a cluster with:
# - At least 4 CPU cores
# - At least 8GB RAM
# - Storage class for PVCs
# - Lots of patience
# - Coffee ☕
```

### The Deployment Saga

#### Step 1: Deploy Infrastructure (5-10 min)
```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-postgresql.yaml
kubectl apply -f 02-redis.yaml
kubectl apply -f 03-rabbitmq.yaml

# Wait... and wait... and wait...
kubectl get pods -n ecommerce -w

# Troubleshoot when PVC is Pending:
kubectl get pvc -n ecommerce
kubectl describe pvc postgres-pvc -n ecommerce
# Oh no, need to configure storage class!
```

#### Step 2: Verify Infrastructure (5 min)
```bash
# Test PostgreSQL
PG_POD=$(kubectl get pods -n ecommerce -l component=database -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n ecommerce -it $PG_POD -- psql -U ecommerce -c '\l'

# Test Redis
REDIS_POD=$(kubectl get pods -n ecommerce -l component=redis -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n ecommerce -it $REDIS_POD -- redis-cli ping

# Test RabbitMQ
kubectl logs -n ecommerce -l component=rabbitmq | grep "ready"
```

#### Step 3: Deploy Microservices (10 min)
```bash
# Deploy in dependency order!
kubectl apply -f 05-catalog.yaml
kubectl apply -f 09-user.yaml
kubectl apply -f 06-cart.yaml
kubectl apply -f 07-order.yaml
kubectl apply -f 08-payment.yaml

# Wait for all to be running
kubectl get pods -n ecommerce

# If any fail, debug one by one:
kubectl describe pod <failing-pod> -n ecommerce
kubectl logs <failing-pod> -n ecommerce
```

#### Step 4: Deploy Frontend (2 min)
```bash
kubectl apply -f 04-frontend.yaml

# Verify it can reach all services
FRONTEND_POD=$(kubectl get pods -n ecommerce -l component=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n ecommerce -it $FRONTEND_POD -- env | grep SERVICE_URL
```

#### Step 5: Verify Everything (10 min)
```bash
# Check all pods
kubectl get pods -n ecommerce

# Check all services
kubectl get services -n ecommerce

# Test each microservice
kubectl port-forward -n ecommerce service/catalog 8001:8001 &
curl http://localhost:8001  # Should return something

kubectl port-forward -n ecommerce service/cart 8002:8002 &
curl http://localhost:8002  # Should return something

# ... repeat for all 6 microservices
```

**Total deployment time**: 30+ minutes (if lucky!)

## 😱 Common Disasters

### Disaster 1: Wrong Deployment Order
```bash
# You deployed frontend before databases
kubectl apply -f 04-frontend.yaml  # Deployed first
kubectl apply -f 01-postgresql.yaml  # Deployed after

# Result: Frontend pods crash-looping
# Solution: Delete frontend, wait for DB, redeploy frontend
kubectl delete -f 04-frontend.yaml
kubectl wait --for=condition=ready pod -l component=database -n ecommerce
kubectl apply -f 04-frontend.yaml
```

### Disaster 2: Typo in Service Name
```yaml
# 04-frontend.yaml has:
value: "http://catologue:8001"  # Typo! Should be "catalog"

# Result: Frontend can't connect to catalog
# How to find: Check frontend logs
kubectl logs -n ecommerce -l component=frontend
# Error: "Failed to connect to catologue:8001"

# Fix: Edit 04-frontend.yaml, fix typo, reapply
vim 04-frontend.yaml
kubectl apply -f 04-frontend.yaml
kubectl rollout restart deployment/frontend -n ecommerce
```

### Disaster 3: Password Mismatch
```yaml
# 01-postgresql.yaml has:
POSTGRES_PASSWORD: "ecommerce-password"

# But 05-catalog.yaml has:
DATABASE_URL: "postgresql://ecommerce:wrong-password@postgresql:5432/ecommerce"

# Result: Catalog can't connect to database
# Fix: Update password in ALL 5 places it appears!
```

### Disaster 4: Port Collision
```yaml
# You changed catalog port from 8001 to 9001:
# 05-catalog.yaml:
ports:
  - containerPort: 9001  # Changed!

# But forgot to update frontend:
# 04-frontend.yaml:
value: "http://catalog:8001"  # Still using old port!

# Fix: Update in both places
```

## 🎯 Scaling Nightmare

### Scale a Single Service
```bash
# With Helm:
helm upgrade myshop . --set catalog.replicaCount=5

# Without Helm:
vim 05-catalog.yaml  # Edit replicas: 2 → 5
kubectl apply -f 05-catalog.yaml
```

### Scale Everything for Black Friday
```bash
# With Helm:
helm upgrade myshop . \
  --set frontend.replicaCount=10 \
  --set catalog.replicaCount=8 \
  --set cart.replicaCount=8 \
  --set order.replicaCount=12 \
  --set payment.replicaCount=10

# Without Helm:
vim 04-frontend.yaml  # Edit replicas
vim 05-catalog.yaml   # Edit replicas
vim 06-cart.yaml      # Edit replicas
vim 07-order.yaml     # Edit replicas
vim 08-payment.yaml   # Edit replicas
kubectl apply -f 04-frontend.yaml
kubectl apply -f 05-catalog.yaml
kubectl apply -f 06-cart.yaml
kubectl apply -f 07-order.yaml
kubectl apply -f 08-payment.yaml
# Don't forget to scale back after Black Friday!
```

## 🧹 Cleanup

```bash
# Delete namespace (easiest)
kubectl delete namespace ecommerce

# Or pray you have all the files
kubectl delete -f .
```

## 📊 The Damage Report

| Metric | Helm | Raw YAML | Difference |
|--------|------|----------|------------|
| **Files** | 1 values.yaml | 10 YAML files | 10x more |
| **Lines of Code** | ~150 | ~800+ | 5x more |
| **Commands to Deploy** | 3 | 20+ | 7x more |
| **Time to Deploy** | 2 min | 30+ min | 15x longer |
| **Credentials Repeated** | 1 place | 5+ places | 5x duplication |
| **Service Names Hard-coded** | 0 | 20+ places | Infinite pain |
| **Chance of Typo** | Low | **EXTREMELY HIGH** | 😱 |
| **Rollback Capability** | 1 command | Manual restore | 💀 |
| **Multi-environment** | Easy | Nightmare | 🔥 |

## 💡 Lessons Learned

### Why This is Insane:

1. **Repetition Everywhere**: Same values copied 10+ times
2. **Error-Prone**: One typo breaks everything
3. **No Validation**: Deploy broken config, find out later
4. **Hard to Maintain**: Change requires editing multiple files
5. **Manual Coordination**: Must deploy in exact order
6. **No Rollback**: Can't easily undo changes
7. **No Versioning**: Must manually track what's deployed

### What Helm Provides:

1. **Single Source of Truth**: values.yaml
2. **Template Validation**: Catches errors before deployment
3. **Dependency Management**: Auto-manages PostgreSQL, Redis, RabbitMQ
4. **One-Command Deployment**: `helm install`
5. **One-Command Rollback**: `helm rollback`
6. **Built-in Versioning**: Track all releases
7. **Easy Customization**: --set flags

## 🎓 Conclusion

If you've made it this far, you  understand **WHY HELM EXISTS**.

Managing 9 microservices with raw YAML is:
- ❌ Time-consuming
- ❌ Error-prone
- ❌ Hard to maintain
- ❌ Impossible to scale
- ❌ Career-limiting

**Helm isn't a luxury—it's a necessity!**

---

**Congratulations on surviving this nightmare!** Now go use Helm! 🚀

**P.S.**: If you actually deployed this successfully without errors on the first try, you're either:
1. Lying
2. A Kubernetes wizard
3. Using Helm and don't want to admit it 😉
