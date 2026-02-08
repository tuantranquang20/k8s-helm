# Lab 1: Basic Kubernetes Deployment

## Objective
Learn to create and manage Pods, Deployments, and basic kubectl commands.

## Prerequisites
- Kubernetes cluster running (minikube, Docker Desktop, or kind)
- kubectl installed and configured

## Exercises

### Exercise 1: Create a Simple Pod
```bash
kubectl apply -f nginx-pod.yaml
kubectl get pods
kubectl describe pod nginx-pod
kubectl logs nginx-pod
kubectl exec -it nginx-pod -- /bin/bash
```

### Exercise 2: Create a Deployment
```bash
kubectl apply -f nginx-deployment.yaml
kubectl get deployments
kubectl get pods
kubectl get replicasets
```

### Exercise 3: Scale the Deployment
```bash
# Scale to 5 replicas
kubectl scale deployment nginx-deployment --replicas=5
kubectl get pods

# Scale back to 3
kubectl scale deployment nginx-deployment --replicas=3
```

### Exercise 4: Update the Deployment
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

### Exercise 5: Cleanup
```bash
kubectl delete -f nginx-pod.yaml
kubectl delete -f nginx-deployment.yaml
```

## Checkpoints
- [ ] Successfully created and viewed a Pod
- [ ] Created a Deployment with multiple replicas
- [ ] Scaled a Deployment up and down
- [ ] Updated a Deployment image
- [ ] Rolled back a Deployment
- [ ] Cleaned up all resources

## Next Steps
Once you complete this lab, move on to **Lab 2: Services and Networking**.
