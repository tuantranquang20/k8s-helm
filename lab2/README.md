# Lab 2: Services and Networking

## Objective
Understand how Services provide networking and load balancing for Pods.

## Prerequisites
- Completed Lab 1
- Kubernetes cluster running

## Exercises

### Exercise 1: Create a Deployment
```bash
kubectl apply -f web-deployment.yaml
kubectl get pods -l app=web
```

### Exercise 2: Create a ClusterIP Service
```bash
kubectl apply -f web-service-clusterip.yaml
kubectl get services
kubectl describe service web-service

# Test from within the cluster
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service
```

### Exercise 3: Create a NodePort Service
```bash
kubectl apply -f web-service-nodeport.yaml
kubectl get service web-nodeport

# For Minikube
minikube service web-nodeport --url

# Or use port-forward
kubectl port-forward service/web-nodeport 8080:80
# Then access: http://localhost:8080
```

### Exercise 4: Create a LoadBalancer Service
```bash
kubectl apply -f web-service-lb.yaml
kubectl get service web-loadbalancer

# For Minikube, run in separate terminal
minikube tunnel
```

### Exercise 5: Test Load Balancing
```bash
# Make multiple requests to see different Pods responding
for i in {1..10}; do
  kubectl run test-$i --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service
done
```

### Exercise 6: Cleanup
```bash
kubectl delete -f web-deployment.yaml
kubectl delete -f web-service-clusterip.yaml
kubectl delete -f web-service-nodeport.yaml
kubectl delete -f web-service-lb.yaml
```

## Checkpoints
- [ ] Created ClusterIP service and accessed it internally
- [ ] Created NodePort service and accessed it from outside
- [ ] Created LoadBalancer service (if supported)
- [ ] Understood the difference between service types
- [ ] Observed load balancing across multiple Pods
- [ ] Cleaned up all resources

## Next Steps
Once you complete this lab, move on to **Lab 3: Introduction to Helm**.
