# Lab 4: Detailed Instructions

## Step-by-Step Guide

### Step 1: Create the Chart

Run this command from the `lab4/` directory:
```bash
helm create myapp
```

This creates a chart with the following structure:
```
myapp/
├── Chart.yaml          # Metadata about the chart
├── values.yaml         # Default configuration values
├── charts/             # Dependencies (other charts)
├── templates/          # Kubernetes manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── _helpers.tpl   # Template helpers
│   └── NOTES.txt      # Usage notes
└── .helmignore        # Files to ignore
```

### Step 2: Customize Chart.yaml

Edit `myapp/Chart.yaml`:

```yaml
apiVersion: v2
name: myapp
description: A custom Helm chart for my application
type: application
version: 1.0.0
appVersion: "1.0"
keywords:
  - web
  - demo
maintainers:
  - name: Your Name
    email: you@example.com
```

### Step 3: Customize values.yaml

Edit `myapp/values.yaml` and add custom values at the bottom:

```yaml
# ... keep existing values ...

# Add these custom values at the end
app:
  name: myapp
  environment: development
  logLevel: info
```

### Step 4: Create ConfigMap Template

Create a new file `myapp/templates/configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "myapp.fullname" . }}-config
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
data:
  app.name: {{ .Values.app.name | quote }}
  app.environment: {{ .Values.app.environment | quote }}
  log.level: {{ .Values.app.logLevel | quote }}
```

### Step 5: Update Deployment

Edit `myapp/templates/deployment.yaml` and add environment variables.

Find the `containers:` section and add the `env:` block:

```yaml
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        # ADD THIS SECTION:
        env:
        - name: APP_NAME
          valueFrom:
            configMapKeyRef:
              name: {{ include "myapp.fullname" . }}-config
              key: app.name
        - name: ENVIRONMENT
          valueFrom:
            configMapKeyRef:
              name: {{ include "myapp.fullname" . }}-config
              key: app.environment
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: {{ include "myapp.fullname" . }}-config
              key: log.level
        resources:
          {{- toYaml .Values.resources | nindent 12 }}
```

### Step 6: Create Production Values File

Create `myapp-production.yaml` in the `lab4/` directory:

```yaml
replicaCount: 5

image:
  repository: nginx
  tag: "1.22"

service:
  type: LoadBalancer
  port: 80

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

app:
  environment: production
  logLevel: warning
```

### Step 7: Validate Your Chart

```bash
# Lint the chart
helm lint myapp/

# Should output: "1 chart(s) linted, 0 chart(s) failed"
```

### Step 8: Test Templating

```bash
# See what would be created
helm template myapp myapp/

# Test with production values
helm template myapp-prod myapp/ -f myapp-production.yaml
```

### Step 9: Install and Verify

```bash
# Install the chart
helm install myapp-release myapp/

# Check what was created
helm list
kubectl get all -l app.kubernetes.io/instance=myapp-release
kubectl get configmap -l app.kubernetes.io/instance=myapp-release

# View the ConfigMap contents
kubectl describe configmap myapp-release-config
```

### Step 10: Install with Production Values

```bash
# Install with production configuration
helm install myapp-prod myapp/ -f myapp-production.yaml

# Compare the two deployments
echo "Development Pods:"
kubectl get pods -l app.kubernetes.io/instance=myapp-release

echo "Production Pods:"
kubectl get pods -l app.kubernetes.io/instance=myapp-prod
```

## Tips

1. **Indent carefully**: YAML is sensitive to indentation (use 2 spaces)
2. **Use `helm template`**: Always preview before installing
3. **Check logs**: If pods don't start, check: `kubectl logs <pod-name>`
4. **Describe resources**: Use `kubectl describe` for detailed info

## Common Issues

### Issue: Template rendering errors
**Solution**: Check indentation and bracket matching in templates

### Issue: Pod not starting
**Solution**: Run `kubectl describe pod <pod-name>` to see events

### Issue: ConfigMap not found
**Solution**: Ensure ConfigMap template is in `templates/` directory

## Verification

After completing all steps, you should have:
- ✅ A working Helm chart in `myapp/`
- ✅ Custom ConfigMap with app configuration
- ✅ Deployment using values from ConfigMap
- ✅ Two different deployments (dev and prod) from same chart
- ✅ Packaged chart file (`myapp-1.0.0.tgz`)

Ready to move on? Great! Head to **Lab 5** for advanced features! 🚀
