# Lab 10: Complete E-Commerce Platform

## 🛒 Overview
Deploy a production-ready e-commerce platform with full microservices architecture:
- **Frontend** - Storefront UI
- **Catalog Service** - Product management
- **Cart Service** - Shopping cart functionality
- **Order Service** - Order processing
- **Payment Service** - Payment processing (mock)
- **User Service** - Authentication & user profiles
- **PostgreSQL** - Primary database
- **Redis** - Session store & cache
- **RabbitMQ** - Message queue for async processing

## Architecture

```
                          Internet
                             ↓
                      [LoadBalancer]
                             ↓
                    ┌────────────────┐
                    │    Frontend    │
                    │   (Storefront) │
                    └────────┬───────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ↓                    ↓                    ↓
  ┌──────────┐        ┌──────────┐        ┌──────────┐
  │ Catalog  │        │   Cart   │        │  Order   │
  │ Service  │        │ Service  │        │ Service  │
  └────┬─────┘        └────┬─────┘        └────┬─────┘
       │                   │                    │
       ↓                   ↓                    ↓
  ┌──────────┐        ┌──────────┐        ┌──────────┐
  │   User   │        │ Payment  │        │   Rec.   │
  │ Service  │        │ Service  │        │  Engine  │
  └────┬─────┘        └────┬─────┘        └────┬─────┘
       │                   │                    │
       └───────────┬───────┴────────────────────┘
                   │
       ┌───────────┼────────────┬──────────────┐
       ↓           ↓            ↓              ↓
  ┌──────────┐ ┌────────┐ ┌─────────┐  ┌──────────┐
  │PostgreSQL│ │ Redis  │ │RabbitMQ │  │Monitoring│
  │ Database │ │ Cache  │ │  Queue  │  │ (Lab 8)  │
  └──────────┘ └────────┘ └─────────┘  └──────────┘
```

## Microservices Breakdown

### 1. Frontend (Storefront)
- **Purpose**: Customer-facing web interface
- **Tech**: React/Vue/Angular (nginx for serving)
- **Features**: Product browsing, cart, checkout
- **Port**: 80

### 2. Catalog Service
- **Purpose**: Product catalog management
- **Features**: 
  - Product CRUD operations
  - Search & filtering
  - Categories & tags
  - Inventory management
- **Port**: 8001
- **Database**: PostgreSQL

### 3. Cart Service
- **Purpose**: Shopping cart management
- **Features**:
  - Add/remove items
  - Update quantities
  - Cart persistence
  - Session management
- **Port**: 8002
- **Storage**: Redis (session), PostgreSQL (persistent)

### 4. Order Service
- **Purpose**: Order processing & management
- **Features**:
  - Order creation
  - Order history
  - Order status tracking
  - Invoice generation
- **Port**: 8003
- **Database**: PostgreSQL
- **Queue**: RabbitMQ (order processing)

### 5. Payment Service
- **Purpose**: Payment processing (mock gateway)
- **Features**:
  - Payment validation
  - Transaction processing
  - Payment methods (CC, PayPal)
  - Fraud detection (basic)
- **Port**: 8004
- **Database**: PostgreSQL

### 6. User Service
- **Purpose**: Authentication & user management
- **Features**:
  - User registration
  - Login/logout
  - Profile management
  - Address book
  - Order history
- **Port**: 8005
- **Database**: PostgreSQL
- **Cache**: Redis (sessions)

### 7. Recommendation Engine (Optional)
- **Purpose**: Product recommendations
- **Features**:
  - Personalized recommendations
  - Trending products
  - Related items
  - Recently viewed
- **Port**: 8006

## Quick Start

### 1. Add Required Repositories
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### 2. Install Dependencies
```bash
cd lab10-ecommerce
helm dependency update
```

### 3. Deploy E-Commerce Platform
```bash
# Install all services
helm install myshop .

# Watch pods starting (this will take a few minutes)
kubectl get pods -w
```

### 4. Get Frontend URL
```bash
# Get LoadBalancer IP/URL
kubectl get service myshop-ecommerce-platform-frontend

# For Minikube
minikube service myshop-ecommerce-platform-frontend --url

# Or port-forward
kubectl port-forward service/myshop-ecommerce-platform-frontend 8080:80
```

### 5. Access the Store
```
http://localhost:8080
```

## Service Communication Flow

### Customer Places Order:
```
1. Customer browses products
   Frontend → Catalog Service → PostgreSQL

2. Customer adds to cart
   Frontend → Cart Service → Redis (session)
                          → PostgreSQL (persist)

3. Customer checks out
   Frontend → User Service (verify user)
            → Cart Service (get cart items)
            → Order Service (create order)
            → RabbitMQ (queue order processing)

4. Process payment
   Order Worker (consumes RabbitMQ)
   → Payment Service (process payment)
   → Order Service (update order status)
   → Email notification (if configured)

5. Confirm order
   Frontend → Order Service (fetch order details)
```

## Managing the Platform

### View All Services
```bash
# List all pods
kubectl get pods -l app.kubernetes.io/instance=myshop

# List all services
kubectl get services -l app.kubernetes.io/instance=myshop

# Check service endpoints
kubectl get endpoints
```

### Access Individual Services
```bash
# Catalog Service
kubectl port-forward service/myshop-ecommerce-platform-catalog 8001:8001

# Cart Service
kubectl port-forward service/myshop-ecommerce-platform-cart 8002:8002

# Order Service
kubectl port-forward service/myshop-ecommerce-platform-order 8003:8003

# Payment Service
kubectl port-forward service/myshop-ecommerce-platform-payment 8004:8004

# User Service
kubectl port-forward service/myshop-ecommerce-platform-user 8005:8005
```

### Database Management
```bash
# Get PostgreSQL pod
PG_POD=$(kubectl get pods -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}')

# Connect to database
kubectl exec -it $PG_POD -- psql -U ecommerce -d ecommerce

# Inside psql:
# \dt                                (list tables)
# SELECT * FROM products LIMIT 10;   (view products)
# SELECT * FROM users;                (view users)
# SELECT * FROM orders;               (view orders)
# \q                                  (quit)
```

### Redis Cache Management
```bash
# Get Redis pod
REDIS_POD=$(kubectl get pods -l app.kubernetes.io/name=redis -o jsonpath='{.items[0].metadata.name}')

# Connect to Redis
kubectl exec -it $REDIS_POD -- redis-cli

# Inside Redis CLI:
# KEYS *           (view all keys)
# GET cart:user:1  (get cart for user 1)
# KEYS session:*   (view all sessions)
# quit
```

### RabbitMQ Queue Management
```bash
# Get RabbitMQ pod
RABBIT_POD=$(kubectl get pods -l app.kubernetes.io/name=rabbitmq -o jsonpath='{.items[0].metadata.name}')

# Access RabbitMQ Management UI
kubectl port-forward service/myshop-rabbitmq 15672:15672

# Access at: http://localhost:15672
# Username: admin
# Password: admin123

# View queues, check messages, monitor throughput
```

## Scaling the Platform

### Scale Individual Services
```bash
# Scale frontend for high traffic
kubectl scale deployment myshop-ecommerce-platform-frontend --replicas=5

# Scale catalog service
kubectl scale deployment myshop-ecommerce-platform-catalog --replicas=4

# Scale order service for Black Friday
kubectl scale deployment myshop-ecommerce-platform-order --replicas=10

# Scale payment service
kubectl scale deployment myshop-ecommerce-platform-payment --replicas=3
```

### Auto-scaling Configuration
```yaml
# Create HPA for frontend
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myshop-ecommerce-platform-frontend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

Apply:
```bash
kubectl apply -f frontend-hpa.yaml
```

## Monitoring with Prometheus (Lab 8 Integration)

### Add ServiceMonitors
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ecommerce-services
  labels:
    release: monitoring
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: ecommerce-platform
  endpoints:
  - port: http
    interval: 30s
    path: /metrics
```

### Create Dashboard
```bash
# Access Grafana (from Lab 8)
kubectl port-forward service/monitoring-kube-prometheus-stack-grafana 3000:80

# Create E-Commerce Dashboard with:
# - Order rate
# - Cart conversion rate
# - Payment success rate
# - API response times
# - Error rates per service
```

## Sample Data & Testing

### Populate Database with Sample Products
```bash
# Run seed script (create this as a Job)
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: seed-products
spec:
  template:
    spec:
      containers:
      - name: seed
        image: postgres:14
        command:
        - sh
        - -c
        - |
          psql postgresql://ecommerce:ecommerce-password@myshop-postgresql:5432/ecommerce <<SQL
          CREATE TABLE IF NOT EXISTS products (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255),
            price DECIMAL(10,2),
            description TEXT,
            stock INTEGER
          );
          
          INSERT INTO products (name, price, description, stock) VALUES
          ('Laptop', 999.99, 'High-performance laptop', 50),
          ('Mouse', 29.99, 'Wireless mouse', 200),
          ('Keyboard', 79.99, 'Mechanical keyboard', 150),
          ('Monitor', 299.99, '27-inch 4K monitor', 75),
          ('Headphones', 149.99, 'Noise-cancelling headphones', 100);
          SQL
      restartPolicy: Never
EOF

# Check job status
kubectl get jobs
kubectl logs job/seed-products
```

### Test API Endpoints
```bash
# Test Catalog Service
curl http://localhost:8001/api/products

# Test Cart Service - Add item
curl -X POST http://localhost:8002/api/cart \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 2}'

# Test Order Service - Get orders
curl http://localhost:8003/api/orders

# Test Payment Service - Process payment
curl -X POST http://localhost:8004/api/payments \
  -H "Content-Type: application/json" \
  -d '{"amount": 100.00, "method": "credit_card"}'

# Test User Service - Register
curl -X POST http://localhost:8005/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'
```

## Load Testing

### Using Apache Bench
```bash
# Test frontend
ab -n 1000 -c 50 http://localhost:8080/

# Test catalog API
ab -n 1000 -c 50 http://localhost:8001/api/products

# Test cart API
ab -n 500 -c 25 -p cart-data.json -T application/json http://localhost:8002/api/cart
```

### Using K6
```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 50,
  duration: '2m',
};

export default function () {
  // Browse products
  let products = http.get('http://localhost:8001/api/products');
  check(products, { 'products loaded': (r) => r.status === 200 });
  
  // Add to cart
  let cart = http.post('http://localhost:8002/api/cart', 
    JSON.stringify({ product_id: 1, quantity: 1 }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  check(cart, { 'added to cart': (r) => r.status === 200 });
  
  sleep(1);
}
```

Run:
```bash
k6 run load-test.js
```

## Exercises

### Exercise 1: Complete Purchase Flow
1. Browse catalog
2. Add 3 items to cart
3. Update quantities
4. Proceed to checkout
5. Enter payment details
6. Confirm order
7. View order history

### Exercise 2: Monitor Services
```bash
# Deploy monitoring (Lab 8)
# Add ServiceMonitors for e-commerce services
# Create custom dashboard
# Set up alerts for:
# - High error rates
# - Slow responses
# - Failed payments
```

### Exercise 3: Simulate Black Friday
```bash
# Scale all services
kubectl scale deployment myshop-ecommerce-platform-frontend --replicas=10
kubectl scale deployment myshop-ecommerce-platform-catalog --replicas=5
kubectl scale deployment myshop-ecommerce-platform-cart --replicas=5
kubectl scale deployment myshop-ecommerce-platform-order --replicas=8
kubectl scale deployment myshop-ecommerce-platform-payment --replicas=6

# Run load test
ab -n 10000 -c 100 http://localhost:8080/

# Monitor with Grafana
# Check RabbitMQ queue depth
# Monitor database connections
```

### Exercise 4: Database Backup & Restore
```bash
# Backup database
kubectl exec -it $PG_POD -- pg_dump -U ecommerce ecommerce > ecommerce-backup.sql

# Simulate data loss
kubectl exec -it $PG_POD -- psql -U ecommerce -d ecommerce -c "DROP TABLE products;"

# Restore
kubectl exec -i $PG_POD -- psql -U ecommerce ecommerce < ecommerce-backup.sql
```

## Production Configuration

Create `production-values.yaml`:
```yaml
frontend:
  replicaCount: 5
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi

catalog:
  replicaCount: 4
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi

cart:
  replicaCount: 4

order:
  replicaCount: 6

payment:
  replicaCount: 4

user:
  replicaCount: 3

recommendation:
  enabled: true
  replicaCount: 2

postgresql:
  primary:
    persistence:
      enabled: true
      size: 100Gi
    resources:
      limits:
        cpu: 2000m
        memory: 4Gi

redis:
  master:
    persistence:
      enabled: true
      size: 20Gi
    resources:
      limits:
        cpu: 1000m
        memory: 2Gi

rabbitmq:
  persistence:
    enabled: true
    size: 50Gi
  resources:
    limits:
      cpu: 2000m
      memory: 2Gi

ingress:
  enabled: true
  hosts:
    - host: shop.yourcompany.com
      paths:
        - path: /
          service: frontend
```

Deploy:
```bash
helm install prod-shop . -f production-values.yaml
```

## Troubleshooting

### Service Can't Connect to Database
```bash
# Check PostgreSQL is running
kubectl get pods -l app.kubernetes.io/name=postgresql

# Test connection
kubectl exec -it myshop-ecommerce-platform-catalog-xxx -- nc -zv myshop-postgresql 5432

# Check credentials
echo "postgresql://ecommerce:ecommerce-password@myshop-postgresql:5432/ecommerce"
```

### Orders Not Processing
```bash
# Check RabbitMQ
kubectl get pods -l app.kubernetes.io/name=rabbitmq

#Check queue depth
kubectl port-forward service/myshop-rabbitmq 15672:15672
# Access http://localhost:15672

# Check worker logs
kubectl logs -l app.kubernetes.io/component=order -f
```

### High Latency
```bash
# Check resource usage
kubectl top pods

# Check if services need scaling
kubectl get hpa

# Check database connections
kubectl exec -it $PG_POD -- psql -U ecommerce -d ecommerce -c "SELECT count(*) FROM pg_stat_activity;"
```

## Cleanup
```bash
helm uninstall myshop

# Delete PVCs
kubectl delete pvc -l app.kubernetes.io/instance=myshop
```

## Learning Objectives

After this lab, you should understand:
- ✅ Microservices architecture design
- ✅ Service mesh patterns
- ✅ Message queues for async processing
- ✅ Session management with Redis
- ✅ Multi-service deployments
- ✅ API gateway patterns
- ✅ Database per service pattern
- ✅ Event-driven architecture
- ✅ Distributed transactions

## Next Steps
- Add API Gateway (Kong, Ambassador)
- Implement service mesh (Istio, Linkerd)
- Add distributed tracing (Jaeger)
- Implement CI/CD pipeline
- Add authentication (OAuth2, JWT)
- Implement rate limiting
- Add search (Elasticsearch)
- Implement caching strategies

🎉 **Congratulations!** You've deployed a complete e-commerce platform on Kubernetes!
