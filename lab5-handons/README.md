# Lab 5 Hands-On: Advanced Helm Features

## Overview
This lab demonstrates advanced Helm templating features:
- ✅ Conditionals (`{{- if }}`)
- ✅ Loops (`{{- range }}`)
- ✅ Template functions (upper, lower, join, etc.)
- ✅ Custom helper functions
- ✅ Chart dependencies (PostgreSQL, Redis)
- ✅ Helm hooks (pre-install, post-install)
- ✅ Chart testing

## What's Included

### Templates:
- `secret.yaml` - Conditional secret (only if database.enabled)
- `extra-configmap.yaml` - ConfigMap with loops
- `functions-demo.yaml` - Demonstrates template functions
- `connection-config.yaml` - Uses custom helper functions
- `hooks/pre-install-job.yaml` - Pre-install hook
- `hooks/post-install-job.yaml` - Post-install hook
- `tests/test-connection.yaml` - Service connection test
- `tests/test-configmap.yaml` - ConfigMap test

### Custom Helpers (`_helpers.tpl`):
- `lab5-handons.databaseURL` - Generates database connection string
- `lab5-handons.redisURL` - Generates Redis connection string
- `lab5-handons.resourceLimits` - Calculates resources based on environment

## Quick Start

### 1. Install Dependencies
```bash
cd lab5-handons
helm dependency update
ls -la charts/
```

### 2. Test Conditionals
```bash
# Without database (no secret created)
helm template test . | grep -A10 Secret

# With database enabled (secret created)
helm template test . --set database.enabled=true | grep -A10 Secret
```

### 3. Test Loops
```bash
# Create values file with extra env vars
cat > test-values.yaml <<EOF
extraEnvVars:
  - name: API_KEY
    value: "abc123"
  - name: DEBUG
    value: "true"
EOF

# Template with loops
helm template test . -f test-values.yaml | grep -A10 "extra-env"
```

### 4. Test Template Functions
```bash
# Enable functions demo
helm template test . --set functionsDemo.enabled=true | grep -A15 "functions-demo"
```

### 5. Install with Hooks
```bash
# Install and watch hooks execute
helm install advanced . --debug

# Check hook jobs
kubectl get jobs
kubectl logs job/advanced-lab5-handons-pre-install
kubectl logs job/advanced-lab5-handons-post-install
```

###  6. Install with Dependencies
```bash
# Install with PostgreSQL
helm install fullstack . --set postgresql.enabled=true

# Check all pods
kubectl get pods

# Check PostgreSQL pod
kubectl get pods -l app.kubernetes.io/name=postgresql
```

### 7. Run Tests
```bash
# Install the chart
helm install testapp .

# Run Helm tests
helm test testapp

# View test results
kubectl get pods -l helm.sh/chart-test=true
kubectl logs testapp-lab5-handons-test-connection
```

## Testing Individual Features

### Conditional Secret
```bash
# Disable database (default)
helm template test . | grep -c "kind: Secret"  # Should be 0

# Enable database
helm template test . --set database.enabled=true | grep -c "kind: Secret"  # Should be 1
```

### Loops with Environment Variables
```bash
helm template test . \
  --set 'extraEnvVars[0].name=VAR1' \
  --set 'extraEnvVars[0].value=value1' \
  --set 'extraEnvVars[1].name=VAR2' \
  --set 'extraEnvVars[1].value=value2'
```

### Custom Helper Functions
```bash
# Check database URL generation
helm template test . --set database.enabled=true | grep "database-url"

# Check Redis URL generation  
helm template test . --set redis.enabled=true | grep "redis-url"
```

### Dependencies
```bash
# List dependencies
helm dependency list

# Update dependencies
helm dependency update

# Check downloaded charts
ls charts/
```

## Configuration Examples

### Minimal Installation
```bash
helm install minimal .
```

### With Database
```bash
helm install withdb . --set database.enabled=true
```

### With Database and Redis
```bash
helm install fullstack . \
  --set database.enabled=true \
  --set postgresql.enabled=true \
  --set redis.enabled=true
```

### Full Featured
```bash
helm install complete . \
  --set database.enabled=true \
  --set postgresql.enabled=true \
  --set functionsDemo.enabled=true \
  --set 'extraEnvVars[0].name=API_KEY' \
  --set 'extraEnvVars[0].value=secret123'
```

## Exercises

### Exercise 1: Conditionals
1. Enable database and verify secret is created
2. Add a new conditional template for monitoring
3. Create a conditional ingress

### Exercise 2: Loops
1. Add 5 environment variables using loops
2. Create a loop for multiple ports
3. Loop through a list of volumes

### Exercise 3: Functions
1. Find all template functions used
2. Add a new function (quote, trim, etc.)
3. Combine multiple functions

### Exercise 4: Helpers
1. Create a new helper for calculating replicas
2. Add a helper for generating SSL certificate names
3. Use helpers in multiple templates

### Exercise 5: Dependencies
1. Install with PostgreSQL
2. Install with Redis  
3. Install with both
4. Check dependency conditions

### Exercise 6: Hooks
1. Add a pre-upgrade hook
2. Create a post-upgrade hook
3. Add hook weights to control order

### Exercise 7: Testing
1. Run all tests
2. Add a new test for backend connectivity
3. Create a test that validates ConfigMap values

## Troubleshooting

### Hook Job Fails
```bash
kubectl get jobs
kubectl describe job <job-name>
kubectl logs job/<job-name>
```

### Dependency Issues
```bash
helm dependency update
helm dependency build
```

### Template Errors
```bash
helm lint .
helm template test . --debug
```

## Cleanup
```bash
helm uninstall advanced
helm uninstall fullstack
helm uninstall testapp
helm uninstall complete

# Clean up test files
rm test-values.yaml
```

## Key Takeaways

1. **Conditionals** control when resources are created
2. **Loops** enable dynamic configuration
3. **Functions** transform and manipulate values
4. **Helpers** create reusable template logic
5. **Dependencies** manage related charts
6. **Hooks** run jobs at specific lifecycle points
7. **Tests** validate deployments

## Next Steps
Move to **Lab 6** for a complete full-stack microservices application!
