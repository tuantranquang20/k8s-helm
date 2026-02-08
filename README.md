# Kubernetes and Helm Learning Guide

Welcome to your Kubernetes and Helm learning journey! This repository contains comprehensive theory and hands-on labs to help you master container orchestration.

## 📚 Contents

### 1. [Theory Guide](k8s-helm-theory.md)
Comprehensive overview covering:
- **Kubernetes Fundamentals**: Architecture, core concepts, and key resources
- **Helm Fundamentals**: Package management, charts, templates, and values
- **Best Practices**: Security, deployment, and operational guidelines

### 2. [Lab Guide](k8s-helm-labs.md)
5 progressive hands-on labs:
- **Lab 1**: Basic Kubernetes Deployment (Pods, Deployments, Scaling)
- **Lab 2**: Services and Networking (ClusterIP, NodePort, LoadBalancer)
- **Lab 3**: Introduction to Helm (Installing charts, custom values)
- **Lab 4**: Creating Custom Helm Charts (Building from scratch)
- **Lab 5**: Advanced Helm Features (Hooks, dependencies, testing)

## 🚀 Getting Started

### Prerequisites

1. **Install Tools**:
   ```bash
   # macOS - Install kubectl and helm
   brew install kubectl helm
   
   # Install Minikube for local cluster
   brew install minikube
   ```

2. **Start Your Cluster**:
   ```bash
   # Start Minikube
   minikube start --driver=docker
   
   # Verify installation
   kubectl cluster-info
   kubectl get nodes
   ```

3. **Verify Helm**:
   ```bash
   helm version
   ```

## 📖 How to Use This Guide

1. **Start with Theory**: Read through [k8s-helm-theory.md](k8s-helm-theory.md) to understand the concepts
2. **Practice with Labs**: Follow [k8s-helm-labs.md](k8s-helm-labs.md) step-by-step
3. **Complete All Checkpoints**: Each lab has checkpoints to verify your progress
4. **Experiment**: Try modifying the examples and creating your own variations

## 🎯 Learning Path

```
Theory Guide → Lab 1 → Lab 2 → Lab 3 → Lab 4 → Lab 5 → Advanced Challenges
```

## 📁 Lab Files Structure

As you work through the labs, you'll create files like:

```
k8s-helm/
├── README.md                      # This file
├── k8s-helm-theory.md            # Theory guide
├── k8s-helm-labs.md              # Lab guide
├── lab1/                          # Lab 1 files
│   ├── README.md
│   ├── nginx-pod.yaml
│   └── nginx-deployment.yaml
├── lab2/                          # Lab 2 files
│   ├── README.md
│   ├── web-deployment.yaml
│   └── web-service.yaml
├── lab3/                          # Lab 3 files
│   ├── README.md
│   └── custom-nginx-values.yaml
├── lab4/                          # Lab 4 files
│   ├── README.md
│   ├── INSTRUCTIONS.md
│   └── myapp-production.yaml
├── lab5/                          # Lab 5 files
│   ├── README.md
│   ├── INSTRUCTIONS.md
│   ├── extra-env-values.yaml
│   └── complete-values.yaml
│
├── lab4-handons/                  # 🎯 READY-TO-USE HELM CHART
│   ├── Chart.yaml
│   ├── README.md
│   ├── values.yaml
│   ├── production-values.yaml
│   └── templates/
│       ├── configmap.yaml         # Custom ConfigMap
│       └── deployment.yaml        # Modified with env vars
│
├── lab5-handons/                  # 🎯 READY-TO-USE ADVANCED CHART
│   ├── Chart.yaml                 # With dependencies
│   ├── README.md
│   ├── values.yaml
│   └── templates/
│       ├── secret.yaml            # Conditional Secret
│       ├── extra-configmap.yaml   # With loops
│       ├── functions-demo.yaml    # Template functions
│       ├── connection-config.yaml # Custom helpers
│       ├── hooks/                 # Pre/post install
│       └── tests/                 # Chart tests
│
└── lab6-handons/                  # 🎯 READY-TO-use FULL-STACK APP
    ├── Chart.yaml                 # With PostgreSQL & Redis  
    ├── README.md
    ├── values.yaml
    └── templates/
        ├── frontend-deployment.yaml
        ├── backend-deployment.yaml
        ├── service.yaml           # Multi-service
        ├── ingress.yaml           # Path-based routing
        └── secret.yaml            # Database credentials
```

## 🎯 Hands-On Labs (Ready to Use!)

Three complete, ready-to-use Helm charts have been created for you:

### **lab4-handons** - Custom Helm Charts
Complete chart demonstrating:
- Custom ConfigMaps
- Environment variables from ConfigMaps
- Multiple environment configurations (dev/prod)

**Quick start:**
```bash
cd lab4-handons
helm lint .
helm template myapp .
helm install myapp-dev .
```

### **lab5-handons** - Advanced Helm Features
Advanced chart with:
- Conditionals (if/else)
- Loops (range)
- Template functions
- Custom helpers
- Chart dependencies (PostgreSQL, Redis)
- Helm hooks
- Chart tests

**Quick start:**
```bash
cd lab5-handons
helm dependency update
helm template test . --set database.enabled=true
helm install advanced .
helm test advanced
```

### **lab6-handons** - Full-Stack Microservices (BONUS)
Production-ready full-stack application:
- Frontend service (nginx)
- Backend API service
- PostgreSQL database
- Redis cache
- Advanced Ingress routing
- Multi-component architecture

**Quick start:**
```bash
cd lab6-handons
helm dependency update
helm install fullstack . --set postgresql.enabled=true
kubectl get all
```

Each lab folder contains a comprehensive README with:
- What's included
- Quick start commands
- Configuration options
- Exercises
- Troubleshooting tips
## ⚡ Quick Commands Reference

### Kubernetes
```bash
kubectl get pods                    # List pods
kubectl get deployments            # List deployments
kubectl get services               # List services
kubectl describe pod <name>        # Detailed pod info
kubectl logs <pod-name>            # View logs
kubectl apply -f <file>.yaml       # Apply configuration
kubectl delete -f <file>.yaml      # Delete resources
```

### Helm
```bash
helm list                          # List releases
helm install <name> <chart>        # Install chart
helm upgrade <name> <chart>        # Upgrade release
helm uninstall <name>              # Uninstall release
helm template <name> <chart>       # Preview templates
helm lint <chart-path>             # Validate chart
```

## 🛠️ Troubleshooting

If you encounter issues:

1. **Check cluster status**: `kubectl cluster-info`
2. **View events**: `kubectl get events --sort-by='.lastTimestamp'`
3. **Check pod logs**: `kubectl logs <pod-name>`
4. **Helm debug**: `helm template <release> <chart> --debug`

See the full troubleshooting guide in [k8s-helm-labs.md](k8s-helm-labs.md).

## 🎓 After Completing the Labs

Once you've mastered the basics:

1. Deploy a real application (database + backend + frontend)
2. Explore advanced topics (StatefulSets, DaemonSets, CRDs)
3. Learn production tools (Prometheus, Grafana, Istio)
4. Contribute to open-source Helm charts

## 📚 Additional Resources

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Helm Official Docs](https://helm.sh/docs/)
- [Artifact Hub](https://artifacthub.io/) - Public Helm charts
- [Play with Kubernetes](https://labs.play-with-k8s.com/) - Interactive playground

## 📝 Notes

- All labs include cleanup steps to remove resources
- Use namespaces to organize your lab work
- Experiment freely - you can always recreate resources!

Happy Learning! 🚀
