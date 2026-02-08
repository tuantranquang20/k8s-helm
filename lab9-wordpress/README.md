# Lab 9: WordPress CMS with MySQL and Redis

## 📝 Overview
Deploy a complete, production-ready WordPress stack with:
- **WordPress** - Popular CMS platform
- **MySQL** - Relational database for content storage
- **Redis** - Object cache for performance
- **Persistent Storage** - For uploads and database
- **LoadBalancer** - External access

## Architecture

```
                    Internet
                       ↓
                [LoadBalancer]
                       ↓
┌──────────────────────────────────────┐
│          WordPress Pod(s)             │
│  ┌─────────────────────────────┐    │
│  │  Apache + PHP + WordPress    │    │
│  └─────────────────────────────┘    │
│         ↓              ↓              │
└─────────┼──────────────┼──────────────┘
          │              │
    ┌─────┴────┐    ┌────┴─────┐
    │  MySQL   │    │  Redis   │
    │ Database │    │  Cache   │
    └──────────┘    └──────────┘
         ↓               ↓
    [PersistentVolume]  (No persistence)
```

## Quick Start

### 1. Add Bitnami Repository
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

###  2. Install Dependencies
```bash
cd lab9-wordpress
helm dependency update
```

### 3. Deploy WordPress
```bash
# Install the stack
helm install myblog .

# Watch pods starting
kubectl get pods -w
```

### 4. Get WordPress URL
```bash
# Get the LoadBalancer IP
kubectl get service myblog-wordpress

# For Minikube
minikube service myblog-wordpress --url

# Or port-forward
kubectl port-forward service/myblog-wordpress 8080:80
```

### 5. Access WordPress
```bash
# Open browser to:
http://localhost:8080

# Login credentials:
# Username: admin
# Password: admin123
```

## Post-Installation Setup

### 1. Complete WordPress Setup
1. Open WordPress URL
2. Select language
3. Site is already configured!
4. Login with admin/admin123
5. Start creating content

### 2. Configure Redis Cache
```bash
# Get WordPress pod
WP_POD=$(kubectl get pods -l app.kubernetes.io/name=wordpress -o jsonpath='{.items[0].metadata.name}')

# Install WP-CLI
kubectl exec -it $WP_POD -- wp plugin install redis-cache --activate --allow-root

# Enable Redis
kubectl exec -it $WP_POD -- wp redis enable --allow-root

# Check status
kubectl exec -it $WP_POD -- wp redis status --allow-root
```

### 3. Install Additional Plugins
```bash
# SEO plugin
kubectl exec -it $WP_POD -- wp plugin install wordpress-seo --activate --allow-root

# Contact form
kubectl exec -it $WP_POD -- wp plugin install contact-form-7 --activate --allow-root

# Backup plugin
kubectl exec -it $WP_POD -- wp plugin install updraftplus --activate --allow-root
```

## Managing WordPress

### Using WP-CLI

```bash
# Get WordPress pod name
WP_POD=$(kubectl get pods -l app.kubernetes.io/name=wordpress -o jsonpath='{.items[0].metadata.name}')

# List installed plugins
kubectl exec -it $WP_POD -- wp plugin list --allow-root

# List themes
kubectl exec -it $WP_POD -- wp theme list --allow-root

# Create a new post
kubectl exec -it $WP_POD -- wp post create \
  --post_title='Hello Kubernetes' \
  --post_content='This post was created via WP-CLI!' \
  --post_status=publish \
  --allow-root

# List users
kubectl exec -it $WP_POD -- wp user list --allow-root

# Create new user
kubectl exec -it $WP_POD -- wp user create editor editor@example.com \
  --role=editor \
  --user_pass=editor123 \
  --allow-root
```

### Database Management

```bash
# Get MySQL pod
MYSQL_POD=$(kubectl get pods -l app.kubernetes.io/name=mysql -o jsonpath='{.items[0].metadata.name}')

# Connect to MySQL
kubectl exec -it $MYSQL_POD -- mysql -u wordpress -pwordpress-password wordpress

# Inside MySQL:
# SHOW TABLES;
# SELECT * FROM wp_posts LIMIT 5;
# SELECT * FROM wp_users;
# exit
```

### Backup WordPress

```bash
# Backup database
kubectl exec -it $MYSQL_POD -- mysqldump -u wordpress -pwordpress-password wordpress > wordpress-backup.sql

# Backup WordPress files
kubectl cp $WP_POD:/bitnami/wordpress ./wordpress-files-backup

# List backups
ls -lh wordpress-*
```

### Restore from Backup

```bash
# Restore database
kubectl exec -i $MYSQL_POD -- mysql -u wordpress -pwordpress-password wordpress < wordpress-backup.sql

# Restore files
kubectl cp ./wordpress-files-backup $WP_POD:/bitnami/wordpress
```

## Scaling WordPress

### Horizontal Scaling
```bash
# Scale to 3 replicas
helm upgrade myblog . --set wordpress.replicaCount=3

# Verify scaling
kubectl get pods -l app.kubernetes.io/name=wordpress
```

**Note**: For multi-replica WordPress, you need:
1. Shared storage (ReadWriteMany volume)
2. Session affinity or Redis sessions
3. Synchronized uploads directory

### Vertical Scaling
```bash
# Increase resources
helm upgrade myblog . \
  --set wordpress.resources.limits.memory=1Gi \
  --set wordpress.resources.limits.cpu=1000m
```

## Performance Optimization

### 1. Enable Redis Object Cache
Already configured in values.yaml!

### 2. Configure PHP Settings
```bash
# Edit values.yaml extraEnvVars:
wordpress:
  extraEnvVars:
    - name: PHP_MEMORY_LIMIT
      value: "512M"
    - name: PHP_MAX_EXECUTION_TIME
      value: "300"
    - name: PHP_MAX_UPLOAD_SIZE
      value: "128M"

# Apply changes
helm upgrade myblog .
```

### 3. Enable CDN
```bash
# Install W3 Total Cache plugin
kubectl exec -it $WP_POD -- wp plugin install w3-total-cache --activate --allow-root
```

## Monitoring WordPress

### Check Site Health
```bash
# WordPress site health
kubectl exec -it $WP_POD -- wp site health status --allow-root

# Check cache status
kubectl exec -it $WP_POD -- wp cache flush --allow-root
kubectl exec -it $WP_POD -- wp cache status --allow-root
```

### View Logs
```bash
# WordPress logs
kubectl logs -l app.kubernetes.io/name=wordpress --tail=100 -f

# MySQL logs
kubectl logs -l app.kubernetes.io/name=mysql --tail=100 -f

# Redis logs
kubectl logs -l app.kubernetes.io/name=redis --tail=100 -f
```

### Resource Usage
```bash
# Check pod resource usage
kubectl top pods

# Check persistent volume usage
kubectl get pvc
```

## Security

### 1. Change Default Passwords
```bash
# Update admin password
helm upgrade myblog . --set wordpress.wordpressPassword=NewSecurePassword123!

# Update MySQL passwords
helm upgrade myblog . \
  --set mysql.auth.rootPassword=NewMySQLRootPass \
  --set mysql.auth.password=NewWordPressDBPass
```

### 2. Install Security Plugins
```bash
# Wordfence Security
kubectl exec -it $WP_POD -- wp plugin install wordfence --activate --allow-root

# iThemes Security
kubectl exec -it $WP_POD -- wp plugin install better-wp-security --activate --allow-root
```

### 3. SSL/TLS Setup
```yaml
# Update values.yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: wordpress-tls
      hosts:
        - yourdomain.com
```

## Exercises

### Exercise 1: Create Content
1. Login to WordPress admin
2. Create a new post with images
3. Create a new page
4. Create a custom menu
5. Change theme

### Exercise 2: Plugin Management
```bash
# Install WooCommerce (e-commerce)
kubectl exec -it $WP_POD -- wp plugin install woocommerce --activate --allow-root

# Install Elementor (page builder)
kubectl exec -it $WP_POD -- wp plugin install elementor --activate --allow-root

# List all plugins
kubectl exec -it $WP_POD -- wp plugin list --allow-root
```

### Exercise 3: Performance Testing
```bash
# Install Apache Bench
# macOS: already included
# Linux: apt-get install apache2-utils

# Get WordPress URL
WP_URL=$(minikube service myblog-wordpress --url)

# Run load test
ab -n 100 -c 10 $WP_URL/

# Check performance
kubectl exec -it $WP_POD -- wp cache flush --allow-root
ab -n 100 -c 10 $WP_URL/  # Compare results
```

### Exercise 4: Database Queries
```bash
# Count posts
kubectl exec -it $MYSQL_POD -- mysql -u wordpress -pwordpress-password wordpress \
  -e "SELECT COUNT(*) FROM wp_posts WHERE post_type='post' AND post_status='publish';"

# List recent posts
kubectl exec -it $MYSQL_POD -- mysql -u wordpress -pwordpress-password wordpress \
  -e "SELECT post_title, post_date FROM wp_posts WHERE post_status='publish' ORDER BY post_date DESC LIMIT 5;"
```

## Production Configuration

Create `production-values.yaml`:
```yaml
wordpress:
  replicaCount: 3
  wordpressPassword: "CHANGE-ME-SECURE-PASSWORD"
  
  persistence:
    enabled: true
    storageClass: "fast-ssd"
    size: 50Gi
  
  resources:
    limits:
      cpu: 2000m
      memory: 2Gi
    requests:
      cpu: 1000m
      memory: 1Gi

mysql:
  auth:
    rootPassword: "CHANGE-ME-MYSQL-ROOT"
    password: "CHANGE-ME-WORDPRESS-DB"
  
  primary:
    persistence:
      enabled: true
      storageClass: "fast-ssd"
      size: 20Gi

redis:
  enabled: true
  master:
    persistence:
      enabled: true
      size: 2Gi

ingress:
  enabled: true
  hosts:
    - host: www.yoursite.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: yoursite-tls
      hosts:
        - www.yoursite.com
```

Deploy:
```bash
helm install prod-blog . -f production-values.yaml
```

## Troubleshooting

### WordPress Won't Start
```bash
# Check pod status
kubectl describe pod -l app.kubernetes.io/name=wordpress

# Check logs
kubectl logs -l app.kubernetes.io/name=wordpress

# Common issues:
# - Database not ready (wait for MySQL pod)
# - PVC pending (check storage class)
# - Wrong credentials (check values)
```

### Database Connection Failed
```bash
# Verify MySQL is running
kubectl get pods -l app.kubernetes.io/name=mysql

# Test connection
kubectl exec -it $WP_POD -- wp db check --allow-root

# Reset database connection
helm upgrade myblog . --set mysql.auth.password=wordpress-password
```

### Site is Slow
```bash
# Enable Redis cache
kubectl exec -it $WP_POD -- wp redis enable --allow-root

# Check cache status
kubectl exec -it $WP_POD -- wp redis status --allow-root

# Install caching plugin
kubectl exec -it $WP_POD -- wp plugin install w3-total-cache --activate --allow-root
```

## Cleanup
```bash
helm uninstall myblog

# Delete PVCs (if desired)
kubectl delete pvc -l app.kubernetes.io/instance=myblog
```

## Learning Objectives

After this lab, you should understand:
- ✅ CMS deployment on Kubernetes
- ✅ Persistent storage for stateful apps
- ✅ Database integration
- ✅ Caching layers (Redis)
- ✅ WordPress management with WP-CLI
- ✅ Backup and restore procedures
- ✅ Scaling web applications
- ✅ Production hardening

## Next Steps
- Set up automated backups
- Configure CDN
- Implement multi-site WordPress
- Add monitoring with Prometheus
- Set up CI/CD for theme development
- Configure high availability

🎉 **Congratulations!** You've deployed a production-ready WordPress site on Kubernetes!
