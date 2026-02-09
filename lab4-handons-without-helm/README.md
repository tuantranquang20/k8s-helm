# Lab 4: Custom Helm Charts - WITHOUT Helm

## 📦 Overview

This lab shows you how to create a **custom application deployment** using raw Kubernetes YAML, compared to Helm's templating approach.

**Key Learning**: See how much you must duplicate for multi-environment deployments!

## 📁 File Structure

```
lab4-handons-without-helm/
├── 00-namespace.yaml      # Namespace
├── 01-configmap.yaml      # Development ConfigMap
├── 02-deployment.yaml     # Development Deployment + Service
├── 03-production.yaml     # Production ConfigMap + Deployment + Service
└── README.md
```

**Total: 4 files, ~150 lines**

Compare to Helm: **1 values.yaml + 1 production-values.yaml + templates**

## 🆚 The Problem: Multi-Environment Deployments

### With Helm (Lab 4):

**values.yaml** (development):
```yaml
replicaCount: 2
image:
  tag: "1.21"
service:
  type: ClusterIP
resources:
  limits:
    cpu: 200m
    memory: 256Mi
app:
  environment: development
  logLevel: info
```

**production-values.yaml** (overrides):
```yaml
replicaCount: 5
image:
  tag: "1.22"
service:
  type: LoadBalancer
resources:
  limits:
    cpu: 500m
    memory: 512Mi
app:
  environment: production
  logLevel: error
```

**Deploy**:
```bash
# Development
helm install myapp .

# Production
helm install myapp-prod . -f production-values.yaml
```

**Same templates, different values!** ✨

---

### Without Helm (This Lab):

Must create **completely separate files** for dev and prod:

**02-deployment.yaml** (development - 80 lines):
```yaml
# Entire deployment with:
replicas: 2
image: nginx:1.21
type: ClusterIP
cpu: 200m
memory: 256Mi
environment: development
log-level: info
```

**03-production.yaml** (production - 110 lines):
```yaml
# COPY the entire deployment and change:
replicas: 5
image: nginx:1.22
type: LoadBalancer
cpu: 500m
memory: 512Mi
environment: production
log-level: error
```

**Duplicate ~90% of code!** 😱

---

## 🚀 Deployment

### Development Environment

```bash
cd lab4-handons-without-helm

# Deploy development
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-configmap.yaml
kubectl apply -f 02-deployment.yaml

# Verify
kubectl get pods -n custom-app
kubectl get service -n custom-app

# Access
kubectl port-forward -n custom-app service/nginx-app 8080:80
```

Visit: **http://localhost:8080**

---

### Production Environment

```bash
# Deploy production (from same directory!)
kubectl apply -f 03-production.yaml

# Verify
kubectl get pods -n custom-app -l environment=production
kubectl get service -n custom-app -l environment=production

# Access
kubectl port-forward -n custom-app service/nginx-app-prod 8081:80
```

Visit: **http://localhost:8081**

---

## 😱 The Duplication Problem

### What's Duplicated Between Dev & Prod?

**EVERYTHING except a few values!**

| Item | Dev | Prod | Duplicated? |
|------|-----|------|-------------|
| Namespace | custom-app | custom-app | ✅ |
| Labels | Same structure | Same structure | ✅ |
| Container spec | Same | Same | ✅ |
| Ports | Same | Same | ✅ |
| Env var structure | Same | Same | ✅ |
| Probes | Same | Same | ✅ |
| Service spec | Same | Same | ✅ |
| **Replicas** | 2 | 5 | ❌ Different |
| **Image tag** | 1.21 | 1.22 | ❌ Different |
| **Service type** | ClusterIP | LoadBalancer | ❌ Different |
| **Resources** | Low | High | ❌ Different |
| **Log level** | info | error | ❌ Different |

**Result**: ~90% duplication just to change 5 values!

---

## 🔧 Common Scenarios

### Scenario 1: Change Image Version

**With Helm**:
```bash
# Update values.yaml
image:
  tag: "1.23"

# Apply to both environments
helm upgrade myapp .
helm upgrade myapp-prod . -f production-values.yaml
```

**Without Helm**:
```bash
# Edit 02-deployment.yaml
vim 02-deployment.yaml
# Find: image: nginx:1.21
# Change to: image: nginx:1.23

# Edit 03-production.yaml
vim 03-production.yaml
# Find: image: nginx:1.22
# Change to: image: nginx:1.23

# Apply both
kubectl apply -f 02-deployment.yaml
kubectl apply -f 03-production.yaml
```

**Helm: 1 edit** vs **Raw YAML: 2 edits**

---

### Scenario 2: Add New Environment Variable

**With Helm**:
```yaml
# Add to values.yaml
env:
  - name: NEW_VAR
    value: "new-value"

# Template automatically adds to all environments
# helm upgrade both
```

**Without Helm**:
```yaml
# Edit 02-deployment.yaml - Add to env section
env:
  - name: APP_NAME
    valueFrom: ...
  - name: ENVIRONMENT
    valueFrom: ...
  - name: LOG_LEVEL
    valueFrom: ...
  - name: NEW_VAR  # <-- Add here
    value: "new-value"

# Edit 03-production.yaml - Add to env section
env:
  - name: APP_NAME
    valueFrom: ...
  - name: ENVIRONMENT
    valueFrom: ...
  - name: LOG_LEVEL
    valueFrom: ...
  - name: NEW_VAR  # <-- Add here AGAIN
    value: "new-value"

# Must keep both in sync!
```

**Helm: 1 place** vs **Raw YAML: 2 places (must stay in sync!)**

---

### Scenario 3: Add Staging Environment

**With Helm**:
```yaml
# Create staging-values.yaml
replicaCount: 3
image:
  tag: "1.22"
service:
  type: ClusterIP
resources:
  limits:
    cpu: 300m
    memory: 384Mi
app:
  environment: staging
  logLevel: warn

# Deploy
helm install myapp-staging . -f staging-values.yaml
```

**Total files**: 1 new value file (~15 lines)

---

**Without Helm**:
```yaml
# Create 04-staging.yaml
# COPY ENTIRE 03-production.yaml (~110 lines)
# Change every occurrence of:
# - replicas: 5 -> 3
# - image: nginx:1.22 -> nginx:1.22 (same)
# - type: LoadBalancer -> ClusterIP
# - cpu: 500m -> 300m
# - memory: 512Mi -> 384Mi
# - environment: production -> staging
# - log-level: error -> warn
# - All label selectors
# - All service names

# Deploy
kubectl apply -f 04-staging.yaml
```

**Total files**: 1 new file (~110 lines - mostly duplicated!)

---

## 📊 Comparison Table

| Task | Helm | Raw YAML | Winner |
|------|------|----------|--------|
| **Deploy Dev** | `helm install app .` | Apply 3 files | 🏆 Helm |
| **Deploy Prod** | `helm install app . -f prod.yaml` | Apply 1 file (110 lines!) | 🏆 Helm |
| **Add Environment** | Create 1 value file (~15 lines) | Duplicate entire deployment (~110 lines) | 🏆 Helm (7x less code!) |
| **Change Image** | Edit 1 value | Edit N deployment files | 🏆 Helm |
| **Add Env Var** | Edit 1 values file | Edit N deployment files | 🏆 Helm |
| **Keep Consistency** | Automatic (same template) | Manual (easy to break) | 🏆 Helm |

---

## 🎯 Real-World Impact

### 3 Environments (Dev, Staging, Prod):

**With Helm**:
- 1 set of templates (~100 lines total)
- 3 value files (~15 lines each = 45 lines)
- **Total: 145 lines**
- Easy to keep consistent
- Change template = all environments updated

**Without Helm**:
- 3 complete deployments (~110 lines each = 330 lines)
- 3 ConfigMaps (~15 lines each = 45 lines)
- **Total: 375 lines**
- Hard to keep consistent
- Change one thing = update 3 files

**Helm saves 60% code!**

---

### 10 Microservices × 3 Environments:

**With Helm**:
- 10 templates
- 30 value files
- **~1,500 lines total**

**Without Helm**:
- 30 complete deployment files
- 90+ YAML files total
- **~3,300+ lines total**
- Nightmare to maintain!

**Helm saves 55% code + sanity!**

---

## 🔥 What Goes Wrong?

### Problem 1: Out of Sync

```bash
# You update dev deployment
vim 02-deployment.yaml
# Add new health check

# Deploy dev
kubectl apply -f 02-deployment.yaml

# Forgot to update production!
# Production still has old health check
# Inconsistency between environments!
```

**With Helm**: Impossible! Same template = same health check

---

### Problem 2: Copy-Paste Errors

```bash
# Creating staging from production
cp 03-production.yaml 04-staging.yaml

# Edit staging file
vim 04-staging.yaml
# Change replicas: 5 -> 3 ✅
# Change environment: production -> staging ✅
# Change service name to nginx-app-staging ✅
# Forgot to change selector! Still points to production pods ❌

# Deploy staging
kubectl apply -f 04-staging.yaml
# Service doesn't work - wrong selector!
```

**With Helm**: Template validation catches this!

---

### Problem 3: Scaling Nightmare

```bash
# Need to change replica count for all environments
vim 02-deployment.yaml  # replicas: 2 -> 3
vim 03-production.yaml  # replicas: 5 -> 7
vim 04-staging.yaml     # replicas: 3 -> 4

# Apply all 3
kubectl apply -f 02-deployment.yaml
kubectl apply -f 03-production.yaml
kubectl apply -f 04-staging.yaml
```

**With Helm**:
```bash
helm upgrade myapp . --set replicaCount=3
helm upgrade myapp-prod . -f prod.yaml --set replicaCount=7
helm upgrade myapp-staging . -f staging.yaml --set replicaCount=4
```

Or better:
```bash
# Update value files once
helm upgrade myapp .
helm upgrade myapp-prod . -f prod.yaml
helm upgrade myapp-staging . -f staging.yaml
```

---

## 💡 Key Takeaways

### Why This is Painful:

1. **Massive Duplication**: 90% of code is identical
2. **Error-Prone**: Easy to forget updating all environments
3. **Hard to Maintain**: Change requires editing multiple files
4. **No Validation**: Copy-paste errors not caught
5. **Scaling Issues**: More environments = more duplication

### What Helm Provides:

1. **DRY Principle**: Template once, use everywhere
2. **Consistency**: Same template = guaranteed consistency
3. **Easy Customization**: Just override values
4. **Validation**: Template errors caught early
5. **Scalability**: Add environments easily

---

## 🧪 Exercises

### Exercise 1: Add Annotation

Add `prometheus.io/scrape: "true"` annotation to both deployments.

**Count**: How many places did you edit?

**Answer**: 2 (dev + prod)

**With Helm**: 1 place (template)

---

### Exercise 2: Change Port

Change container port from 80 to 8080.

**What must change?**
- Container port
- Service targetPort
- Liveness probe port
- Readiness probe port

**Files to edit**: 2 (dev + prod)

**Lines to change per file**: 4

**Total changes**: 8 lines

**With Helm**: Edit 1 value, template handles all 8 places!

---

### Exercise 3: Add 4th Environment (DR)

Create a disaster recovery environment with:
- 10 replicas
- Latest image
- LoadBalancer service
- High resources

**How to do it**:
1. Copy 03-production.yaml -> 05-dr.yaml
2. Edit all occurrences of environment
3. Change all values
4. Cross fingers you didn't miss anything

**With Helm**: Create dr-values.yaml (15 lines), done!

---

## 🧹 Cleanup

```bash
# Delete everything
kubectl delete namespace custom-app

# Or selective cleanup
kubectl delete -f 02-deployment.yaml  # Dev only
kubectl delete -f 03-production.yaml  # Prod only
```

---

## 🎓 Conclusion

**Lab 4 without Helm shows:**

- ✅ Basic deployment works
- ❌ Multi-environment = massive duplication
- ❌ Easy to get out of sync
- ❌ Hard to maintain
- ❌ Doesn't scale

**Lab 4 WITH Helm:**
- ✅ Templates + values = DRY
- ✅ Guaranteed consistency
- ✅ Easy to maintain
- ✅ Scales infinitely

**Verdict**: For single environment, raw YAML is fine. For multi-environment, **Helm is essential**!

---

**Next**: Try Lab 5 to see even more Helm advantages (conditionals, loops, functions)!

**Key Insight**: The more environments you have, the more valuable Helm becomes! 🚀
