# Lab 4 Hands-On: Creating Custom Helm Charts

## Overview
This lab demonstrates how to create a custom Helm chart with:
- Custom ConfigMaps
- Environment variables from ConfigMaps
- Multiple environment configurations (dev vs production)

## What's Included

### Files Created:
- `Chart.yaml` - Chart metadata
- `values.yaml` - Default configuration (development)
- `production-values.yaml` - Production configuration
- `templates/configmap.yaml` - Custom ConfigMap template
- `templates/deployment.yaml` - Modified deployment using ConfigMap
- `templates/service.yaml` - Standard service
- `templates/_helpers.tpl` - Helper functions

## Quick Start

### 1. Validate the Chart
```bash
cd lab4-handons
helm lint .
```

### 2. Preview Templates
```bash
# Preview with default values
helm template my-app .

# Preview with production values
helm template my-app . -f production-values.yaml
```

### 3. Install the Chart
```bash
# Install with development values (default)
helm install myapp-dev .

# Verify installation
kubectl get all -l app.kubernetes.io/instance=myapp-dev
kubectl get configmap
kubectl describe configmap myapp-dev-lab4-handons-config
```

### 4. Install with Production Values
```bash
# Install production version
helm install myapp-prod . -f production-values.yaml

# Compare the two deployments
kubectl get pods -l app.kubernetes.io/instance=myapp-dev
kubectl get pods -l app.kubernetes.io/instance=myapp-prod
```

### 5. Check Environment Variables
```bash
# Exec into a pod to see the environment variables
POD_NAME=$(kubectl get pods -l app.kubernetes.io/instance=myapp-dev -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD_NAME -- env | grep -E '(APP_NAME|ENVIRONMENT|LOG_LEVEL)'
```

## Key Learning Points

1. **ConfigMaps for Configuration**: Using ConfigMaps to externalize configuration
2. **Template Variables**: Using `{{ .Values.* }}` to reference values
3. **Environment-Specific Values**: Different configurations for dev vs prod
4. **Helper Templates**: Using `{{ include "..." }}` for reusable templates

## Configuration Options

### values.yaml (Development)
- `replicaCount: 2`
- `image.tag: "1.21"`
- `app.environment: development`
- `app.logLevel: info`

### production-values.yaml
- `replicaCount: 5`
- `image.tag: "1.22"`
- `app.environment: production`
- `app.logLevel: warning`
- `service.type: LoadBalancer`

## Exercises

1. **Modify Values**: Change the app name and see it reflected in the ConfigMap
2. **Add New Config**: Add a new configuration value to values.yaml and ConfigMap
3. **Create Staging**: Create a `staging-values.yaml` with 3 replicas
4. **Upgrade Release**: Modify values and upgrade an existing release

## Cleanup
```bash
helm uninstall myapp-dev
helm uninstall myapp-prod
```

## Next Steps
Move to **Lab 5** for advanced Helm features like conditionals, loops, and hooks!
