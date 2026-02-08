# Lab 6: Full-Stack App - WITHOUT Helm

## 📦 Overview
Full-stack application with frontend, backend, and PostgreSQL database deployed using raw Kubernetes YAML.

## 📁 Files
```
lab6-handons-without-helm/
├── 00-namespace.yaml      # Namespace
├── 01-postgresql.yaml     # PostgreSQL database
├── 02-frontend.yaml       # Frontend + Secret
├── 03-backend.yaml        # Backend API
└── README.md
```

## 🚀 Quick Deploy
```bash
cd lab6-handons-without-helm

# Deploy in order
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-postgresql.yaml
kubectl wait --for=condition=ready pod -l component=database -n fullstack-app --timeout=60s
kubectl apply -f 02-frontend.yaml
kubectl apply -f 03-backend.yaml

# Access frontend
kubectl port-forward -n fullstack-app service/frontend 8080:80
```

## 🔑 Credentials
Database password appears in **3 places**:
- `01-postgresql.yaml` - POSTGRES_PASSWORD env var
- `02-frontend.yaml` - Secret (base64 encoded)
- `03-backend.yaml` - DATABASE_URL (plaintext!)

**With Helm**: 1 place in values.yaml

## 🆚 Comparison

| Task | Helm | Raw YAML |
|------|------|----------|
| Deploy | 1 command | 5 commands |
| Change password | Edit 1 line | Edit 3 files |
| Add env var | values.yaml | Edit deployment YAML |
| Scale backend | --set flag | Edit + reapply |

## 🧹 Cleanup
```bash
kubectl delete namespace fullstack-app
```

**Takeaway**: Even a simple 3-tier app shows Helm's value!
