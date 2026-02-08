# Kubernetes and Helm Lab Guide

## Prerequisites

Before starting these labs, ensure you have:

1. **Kubernetes Cluster** (one of the following):
   - Minikube (local cluster)
   - Docker Desktop with Kubernetes enabled
   - Kind (Kubernetes in Docker)
   - Cloud provider (GKE, EKS, AKS)

2. **Tools Installed**:
   - `kubectl` - Kubernetes command-line tool
   - `helm` - Helm package manager
   - `git` - Version control

3. **Verify Installation**:
   ```bash
   kubectl version --client
   helm version
   kubectl cluster-info
   ```

---

## Lab Setup

### Option 1: Using Minikube

```bash
# Install Minikube (macOS)
brew install minikube

# Start Minikube
minikube start --driver=docker

# Verify cluster is running
kubectl get nodes
```

### Option 2: Using Docker Desktop

1. Open Docker Desktop
2. Go to Preferences → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"

### Option 3: Using Kind

```bash
# Install Kind (macOS)
brew install kind

# Create a cluster
kind create cluster --name lab-cluster

# Verify
kubectl cluster-info --context kind-lab-cluster
```

---

## Lab 1: Basic Kubernetes Deployment

**Objective**: Learn to create and manage Pods, Deployments, and basic kubectl commands.

### Step 1: Create a Simple Pod

Create a file named `nginx-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    environment: lab
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

Deploy the Pod:

```bash
# Apply the configuration
kubectl apply -f nginx-pod.yaml

# Verify Pod is running
kubectl get pods

# Get detailed information
kubectl describe pod nginx-pod

# View logs
kubectl logs nginx-pod

# Execute command in the Pod
kubectl exec -it nginx-pod -- /bin/bash
# Inside the container, you can run: curl localhost
# Exit with: exit
```

### Step 2: Create a Deployment

Create `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: "100m"
            memory: "128Mi"
          requests:
            cpu: "50m"
            memory: "64Mi"
```

Deploy and manage:

```bash
# Create deployment
kubectl apply -f nginx-deployment.yaml

# Watch Pods being created
kubectl get pods -w

# Check deployment status
kubectl get deployments
kubectl describe deployment nginx-deployment

# Check ReplicaSet
kubectl get replicasets
```

### Step 3: Scale the Deployment

```bash
# Scale to 5 replicas
kubectl scale deployment nginx-deployment --replicas=5

# Verify
kubectl get pods

# Scale back to 3 (can also edit the YAML and re-apply)
kubectl scale deployment nginx-deployment --replicas=3
```

### Step 4: Update the Deployment

```bash
# Update the image version
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# Watch the rollout
kubectl rollout status deployment/nginx-deployment

# View rollout history
kubectl rollout history deployment/nginx-deployment

# Rollback if needed
kubectl rollout undo deployment/nginx-deployment
```

### Step 5: Cleanup Lab 1

```bash
# Delete resources
kubectl delete -f nginx-pod.yaml
kubectl delete -f nginx-deployment.yaml

# Or delete by name
kubectl delete pod nginx-pod
kubectl delete deployment nginx-deployment
```

### ✅ Lab 1 Checkpoints

- [ ] Successfully created and viewed a Pod
- [ ] Created a Deployment with multiple replicas
- [ ] Scaled a Deployment up and down
- [ ] Updated a Deployment image
- [ ] Rolled back a Deployment
- [ ] Cleaned up all resources

---

## Lab 2: Services and Networking

**Objective**: Understand how Services provide networking and load balancing for Pods.

### Step 1: Create a Deployment

Create `web-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

Apply it:

```bash
kubectl apply -f web-deployment.yaml
kubectl get pods -l app=web
```

### Step 2: Create a ClusterIP Service

Create `web-service-clusterip.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

Deploy and test:

```bash
# Create service
kubectl apply -f web-service-clusterip.yaml

# Get service details
kubectl get services
kubectl describe service web-service

# Get the ClusterIP
CLUSTER_IP=$(kubectl get service web-service -o jsonpath='{.spec.clusterIP}')
echo $CLUSTER_IP

# Test from within the cluster (create a test Pod)
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service
```

### Step 3: Create a NodePort Service

Create `web-service-nodeport.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080  # Optional: specify port (range: 30000-32767)
```

Deploy and access:

```bash
# Create NodePort service
kubectl apply -f web-service-nodeport.yaml

# Get service details
kubectl get service web-nodeport

# For Minikube, get the URL
minikube service web-nodeport --url

# For Docker Desktop or other local clusters
# Access via: http://localhost:30080

# Or use kubectl port-forward
kubectl port-forward service/web-nodeport 8080:80
# Then access: http://localhost:8080
```

### Step 4: Create a LoadBalancer Service (if supported)

Create `web-service-lb.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

Deploy:

```bash
# Create LoadBalancer service
kubectl apply -f web-service-lb.yaml

# Get service (may show <pending> for local clusters)
kubectl get service web-loadbalancer

# For Minikube, use tunnel in a separate terminal
minikube tunnel

# Get external IP
kubectl get service web-loadbalancer
```

### Step 5: Test Service Load Balancing

Create a custom nginx page to see load balancing:

```bash
# Create a ConfigMap with custom HTML for each Pod
kubectl create configmap custom-html --from-literal=index.html='<h1>Hello from Pod!</h1>'

# Update deployment to use ConfigMap (not shown here for brevity)
# Or manually update each Pod to demonstrate load balancing

# Make multiple requests to see different Pods responding
for i in {1..10}; do
  kubectl run test-$i --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service
done
```

### Step 6: Cleanup Lab 2

```bash
kubectl delete -f web-deployment.yaml
kubectl delete -f web-service-clusterip.yaml
kubectl delete -f web-service-nodeport.yaml
kubectl delete -f web-service-lb.yaml
```

### ✅ Lab 2 Checkpoints

- [ ] Created ClusterIP service and accessed it internally
- [ ] Created NodePort service and accessed it from outside
- [ ] Created LoadBalancer service (if supported)
- [ ] Understood the difference between service types
- [ ] Observed load balancing across multiple Pods
- [ ] Cleaned up all resources

---

## Lab 3: Introduction to Helm

**Objective**: Install and use Helm to deploy applications from existing charts.

### Step 1: Verify Helm Installation

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

### Step 2: Install a Chart

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

### Step 3: Customize Installation with Values

```bash
# View default values for a chart
helm show values bitnami/nginx > nginx-default-values.yaml

# View the default values
cat nginx-default-values.yaml
```

Create `custom-nginx-values.yaml`:

```yaml
replicaCount: 2

service:
  type: NodePort
  nodePorts:
    http: 30081

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

Install with custom values:

```bash
# Install with custom values
helm install custom-nginx bitnami/nginx -f custom-nginx-values.yaml

# Verify custom configuration
kubectl get service custom-nginx
kubectl get deployment custom-nginx -o yaml | grep replicas
```

### Step 4: Upgrade a Release

Modify `custom-nginx-values.yaml`:

```yaml
replicaCount: 3  # Changed from 2

service:
  type: NodePort
  nodePorts:
    http: 30081

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

Upgrade the release:

```bash
# Upgrade with new values
helm upgrade custom-nginx bitnami/nginx -f custom-nginx-values.yaml

# Check revision history
helm history custom-nginx

# Verify the change
kubectl get pods -l app.kubernetes.io/instance=custom-nginx
```

### Step 5: Rollback a Release

```bash
# Rollback to previous version
helm rollback custom-nginx 1

# Verify rollback
helm history custom-nginx
kubectl get pods -l app.kubernetes.io/instance=custom-nginx
```

### Step 6: Uninstall Releases

```bash
# Uninstall releases
helm uninstall my-nginx
helm uninstall custom-nginx

# Verify removal
helm list
kubectl get all
```

### ✅ Lab 3 Checkpoints

- [ ] Added Helm repositories
- [ ] Searched for charts
- [ ] Installed a chart with default values
- [ ] Customized chart installation with values file
- [ ] Upgraded a release
- [ ] Rolled back a release
- [ ] Uninstalled releases

---

## Lab 4: Creating Custom Helm Charts

**Objective**: Create your own Helm chart from scratch.

### Step 1: Create a New Chart

```bash
# Create a new chart
helm create myapp

# Explore the chart structure
tree myapp/
```

You'll see:
```
myapp/
├── Chart.yaml
├── charts/
├── templates/
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   └── tests/
└── values.yaml
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

Edit `myapp/values.yaml`:

```yaml
replicaCount: 2

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi

autoscaling:
  enabled: false

# Custom values
app:
  name: myapp
  environment: development
  logLevel: info
```

### Step 4: Create a ConfigMap Template

Create `myapp/templates/configmap.yaml`:

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

### Step 5: Update Deployment to Use ConfigMap

Edit `myapp/templates/deployment.yaml` to add environment variables from ConfigMap:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
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

### Step 6: Validate and Test the Chart

```bash
# Lint the chart
helm lint myapp/

# Template the chart (dry-run, see what would be created)
helm template myapp myapp/

# Template with a specific release name
helm template my-release myapp/

# Install the chart
helm install myapp-release myapp/

# Verify installation
kubectl get all -l app.kubernetes.io/instance=myapp-release
kubectl get configmap
kubectl describe configmap myapp-release-config
```

### Step 7: Create Custom Values Files

Create `myapp-production.yaml`:

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

Test with production values:

```bash
# Template with production values
helm template myapp-prod myapp/ -f myapp-production.yaml

# Install with production values
helm install myapp-prod myapp/ -f myapp-production.yaml

# Compare resources
kubectl get pods -l app.kubernetes.io/instance=myapp-release
kubectl get pods -l app.kubernetes.io/instance=myapp-prod
```

### Step 8: Package the Chart

```bash
# Package the chart
helm package myapp/

# This creates: myapp-1.0.0.tgz

# Install from the package
helm install myapp-from-package myapp-1.0.0.tgz
```

### Step 9: Cleanup Lab 4

```bash
helm uninstall myapp-release
helm uninstall myapp-prod
helm uninstall myapp-from-package
```

### ✅ Lab 4 Checkpoints

- [ ] Created a new Helm chart
- [ ] Customized Chart.yaml and values.yaml
- [ ] Created a ConfigMap template
- [ ] Modified deployment to use ConfigMap
- [ ] Validated chart with `helm lint`
- [ ] Tested chart with `helm template`
- [ ] Installed chart with custom values
- [ ] Packaged the chart
- [ ] Cleaned up all releases

---

## Lab 5: Advanced Helm Features

**Objective**: Learn advanced Helm templating, conditionals, and loops.

### Step 1: Conditionals in Templates

Create `myapp/templates/secret.yaml`:

```yaml
{{- if .Values.database.enabled }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "myapp.fullname" . }}-db-secret
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
type: Opaque
data:
  username: {{ .Values.database.username | b64enc | quote }}
  password: {{ .Values.database.password | b64enc | quote }}
{{- end }}
```

Add to `myapp/values.yaml`:

```yaml
database:
  enabled: false
  username: admin
  password: changeme
  host: postgres
  port: 5432
```

Test conditional:

```bash
# Without database (default)
helm template myapp myapp/ | grep -A5 Secret

# With database enabled
helm template myapp myapp/ --set database.enabled=true | grep -A5 Secret
```

### Step 2: Using Loops

Create `myapp/templates/extra-configmap.yaml`:

```yaml
{{- if .Values.extraEnvVars }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "myapp.fullname" . }}-extra-env
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
data:
  {{- range .Values.extraEnvVars }}
  {{ .name }}: {{ .value | quote }}
  {{- end }}
{{- end }}
```

Add to `myapp/values.yaml`:

```yaml
extraEnvVars: []
# Example:
# extraEnvVars:
#   - name: API_KEY
#     value: "12345"
#   - name: DEBUG_MODE
#     value: "true"
```

Test with values:

```bash
# Create test values file
cat > extra-env-values.yaml <<EOF
extraEnvVars:
  - name: API_KEY
    value: "abc123xyz"
  - name: DEBUG_MODE
    value: "true"
  - name: MAX_CONNECTIONS
    value: "100"
EOF

# Template with extra env vars
helm template myapp myapp/ -f extra-env-values.yaml
```

### Step 3: Template Functions

Create `myapp/templates/labels-demo.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "myapp.fullname" . }}-labels-demo
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
    # Upper case
    app-upper: {{ .Values.app.name | upper | quote }}
    # Lower case
    app-lower: {{ .Values.app.name | lower | quote }}
    # Title case
    app-title: {{ .Values.app.name | title | quote }}
    # Replace
    app-replaced: {{ .Values.app.name | replace "app" "application" | quote }}
    # Default value
    log-level: {{ .Values.app.logLevel | default "info" | quote }}
data:
  # Trim whitespace
  trimmed: {{ " some text " | trim | quote }}
  # Join list
  {{- if .Values.tags }}
  tags: {{ .Values.tags | join "," | quote }}
  {{- end }}
```

Add to `myapp/values.yaml`:

```yaml
tags:
  - production
  - web
  - frontend
```

### Step 4: Named Templates (Helpers)

Edit `myapp/templates/_helpers.tpl` to add custom helper:

```yaml
{{/*
Generate database connection string
*/}}
{{- define "myapp.databaseURL" -}}
{{- if .Values.database.enabled -}}
postgresql://{{ .Values.database.username }}:{{ .Values.database.password }}@{{ .Values.database.host }}:{{ .Values.database.port }}/{{ .Values.database.name }}
{{- else -}}
sqlite:///tmp/db.sqlite
{{- end -}}
{{- end -}}
```

Use the helper in a ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "myapp.fullname" . }}-database
data:
  database-url: {{ include "myapp.databaseURL" . | quote }}
```

### Step 5: Chart Dependencies

Create `myapp/Chart.yaml` with dependencies:

```yaml
apiVersion: v2
name: myapp
description: A custom Helm chart for my application
type: application
version: 1.0.0
appVersion: "1.0"

dependencies:
  - name: postgresql
    version: 12.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
  - name: redis
    version: 17.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled
```

Update `myapp/values.yaml`:

```yaml
postgresql:
  enabled: false
  auth:
    username: myapp
    password: myapppassword
    database: myappdb

redis:
  enabled: false
  auth:
    password: redispassword
```

Update dependencies:

```bash
# Download dependencies
cd myapp/
helm dependency update

# This downloads charts to charts/ directory
ls -la charts/

# Template with dependencies enabled
helm template myapp . --set postgresql.enabled=true --set redis.enabled=true
```

### Step 6: Hooks

Create `myapp/templates/pre-install-job.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "myapp.fullname" . }}-pre-install
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    metadata:
      name: {{ include "myapp.fullname" . }}-pre-install
    spec:
      restartPolicy: Never
      containers:
      - name: pre-install
        image: busybox
        command: ['sh', '-c', 'echo "Running pre-install hook"; sleep 5']
```

Test hook:

```bash
# Install and watch the hook
helm install myapp-hooks myapp/ --debug

# Check for the job
kubectl get jobs

# View job logs
kubectl logs job/myapp-hooks-pre-install
```

### Step 7: Chart Testing

Create `myapp/templates/tests/test-connection.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "myapp.fullname" . }}-test-connection
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
spec:
  containers:
  - name: wget
    image: busybox
    command: ['wget']
    args: ['{{ include "myapp.fullname" . }}:{{ .Values.service.port }}']
  restartPolicy: Never
```

Run tests:

```bash
# Install the chart
helm install myapp-test myapp/

# Run tests
helm test myapp-test

# View test results
kubectl logs myapp-test-test-connection
```

### Step 8: Cleanup Lab 5

```bash
helm uninstall myapp-hooks
helm uninstall myapp-test
rm extra-env-values.yaml
```

### ✅ Lab 5 Checkpoints

- [ ] Used conditionals in templates
- [ ] Implemented loops for dynamic values
- [ ] Applied template functions (upper, lower, replace, etc.)
- [ ] Created custom named templates in _helpers.tpl
- [ ] Added chart dependencies
- [ ] Implemented Helm hooks
- [ ] Created and ran chart tests
- [ ] Cleaned up all resources

---

## Additional Exercises

### Challenge 1: Multi-Environment Deployment

Create separate values files for `development`, `staging`, and `production` environments with different:
- Replica counts
- Resource limits
- Service types
- ConfigMap values

Deploy the same chart to different namespaces with different configurations.

### Challenge 2: Full-Stack Application

Create a Helm chart that deploys:
1. Frontend (Nginx serving static files)
2. Backend API (Node.js or Python)
3. Database (PostgreSQL via dependency)
4. Redis cache (via dependency)

Connect them properly with Services and ConfigMaps.

### Challenge 3: CI/CD Integration

Create a simple CI/CD pipeline that:
1. Lints the Helm chart
2. Runs `helm template` to validate
3. Deploys to a test namespace
4. Runs `helm test`
5. Promotes to production if tests pass

---

## Troubleshooting Tips

### Common Kubectl Issues

```bash
# Pod is not starting
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # For crashed pods

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Pod networking issues
kubectl exec -it <pod-name> -- ping <service-name>
kubectl exec -it <pod-name> -- nslookup <service-name>

# Resource issues
kubectl top nodes
kubectl top pods
```

### Common Helm Issues

```bash
# Helm deployment stuck
helm list
helm status <release-name>
kubectl get all -l app.kubernetes.io/instance=<release-name>

# Template rendering issues
helm template <release-name> <chart-path> --debug

# Lint errors
helm lint <chart-path> --debug

# Failed upgrade
helm rollback <release-name>
helm history <release-name>

# Cleanup failed releases
helm uninstall <release-name>
kubectl delete all -l app.kubernetes.io/instance=<release-name>
```

### Debugging Template Syntax

```bash
# See what values are available
helm show values <chart>

# Render templates locally
helm template <release-name> <chart-path>

# Render with specific values
helm template <release-name> <chart-path> -f custom-values.yaml --debug

# Check specific template
helm template <release-name> <chart-path> -s templates/deployment.yaml
```

---

## Quick Reference

### Essential Kubectl Commands

```bash
# Cluster info
kubectl cluster-info
kubectl get nodes

# Resources
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get all

# With labels
kubectl get pods -l app=nginx
kubectl get all --selector=environment=production

# Describe
kubectl describe pod <pod-name>
kubectl describe deployment <deployment-name>

# Logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow
kubectl logs <pod-name> -c <container-name>  # Multi-container

# Execute
kubectl exec -it <pod-name> -- /bin/bash

# Port forward
kubectl port-forward <pod-name> 8080:80
kubectl port-forward service/<service-name> 8080:80

# Apply/Delete
kubectl apply -f <file>.yaml
kubectl delete -f <file>.yaml
kubectl delete pod <pod-name>

# Scaling
kubectl scale deployment <name> --replicas=3

# Namespaces
kubectl get namespaces
kubectl get pods -n <namespace>
kubectl config set-context --current --namespace=<namespace>
```

### Essential Helm Commands

```bash
# Repository management
helm repo add <name> <url>
helm repo update
helm repo list
helm search repo <keyword>

# Install/Upgrade/Uninstall
helm install <release-name> <chart>
helm install <release-name> <chart> -f values.yaml
helm upgrade <release-name> <chart>
helm uninstall <release-name>

# List and status
helm list
helm status <release-name>
helm history <release-name>

# Rollback
helm rollback <release-name> <revision>

# Chart operations
helm create <chart-name>
helm lint <chart-path>
helm template <release-name> <chart-path>
helm package <chart-path>

# Values
helm show values <chart>
helm get values <release-name>

# Testing
helm test <release-name>

# Dependencies
helm dependency update <chart-path>
helm dependency list <chart-path>
```

---

## Next Steps

After completing these labs, you should:

1. **Practice Regularly**: Deploy real applications to reinforce learning
2. **Explore Public Charts**: Study well-maintained charts on [Artifact Hub](https://artifacthub.io/)
3. **Learn Advanced Topics**:
   - StatefulSets for stateful applications
   - DaemonSets for node-level services
   - Custom Resource Definitions (CRDs)
   - Operators and Helm operator pattern
   - Network Policies
   - RBAC (Role-Based Access Control)
4. **Production Readiness**:
   - Monitoring (Prometheus, Grafana)
   - Logging (ELK, Loki)
   - Security scanning
   - Disaster recovery
5. **Join the Community**:
   - Kubernetes Slack
   - CNCF meetups
   - Contribute to open-source charts

---

## Resources

- **Official Documentation**:
  - [Kubernetes Docs](https://kubernetes.io/docs/)
  - [Helm Docs](https://helm.sh/docs/)

- **Interactive Learning**:
  - [Kubernetes Playground](https://www.katacoda.com/courses/kubernetes)
  - [Play with Kubernetes](https://labs.play-with-k8s.com/)

- **Chart Repositories**:
  - [Artifact Hub](https://artifacthub.io/)
  - [Bitnami Charts](https://github.com/bitnami/charts)

Happy Learning! 🚀
