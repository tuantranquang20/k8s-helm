# Lab 5: Advanced Features - WITHOUT Helm

## 🎯 Overview
This lab demonstrates the **same concepts as Lab 5** but using **plain Kubernetes YAML files** instead of Helm.

This shows you:
- ✅ What Helm does behind the scenes
- ✅ The verbosity of raw Kubernetes manifests
- ✅ **Why Helm is valuable** for managing complexity

## 📁 Files Structure

```
lab5-handons-without-helm/
├── 00-namespace.yaml          # Namespace for isolation
├── 01-secret.yaml             # Database credentials (base64 encoded)
├── 02-configmaps.yaml         # 4 ConfigMaps (vs 1 values.yaml in Helm)
├── 03-deployment.yaml         # Deployment + Service
├── 04-pre-install-job.yaml    # Pre-install hook simulation
└── README.md                  # This file
```

## 🆚 Helm vs Raw YAML Comparison

### With Helm (Lab 5):
```bash
# One command to deploy everything
helm install myapp lab5-handons

# Easy to customize
helm install myapp lab5-handons --set database.enabled=true

# Easy to upgrade
helm upgrade myapp lab5-handons --set replicaCount=5
```

### Without Helm (This Lab):
```bash
# Must apply files in order
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-secret.yaml
kubectl apply -f 02-configmaps.yaml
kubectl apply -f 04-pre-install-job.yaml
kubectl apply -f 03-deployment.yaml

# To customize, must edit YAML files manually
# To upgrade, must edit and reapply files
```

## 🚀 Deployment

### Option 1: Deploy All at Once
```bash
cd lab5-handons-without-helm
kubectl apply -f .
```

### Option 2: Deploy Step by Step (Recommended)
```bash
# Step 1: Create namespace
kubectl apply -f 00-namespace.yaml

# Step 2: Create secrets
kubectl apply -f 01-secret.yaml

# Step 3: Create ConfigMaps
kubectl apply -f 02-configmaps.yaml

# Step 4: Run pre-install hook
kubectl apply -f 04-pre-install-job.yaml

# Wait for job to complete
kubectl wait --for=condition=complete --timeout=60s job/pre-install-hook -n lab5-app

# Step 5: Deploy application
kubectl apply -f 03-deployment.yaml
```

## ✅ Verify Deployment

```bash
# Check namespace
kubectl get namespace lab5-app

# Check all resources
kubectl get all -n lab5-app

# Check ConfigMaps
kubectl get configmap -n lab5-app

# Check Secrets
kubectl get secret -n lab5-app
```

## 🔍 Inspect Resources

### View ConfigMaps
```bash
# View all ConfigMaps
kubectl get configmap -n lab5-app

# View specific ConfigMap
kubectl describe configmap app-config -n lab5-app

# View ConfigMap data
kubectl get configmap app-config -n lab5-app -o yaml
```

### View Secret (Base64 Encoded)
```bash
# View secret
kubectl get secret app-database-secret -n lab5-app -o yaml

# Decode secret values
kubectl get secret app-database-secret -n lab5-app -o jsonpath='{.data.username}' | base64 --decode
kubectl get secret app-database-secret -n lab5-app -o jsonpath='{.data.password}' | base64 --decode
```

### View Environment Variables in Pod
```bash
# Get pod name
POD=$(kubectl get pods -n lab5-app -l app=advanced-app -o jsonpath='{.items[0].metadata.name}')

# View all environment variables
kubectl exec -n lab5-app $POD -- env | sort

# View specific env vars
kubectl exec -n lab5-app $POD -- env | grep -E '(APP_NAME|ENVIRONMENT|DB_)'
```

## 📝 What's Different from Helm Version?

### 1. **No Templating**
**Helm:**
```yaml
replicas: {{ .Values.replicaCount }}
image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
```

**Raw YAML:**
```yaml
replicas: 2  # Hard-coded
image: nginx:1.21  # Hard-coded
```

### 2. **No Conditionals**
**Helm:**
```yaml
{{- if .Values.database.enabled }}
# Only create if enabled
{{- end }}
```

**Raw YAML:**
```yaml
# Must manually add/remove entire sections
# No built-in conditional logic
```

### 3. **No Loops**
**Helm:**
```yaml
{{- range .Values.extraEnvVars }}
- name: {{ .name }}
  value: {{ .value }}
{{- end }}
```

**Raw YAML:**
```yaml
# Must manually write each environment variable
- name: API_KEY
  value: "abc123"
- name: DEBUG
  value: "true"
# ... repeat for each variable
```

### 4. **No Helper Functions**
**Helm:**
```yaml
name: {{ include "app.fullname" . }}
labels:
  {{- include "app.labels" . | nindent 4 }}
```

**Raw YAML:**
```yaml
# Must manually repeat labels everywhere
labels:
  app: advanced-app
  # ... repeated in every resource
```

### 5. **No Dependencies**
**Helm:**
```yaml
# Chart.yaml
dependencies:
  - name: postgresql
    version: "12.x.x"
```

**Raw YAML:**
```yaml
# Must deploy PostgreSQL separately
# Must manage connection strings manually
```

## 🔧 Customization

### To Change Replicas
```bash
# Edit file
vim 03-deployment.yaml
# Change: replicas: 2 → replicas: 5

# Reapply
kubectl apply -f 03-deployment.yaml
```

### To Change Image
```bash
# Edit file
vim 03-deployment.yaml
# Change: image: nginx:1.21 → image: nginx:1.22

# Reapply
kubectl apply -f 03-deployment.yaml
```

### To Add Environment Variables
```bash
# Edit ConfigMap
vim 02-configmaps.yaml
# Add new key-value pair

# Edit Deployment
vim 03-deployment.yaml
# Add new env var reference

# Reapply both
kubectl apply -f 02-configmaps.yaml
kubectl apply -f 03-deployment.yaml
```

## 📊 Comparison Table

| Feature | Helm | Raw YAML |
|---------|------|----------|
| **Deploy** | 1 command | Multiple files/commands |
| **Customize** | `--set` flags | Edit YAML files |
| **Upgrade** | `helm upgrade` | Edit + reapply |
| **Rollback** | `helm rollback` | Manual restore |
| **Templating** | ✅ Yes | ❌ No |
| **Variables** | ✅ values.yaml | ❌ Hard-coded |
| **Conditionals** | ✅ Yes | ❌ No |
| **Loops** | ✅ Yes | ❌ No |
| **Dependencies** | ✅ Managed | ❌ Manual |
| **Versioning** | ✅ Built-in | ❌ Manual |
| **Package** | ✅ Single chart | ❌ Multiple files |
| **Reusability** | ✅ High | ❌ Low |

## 🎓 Key Takeaways

### Helm Advantages:
1. **DRY Principle**: Don't Repeat Yourself
2. **Parameterization**: Easy customization via values
3. **Templating**: Dynamic resource generation
4. **Dependency Management**: Automated subcomponent deployment
5. **Versioning**: Built-in release management
6. **Rollback**: Easy rollback to previous versions
7. **Package Management**: Distribute as single unit

### Raw YAML Challenges:
1. **Repetition**: Copy-paste same labels, names, etc.
2. **Hard-coded Values**: Must edit files for changes
3. **No Logic**: Can't use if/else or loops
4. **Manual Dependencies**: Must deploy/manage separately
5. **Version Control**: Must tag manually
6. **No Rollback**: Must manually restore previous state
7. **Multiple Files**: Harder to distribute

## 🧪 Exercises

### Exercise 1: Scale the Application
```bash
# Without Helm
vim 03-deployment.yaml  # Edit replicas: 2 → 5
kubectl apply -f 03-deployment.yaml

# With Helm (for comparison)
# helm upgrade myapp . --set replicaCount=5
```

### Exercise 2: Add New Environment Variable
```bash
# 1. Add to ConfigMap
vim 02-configmaps.yaml
# Add: NEW_VAR: "value"

# 2. Add to Deployment
vim 03-deployment.yaml
# Add env variable reference

# 3. Apply both
kubectl apply -f 02-configmaps.yaml
kubectl apply -f 03-deployment.yaml
```

### Exercise 3: Change Image Version
```bash
# Count how many places you need to change
grep -r "nginx:1.21" .
# Only 1 file!

# But imagine if you had 10 deployments...
# With Helm: Change 1 value in values.yaml
# Without Helm: Change 10 different files
```

## 🧹 Cleanup

```bash
# Delete all resources in namespace
kubectl delete namespace lab5-app

# Or delete individual files
kubectl delete -f .
```

## 💡 When to Use Raw YAML vs Helm

### Use Raw YAML When:
- ✅ Very simple, one-time deployment
- ✅ Learning Kubernetes basics
- ✅ Single environment (no dev/staging/prod)
- ✅ Resources rarely change
- ✅ Small number of resources (< 5)

### Use Helm When:
- ✅ Multiple environments (dev/staging/prod)
- ✅ Frequently updated applications
- ✅ Complex applications (> 5 resources)
- ✅ Need parameterization
- ✅ Need dependency management
- ✅ Team collaboration
- ✅ Production deployments

## 🎯 Conclusion

This lab demonstrates that while **raw Kubernetes YAML works**, Helm provides significant advantages for:
- **Maintainability**
- **Reusability**
- **Scalability**
- **Team collaboration**

**Key Insight**: As your application grows in complexity, Helm becomes increasingly valuable!

---

**Next**: Try Lab 6, 7, 8, 9, or 10 without Helm to see the complexity increase! 🚀
