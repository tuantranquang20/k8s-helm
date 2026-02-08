# Lab 7: Voting App Microservices

## 🗳️ Overview
Deploy a complete microservices voting application with:
- **Vote Service** - Frontend where users cast votes (Python/Flask)
- **Result Service** - Frontend displaying real-time results (Node.js)
- **Worker Service** - Background worker processing votes (Java)
- **Redis** - Message queue for incoming votes
- **PostgreSQL** - Database storing vote results

## Architecture

```
┌─────────┐         ┌─────────┐
│  Vote   │         │ Result  │
│ Service │         │ Service │
│ (Port   │         │ (Port   │
│   80)   │         │   80)   │
└────┬────┘         └────┬────┘
     │                   │
     │  Store votes      │  Read results
     ↓                   ↓
┌─────────┐         ┌──────────────┐
│  Redis  │←───────→│  Worker      │
│  Queue  │  Process │  Service     │
└─────────┘   votes  └──────┬───────┘
                            │
                            │ Store results
                            ↓
                      ┌─────────────┐
                      │ PostgreSQL  │
                      │  Database   │
                      └─────────────┘
```

## What's Included

### Services:
- `vote-deployment.yaml` - Vote frontend (2 replicas)
- `result-deployment.yaml` - Result frontend (1 replica)
- `worker-deployment.yaml` - Vote processor (1 replica)

### Dependencies:
- Redis (via Bitnami chart)
- PostgreSQL (via Bitnami chart)

## Quick Start

### 1. Install Dependencies
```bash
cd lab7-voting-app
helm dependency update
```

### 2. Deploy the Application
```bash
# Install the complete voting app
helm install voteapp .

# Watch pods coming up
kubectl get pods -w
```

### 3. Access the Applications
```bash
# Get the Vote service URL
kubectl get service voteapp-voting-app-vote

# Get the Result service URL
kubectl get service voteapp-voting-app-result

# For Minikube
minikube service voteapp-voting-app-vote
minikube service voteapp-voting-app-result

#Or use port-forward
kubectl port-forward service/voteapp-voting-app-vote 5000:80
kubectl port-forward service/voteapp-voting-app-result 5001:80
```

### 4. Use the Application
1. Open Vote UI: http://localhost:5000
   - Vote for "Cats" or "Dogs"
   
2. Open Result UI: http://localhost:5001
   - See real-time voting results

## Testing the Microservices

### Test Vote Service
```bash
# Check vote pods
kubectl get pods -l app.kubernetes.io/component=vote

# View vote logs
kubectl logs -l app.kubernetes.io/component=vote

# Test voting (if port-forwarded to 5000)
curl http://localhost:5000
```

### Test Result Service
```bash
# Check result pods
kubectl get pods -l app.kubernetes.io/component=result

# View result logs
kubectl logs -l app.kubernetes.io/component=result

# Access results
curl http://localhost:5001
```

### Test Worker Service
```bash
# Check worker pods
kubectl get pods -l app.kubernetes.io/component=worker

# View worker logs (should show vote processing)
kubectl logs -l app.kubernetes.io/component=worker -f
```

### Test Redis
```bash
# Get Redis pod
REDIS_POD=$(kubectl get pods -l app.kubernetes.io/name=redis -o jsonpath='{.items[0].metadata.name}')

# Connect to Redis
kubectl exec -it $REDIS_POD -- redis-cli

# Inside Redis CLI:
# KEYS *        (view stored votes)
# GET votes     (see vote data)
# quit
```

### Test PostgreSQL
```bash
# Get PostgreSQL pod
PG_POD=$(kubectl get pods -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}')

# Connect to database
kubectl exec -it $PG_POD -- psql -U postgres

# Inside psql:
# \dt                    (list tables)
# SELECT * FROM votes;   (view vote results)
# \q                     (quit)
```

## Scaling the Application

### Scale Vote Service
```bash
# Scale to handle more voters
kubectl scale deployment voteapp-voting-app-vote --replicas=5

# Verify scaling
kubectl get pods -l app.kubernetes.io/component=vote
```

### Scale Worker Service
```bash
# Add more workers to process votes faster
kubectl scale deployment voteapp-voting-app-worker --replicas=3

# Check workers
kubectl get pods -l app.kubernetes.io/component=worker
```

## Configuration Options

### Production Configuration
Create `production-values.yaml`:
```yaml
vote:
  replicaCount: 5
  service:
    type: LoadBalancer
  resources:
    limits:
      cpu: 500m
      memory: 512Mi

result:
  replicaCount: 3
  resources:
    limits:
      cpu: 500m
      memory: 512Mi

worker:
  replicaCount: 3
  resources:
    limits:
      cpu: 500m
      memory: 1Gi

postgresql:
  primary:
    persistence:
      enabled: true
      size: 10Gi

redis:
  master:
    persistence:
      enabled: true
      size: 1Gi
```

Deploy:
```bash
helm install voteapp-prod . -f production-values.yaml
```

## Exercises

### Exercise 1: Monitor Vote Flow
1. Open vote UI and cast a vote
2. Watch worker logs: `kubectl logs -f -l app.kubernetes.io/component=worker`
3. Refresh result UI to see the update
4. Check Redis for queued votes
5. Check PostgreSQL for stored results

### Exercise 2: Load Testing
```bash
# Install Apache Bench
# For macOS: already included
# For Linux: apt-get install apache2-utils

# Get vote service URL
VOTE_URL=$(minikube service voteapp-voting-app-vote --url)

# Send 100 requests with 10 concurrent users
ab -n 100 -c 10 $VOTE_URL/

# Watch pods handle the load
kubectl top pods
```

### Exercise 3: Simulate Failure
```bash
# Delete a vote pod
kubectl delete pod -l app.kubernetes.io/component=vote | head -1

# Vote service should still work (self-healing)
# Kubernetes will recreate the pod

# Watch pod recreation
kubectl get pods -w
```

### Exercise 4: Update Vote Image
```bash
# Update to a specific version
helm upgrade voteapp . --set vote.image.tag=v2

# Roll back if needed
helm rollback voteapp
```

## Troubleshooting

### Votes Not Appearing
```bash
# Check all pods are running
kubectl get pods

# Check worker is processing
kubectl logs -l app.kubernetes.io/component=worker

# Verify Redis connection
kubectl exec -it <vote-pod> -- env | grep REDIS

# Verify PostgreSQL connection
kubectl exec -it <worker-pod> -- env | grep POSTGRES
```

### Can't Access Services
```bash
# Check service types
kubectl get services

# If pending (LoadBalancer on local)
# Use NodePort or port-forward instead
kubectl port-forward service/voteapp-voting-app-vote 5000:80
```

### Database Issues
```bash
# Check PostgreSQL logs
kubectl logs -l app.kubernetes.io/name=postgresql

# Verify database exists
kubectl exec -it <pg-pod> -- psql -U postgres -c '\l'
```

## Monitoring

### View All Resources
```bash
kubectl get all -l app.kubernetes.io/instance=voteapp
```

### Check Resource Usage
```bash
kubectl top pods
kubectl top nodes
```

### View Events
```bash
kubectl get events --sort-by='.lastTimestamp' | grep voteapp
```

## Cleanup
```bash
helm uninstall voteapp
```

## Learning Objectives

After this lab, you should understand:
- ✅ Microservices architecture
- ✅ Service-to-service communication
- ✅ Message queues (Redis)
- ✅ Database integration
- ✅ Multi-tier application deployment
- ✅ Scaling microservices independently
- ✅ Helm dependency management

## Next Steps
- Add Ingress for external access
- Implement health checks
- Add monitoring with Prometheus (Lab 8)
- Implement horizontal pod autoscaling
- Add persistent storage for database

🎉 **Congratulations!** You've deployed a complete microservices application!
