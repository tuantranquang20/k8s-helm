# Lab 5: Advanced Helm Features - Detailed Instructions

## Overview
This lab teaches you advanced Helm templating techniques used in production environments.

---

## Exercise 1: Conditionals in Templates

### Step 1.1: Create a Conditional Secret

Create `advanced-chart/templates/secret.yaml`:

```yaml
{{- if .Values.database.enabled }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "advanced-chart.fullname" . }}-db-secret
  labels:
    {{- include "advanced-chart.labels" . | nindent 4 }}
type: Opaque
data:
  username: {{ .Values.database.username | b64enc | quote }}
  password: {{ .Values.database.password | b64enc | quote }}
  host: {{ .Values.database.host | b64enc | quote }}
{{- end }}
```

### Step 1.2: Add Database Values

Add to `advanced-chart/values.yaml`:

```yaml
database:
  enabled: false
  username: admin
  password: changeme
  host: postgres
  port: 5432
  name: myapp
```

### Step 1.3: Test Conditional

```bash
# Without database (default - no secret created)
helm template test advanced-chart/ | grep -A5 Secret

# With database enabled (secret is created)
helm template test advanced-chart/ --set database.enabled=true | grep -A10 Secret
```

---

## Exercise 2: Loops in Templates

### Step 2.1: Create ConfigMap with Loops

Create `advanced-chart/templates/extra-configmap.yaml`:

```yaml
{{- if .Values.extraEnvVars }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "advanced-chart.fullname" . }}-extra-env
  labels:
    {{- include "advanced-chart.labels" . | nindent 4 }}
data:
  {{- range .Values.extraEnvVars }}
  {{ .name }}: {{ .value | quote }}
  {{- end }}
{{- end }}
```

### Step 2.2: Add Extra Environment Variables

Add to `advanced-chart/values.yaml`:

```yaml
extraEnvVars: []
# Example usage:
# extraEnvVars:
#   - name: API_KEY
#     value: "12345"
#   - name: DEBUG_MODE
#     value: "true"
#   - name: MAX_CONNECTIONS
#     value: "100"
```

### Step 2.3: Create Test Values File

Create `lab5/extra-env-values.yaml`:

```yaml
extraEnvVars:
  - name: API_KEY
    value: "abc123xyz"
  - name: DEBUG_MODE
    value: "true"
  - name: MAX_CONNECTIONS
    value: "100"
  - name: CACHE_TTL
    value: "3600"
```

### Step 2.4: Test Loop

```bash
# Test with extra env vars
helm template test advanced-chart/ -f extra-env-values.yaml | grep -A10 "extra-env"
```

---

## Exercise 3: Template Functions

### Step 3.1: Create Labels Demo ConfigMap

Create `advanced-chart/templates/functions-demo.yaml`:

```yaml
{{- if .Values.functionsDemo.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "advanced-chart.fullname" . }}-functions-demo
  labels:
    {{- include "advanced-chart.labels" . | nindent 4 }}
    # String manipulation functions
    app-upper: {{ .Values.app.name | upper | quote }}
    app-lower: {{ .Values.app.name | lower | quote }}
    app-title: {{ .Values.app.name | title | quote }}
    # Default value function
    log-level: {{ .Values.app.logLevel | default "info" | quote }}
    # Replace function
    env-cleaned: {{ .Values.app.environment | replace "dev" "development" | quote }}
data:
  # Trim whitespace
  trimmed: {{ "  some text with spaces  " | trim | quote }}
  
  # Join list
  {{- if .Values.tags }}
  tags: {{ .Values.tags | join "," | quote }}
  {{- end }}
  
  # Number to string
  max-replicas: {{ .Values.replicaCount | toString | quote }}
  
  # Conditional with default
  cache-enabled: {{ .Values.cache.enabled | default false | quote }}
{{- end }}
```

### Step 3.2: Add Values for Functions

Add to `advanced-chart/values.yaml`:

```yaml
functionsDemo:
  enabled: false

app:
  name: myapp
  environment: dev
  logLevel: info

tags:
  - production
  - web
  - frontend

cache:
  enabled: true
```

### Step 3.3: Test Functions

```bash
# Enable and test functions demo
helm template test advanced-chart/ --set functionsDemo.enabled=true | grep -A20 "functions-demo"
```

---

## Exercise 4: Named Templates (Helpers)

### Step 4.1: Add Custom Helpers

Edit `advanced-chart/templates/_helpers.tpl` and add these custom helpers at the end:

```yaml
{{/*
Generate database connection string
*/}}
{{- define "advanced-chart.databaseURL" -}}
{{- if .Values.database.enabled -}}
postgresql://{{ .Values.database.username }}:{{ .Values.database.password }}@{{ .Values.database.host }}:{{ .Values.database.port }}/{{ .Values.database.name }}
{{- else -}}
sqlite:///tmp/db.sqlite
{{- end -}}
{{- end -}}

{{/*
Generate Redis URL
*/}}
{{- define "advanced-chart.redisURL" -}}
{{- if .Values.redis.enabled -}}
redis://:{{ .Values.redis.password }}@{{ .Values.redis.host }}:{{ .Values.redis.port }}/0
{{- else -}}
redis://localhost:6379/0
{{- end -}}
{{- end -}}

{{/*
Calculate resource limits based on environment
*/}}
{{- define "advanced-chart.resourceLimits" -}}
{{- if eq .Values.app.environment "production" -}}
cpu: 500m
memory: 512Mi
{{- else if eq .Values.app.environment "staging" -}}
cpu: 250m
memory: 256Mi
{{- else -}}
cpu: 100m
memory: 128Mi
{{- end -}}
{{- end -}}
```

### Step 4.2: Create ConfigMap Using Helpers

Create `advanced-chart/templates/connection-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "advanced-chart.fullname" . }}-connections
  labels:
    {{- include "advanced-chart.labels" . | nindent 4 }}
data:
  database-url: {{ include "advanced-chart.databaseURL" . | quote }}
  redis-url: {{ include "advanced-chart.redisURL" . | quote }}
  environment: {{ .Values.app.environment | quote }}
```

### Step 4.3: Add Redis Values

Add to `advanced-chart/values.yaml`:

```yaml
redis:
  enabled: false
  host: redis
  port: 6379
  password: redispass
```

### Step 4.4: Test Helpers

```bash
# Test with database enabled
helm template test advanced-chart/ --set database.enabled=true | grep -A5 "connections"

# Test with both enabled
helm template test advanced-chart/ \
  --set database.enabled=true \
  --set redis.enabled=true \
  | grep -A7 "connections"
```

---

## Exercise 5: Chart Dependencies

### Step 5.1: Add Dependencies to Chart.yaml

Edit `advanced-chart/Chart.yaml` and add:

```yaml
dependencies:
  - name: postgresql
    version: "12.x.x"
    repository: "https://charts.bitnami.com/bitnami"
    condition: postgresql.enabled
  - name: redis
    version: "17.x.x"
    repository: "https://charts.bitnami.com/bitnami"
    condition: redis.enabled
```

### Step 5.2: Configure Dependencies

Add to `advanced-chart/values.yaml`:

```yaml
postgresql:
  enabled: false
  auth:
    username: myapp
    password: myapppassword
    database: myappdb
  primary:
    persistence:
      enabled: false

redis:
  enabled: false
  auth:
    password: redispassword
  master:
    persistence:
      enabled: false
```

### Step 5.3: Update Dependencies

```bash
cd advanced-chart/
helm dependency update
cd ..

# Check downloaded charts
ls -la advanced-chart/charts/
```

### Step 5.4: Install with Dependencies

```bash
# Install with PostgreSQL
helm install advanced-with-db advanced-chart/ --set postgresql.enabled=true

# Install with both PostgreSQL and Redis
helm install advanced-full advanced-chart/ \
  --set postgresql.enabled=true \
  --set redis.enabled=true

# Check what was created
kubectl get all
```

---

## Exercise 6: Helm Hooks

### Step 6.1: Create Pre-Install Hook

Create `advanced-chart/templates/hooks/pre-install-job.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "advanced-chart.fullname" . }}-pre-install
  labels:
    {{- include "advanced-chart.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    metadata:
      name: {{ include "advanced-chart.fullname" . }}-pre-install
    spec:
      restartPolicy: Never
      containers:
      - name: pre-install
        image: busybox
        command:
          - sh
          - -c
          - |
            echo "===================================="
            echo "Running pre-install hook"
            echo "Checking prerequisites..."
            echo "Environment: {{ .Values.app.environment }}"
            echo "===================================="
            sleep 5
            echo "Pre-install checks completed!"
```

### Step 6.2: Create Post-Install Hook

Create `advanced-chart/templates/hooks/post-install-job.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "advanced-chart.fullname" . }}-post-install
  labels:
    {{- include "advanced-chart.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    metadata:
      name: {{ include "advanced-chart.fullname" . }}-post-install
    spec:
      restartPolicy: Never
      containers:
      - name: post-install
        image: busybox
        command:
          - sh
          - -c
          - |
            echo "===================================="
            echo "Running post-install hook"
            echo "Performing post-deployment tasks..."
            echo "Application: {{ .Values.app.name }}"
            echo "===================================="
            sleep 5
            echo "Post-install tasks completed!"
```

### Step 6.3: Test Hooks

```bash
# Install and watch hooks execute
helm install advanced-hooks advanced-chart/ --debug

# Check for hook jobs
kubectl get jobs

# View hook logs
kubectl logs job/advanced-hooks-pre-install
kubectl logs job/advanced-hooks-post-install
```

---

## Exercise 7: Chart Testing

### Step 7.1: Create Test Pod

Create `advanced-chart/templates/tests/test-connection.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "advanced-chart.fullname" . }}-test-connection
  labels:
    {{- include "advanced-chart.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
spec:
  containers:
  - name: wget
    image: busybox
    command: ['wget']
    args: ['{{ include "advanced-chart.fullname" . }}:{{ .Values.service.port }}']
  restartPolicy: Never
```

### Step 7.2: Create Advanced Test

Create `advanced-chart/templates/tests/test-configmap.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "advanced-chart.fullname" . }}-test-config
  labels:
    {{- include "advanced-chart.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
spec:
  containers:
  - name: test
    image: busybox
    command:
      - sh
      - -c
      - |
        echo "Testing ConfigMap existence..."
        if [ -f /config/database-url ]; then
          echo "✓ ConfigMap mounted successfully"
          exit 0
        else
          echo "✗ ConfigMap not found"
          exit 1
        fi
    volumeMounts:
    - name: config
      mountPath: /config
  volumes:
  - name: config
    configMap:
      name: {{ include "advanced-chart.fullname" . }}-connections
  restartPolicy: Never
```

### Step 7.3: Run Tests

```bash
# Install the chart
helm install advanced-test advanced-chart/

# Run tests
helm test advanced-test

# View test logs
kubectl logs advanced-test-test-connection
kubectl logs advanced-test-test-config

# Check test status
kubectl get pods -l helm.sh/chart-test=true
```

---

## Complete Example Values File

Create `lab5/complete-values.yaml`:

```yaml
replicaCount: 3

image:
  repository: nginx
  tag: "1.22"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

app:
  name: advanced-app
  environment: staging
  logLevel: debug

database:
  enabled: true
  username: appuser
  password: securepassword
  host: postgres
  port: 5432
  name: appdb

redis:
  enabled: true
  host: redis
  port: 6379
  password: redispass

extraEnvVars:
  - name: API_ENDPOINT
    value: "https://api.example.com"
  - name: FEATURE_FLAG_NEW_UI
    value: "true"
  - name: MAX_UPLOAD_SIZE
    value: "10485760"

tags:
  - staging
  - backend
  - api

functionsDemo:
  enabled: true

postgresql:
  enabled: true
  auth:
    username: appuser
    password: securepassword
    database: appdb
```

---

## Verification Commands

```bash
# Lint the chart
helm lint advanced-chart/

# Template with complete values
helm template advanced-complete advanced-chart/ -f complete-values.yaml

# Install with complete configuration
helm install advanced-complete advanced-chart/ -f complete-values.yaml

# Verify all resources
kubectl get all
kubectl get configmaps
kubectl get secrets
kubectl get jobs

# Run tests
helm test advanced-complete

# Check release history
helm history advanced-complete
```

---

## Cleanup

```bash
# Uninstall all releases
helm uninstall advanced-hooks
helm uninstall advanced-with-db
helm uninstall advanced-full
helm uninstall advanced-test
helm uninstall advanced-complete

# Delete test pods
kubectl delete pods -l helm.sh/chart-test=true

# Verify cleanup
helm list
kubectl get all
```

---

## Summary

You've learned:
- ✅ Conditional rendering with `{{- if }}`
- ✅ Loops with `{{- range }}`
- ✅ Template functions (upper, lower, default, etc.)
- ✅ Custom named templates in `_helpers.tpl`
- ✅ Chart dependencies via `Chart.yaml`
- ✅ Helm hooks (pre-install, post-install)
- ✅ Chart testing with test pods

## Next Level

Now you're ready to:
1. Build production-grade Helm charts
2. Contribute to public Helm repositories
3. Create chart libraries for your organization
4. Implement GitOps workflows with Helm

Congratulations! 🎉🚀
