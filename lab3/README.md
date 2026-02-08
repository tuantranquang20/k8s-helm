# Lab 3: Introduction to Helm

## Objective
Install and use Helm to deploy applications from existing charts.

## Prerequisites
- Completed Lab 2
- Helm installed
- Kubernetes cluster running

## Exercises

### Exercise 1: Setup Helm Repositories
```bash
# Check Helm version
helm version

# Add Bitnami repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repositories
helm repo update

# List repositories
helm repo list

# Search for charts
helm search repo nginx
helm search repo mysql
```

### Exercise 2: Install a Chart with Default Values
```bash
# Install nginx from Bitnami
helm install my-nginx bitnami/nginx

# List installed releases
helm list

# Get release status
helm status my-nginx

# Get all Kubernetes resources created
kubectl get all -l app.kubernetes.io/instance=my-nginx
```

### Exercise 3: Install with Custom Values
```bash
# View default values for a chart
helm show values bitnami/nginx > nginx-default-values.yaml

# Install with custom values
helm install custom-nginx bitnami/nginx -f custom-nginx-values.yaml

# Verify custom configuration
kubectl get service custom-nginx
kubectl get deployment custom-nginx -o yaml | grep replicas
```

### Exercise 4: Upgrade a Release
```bash
# Modify custom-nginx-values.yaml (change replicaCount to 3)

# Upgrade with new values
helm upgrade custom-nginx bitnami/nginx -f custom-nginx-values.yaml

# Check revision history
helm history custom-nginx

# Verify the change
kubectl get pods -l app.kubernetes.io/instance=custom-nginx
```

### Exercise 5: Rollback a Release
```bash
# Rollback to previous version
helm rollback custom-nginx 1

# Verify rollback
helm history custom-nginx
kubectl get pods -l app.kubernetes.io/instance=custom-nginx
```

### Exercise 6: Cleanup
```bash
helm uninstall my-nginx
helm uninstall custom-nginx

# Verify removal
helm list
kubectl get all
```

## Checkpoints
- [ ] Added Helm repositories
- [ ] Searched for charts
- [ ] Installed a chart with default values
- [ ] Customized chart installation with values file
- [ ] Upgraded a release
- [ ] Rolled back a release
- [ ] Uninstalled releases

## Next Steps
Once you complete this lab, move on to **Lab 4: Creating Custom Helm Charts**.
