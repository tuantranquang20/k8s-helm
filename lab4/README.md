# Lab 4: Creating Custom Helm Charts

## Objective
Create your own Helm chart from scratch.

## Prerequisites
- Completed Lab 3
- Understanding of Helm basics

## Exercises

### Exercise 1: Create a New Chart
```bash
# Navigate to lab4 directory
cd lab4

# Create a new chart (this will create a myapp/ directory)
helm create myapp

# Explore the chart structure
tree myapp/
# or
ls -la myapp/
```

### Exercise 2: Customize the Chart
Follow the instructions in `myapp/INSTRUCTIONS.md` to:
1. Edit `Chart.yaml` with your metadata
2. Customize `values.yaml` 
3. Create a ConfigMap template
4. Update the Deployment to use the ConfigMap

### Exercise 3: Validate the Chart
```bash
# Lint the chart
helm lint myapp/

# Template the chart (dry-run)
helm template myapp myapp/

# Template with a specific release name
helm template my-release myapp/
```

### Exercise 4: Install Your Chart
```bash
# Install the chart
helm install myapp-release myapp/

# Verify installation
kubectl get all -l app.kubernetes.io/instance=myapp-release
kubectl get configmap
kubectl describe configmap myapp-release-config
```

### Exercise 5: Test with Custom Values
```bash
# Use the production values file
helm template myapp-prod myapp/ -f myapp-production.yaml

# Install with production values
helm install myapp-prod myapp/ -f myapp-production.yaml

# Compare resources
kubectl get pods -l app.kubernetes.io/instance=myapp-release
kubectl get pods -l app.kubernetes.io/instance=myapp-prod
```

### Exercise 6: Package the Chart
```bash
# Package the chart
helm package myapp/

# This creates: myapp-1.0.0.tgz

# Install from the package
helm install myapp-from-package myapp-1.0.0.tgz
```

### Exercise 7: Cleanup
```bash
helm uninstall myapp-release
helm uninstall myapp-prod
helm uninstall myapp-from-package
```

## Checkpoints
- [ ] Created a new Helm chart
- [ ] Customized Chart.yaml and values.yaml
- [ ] Created a ConfigMap template
- [ ] Modified deployment to use ConfigMap
- [ ] Validated chart with `helm lint`
- [ ] Tested chart with `helm template`
- [ ] Installed chart with custom values
- [ ] Packaged the chart
- [ ] Cleaned up all releases

## Files to Create/Modify
- `myapp/Chart.yaml` - Chart metadata
- `myapp/values.yaml` - Default values
- `myapp/templates/configmap.yaml` - New ConfigMap template
- `myapp/templates/deployment.yaml` - Modified deployment
- `myapp-production.yaml` - Production values

See `INSTRUCTIONS.md` for detailed step-by-step guidance.

## Next Steps
Once you complete this lab, move on to **Lab 5: Advanced Helm Features**.
