# Lab 9: WordPress CMS - WITHOUT Helm

## 📝 Overview
Complete WordPress deployment with MySQL database using raw Kubernetes YAML.

**No Helm, just pain!** ☠️

## 📁 Files
```
lab9-wordpress-without-helm/
├── 00-namespace.yaml      # Namespace
├── 01-mysql.yaml          # MySQL + Secret + PVC
├── 02-wordpress.yaml      # WordPress + PVC
└── README.md
```

**Total: 3 files, ~200 lines**

Compare to Helm: 1 command with Bitnami chart

## 🚀 Quick Deploy

### Step 1: Deploy MySQL
```bash
cd lab9-wordpress-without-helm

kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-mysql.yaml

# Wait for MySQL to be ready
kubectl wait --for=condition=ready pod -l component=mysql -n wordpress --timeout=120s
```

### Step 2: Deploy WordPress
```bash
kubectl apply -f 02-wordpress.yaml

# Wait for WordPress
kubectl wait --for=condition=ready pod -l component=wordpress -n wordpress --timeout=120s
```

### Step 3: Access WordPress
```bash
# Get service URL
kubectl get service wordpress -n wordpress

# For Minikube
minikube service wordpress -n wordpress

# Or port-forward
kubectl port-forward -n wordpress service/wordpress 8080:80
```

Visit: **http://localhost:8080**

## 🔑 Hardcoded Credentials (Security Nightmare!)

MySQL password appears in **3 places**:

1. **01-mysql.yaml** - Secret (base64):
   ```yaml
   data:
     mysql-root-password: d29yZHByZXNz  # "wordpress"
     mysql-password: d29yZHByZXNz       # "wordpress"
   ```

2. **01-mysql.yaml** - Environment variable:
   ```yaml
   env:
     - name: MYSQL_PASSWORD
       valueFrom:
         secretKeyRef:
           name: mysql-secret
           key: mysql-password
   ```

3. **02-wordpress.yaml** - WordPress config:
   ```yaml
   env:
     - name: WORDPRESS_DB_PASSWORD
       valueFrom:
         secretKeyRef:
           name: mysql-secret  # Must match secret name!
           key: mysql-password  # Must match secret key!
   ```

**Change password?** Edit in 3 places + re-encode base64!

**With Helm:**
```yaml
# values.yaml
mysql:
  auth:
    password: newpassword
```

Done! ✅

## 💾 Persistent Storage

### Manual PVC Configuration
```yaml
# Must create PVC for MySQL
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi

# And another for WordPress
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wordpress-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

**With Helm:**
```yaml
persistence:
  enabled: true
  size: 10Gi
```

Helm creates PVCs automatically!

## 🔧 Common Issues

### Issue 1: PVC Pending
```bash
kubectl get pvc -n wordpress
# NAME            STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS
# mysql-pvc       Pending                                      
# wordpress-pvc   Pending

# Solution: Configure default storage class
kubectl get storageclass
# If none, create one or use hostPath for testing
```

### Issue 2: WordPress Can't Connect to MySQL
```bash
# Check WordPress logs
kubectl logs -n wordpress -l component=wordpress

# Common errors:
# - Wrong service name (must be "mysql")
# - Wrong password
# - MySQL not ready yet
# - Wrong namespace

# Verify MySQL service
kubectl get service -n wordpress
# NAME    TYPE        CLUSTER-IP      PORT(S)
# mysql   ClusterIP   10.96.123.456   3306/TCP  ← Must exist!
```

### Issue 3: Change MySQL Password
```bash
# The nightmare begins...

# 1. Base64 encode new password
echo -n "newpassword" | base64
# bmV3cGFzc3dvcmQ=

# 2. Edit secret in 01-mysql.yaml
vim 01-mysql.yaml
# Update mysql-password: bmV3cGFzc3dvcmQ=

# 3. Reapply secret
kubectl apply -f 01-mysql.yaml

# 4. Restart MySQL to use new password
kubectl rollout restart deployment/mysql -n wordpress

# 5. Restart WordPress to reconnect
kubectl rollout restart deployment/wordpress -n wordpress

# 6. Pray it works 🙏
```

**With Helm:**
```bash
helm upgrade myblog . --set mysql.auth.password=newpassword
# Done! Helm handles the rest
```

## 📊 Comparison Table

| Task | Helm | Raw YAML |
|------|------|----------|
| **Deploy** | `helm install myblog bitnami/wordpress` | Apply 3 files in order |
| **Configure Password** | `--set mysql.auth.password=xxx` | Edit 01-mysql.yaml (base64 encode!) |
| **Enable Persistence** | `--set persistence.enabled=true` | Manually create 2 PVCs |
| **Scale WordPress** | `--set replicaCount=3` | Edit 02-wordpress.yaml |
| **Upgrade** | `helm upgrade myblog .` | Edit files, kubectl apply |
| **Rollback** | `helm rollback myblog` | Manually restore from backup |
| **Add Plugin** | `--set wordpressPlugins=plugin-name` | SSH into pod, install manually |

## 🎯 What's Missing (Helm Has It!)

### 1. **No Plugin Management**
```bash
# With Helm:
--set wordpressPlugins="akismet,jetpack"

# Without Helm:
kubectl exec -it <wordpress-pod> -- wp plugin install akismet
# Repeat for each pod if replicas > 1
# Lost on pod restart unless using persistence
```

### 2. **No Redis Cache**
```bash
# With Helm (Lab 9):
redis:
  enabled: true

# Without Helm:
# Must deploy Redis manually
# Configure WordPress to use Redis manually
# Add PHP Redis extension manually
# Update wp-config.php manually
```

### 3. **No Automatic TLS**
```bash
# With Helm:
ingress:
  enabled: true
  tls:
    - secretName: wordpress-tls

# Without Helm:
# Create certificate manually
# Create Ingress manifest manually
# Configure TLS manually
```

### 4. **No Backup Configuration**
```bash
# With Helm + Bitnami:
# Built-in backup scripts
# Schedule automated backups

# Without Helm:
# Write your own backup scripts
# Create CronJobs manually
# Test restores manually
```

## 🧪 Testing WordPress

### Create Test Content
```bash
# Get WordPress pod
WP_POD=$(kubectl get pods -n wordpress -l component=wordpress -o jsonpath='{.items[0].metadata.name}')

# Access WP-CLI (if available in image)
kubectl exec -n wordpress -it $WP_POD -- wp --version

# Create test post
kubectl exec -n wordpress -it $WP_POD -- wp post create \
  --post_title="Test Post" \
  --post_content="This is a test" \
  --post_status=publish
```

### Backup Database
```bash
# Get MySQL pod
MYSQL_POD=$(kubectl get pods -n wordpress -l component=mysql -o jsonpath='{.items[0].metadata.name}')

# Backup database
kubectl exec -n wordpress -it $MYSQL_POD -- \
  mysqldump -u wordpress -pwordpress wordpress > wordpress-backup.sql

# Restore (if needed)
kubectl exec -n wordpress -i $MYSQL_POD -- \
  mysql -u wordpress -pwordpress wordpress < wordpress-backup.sql
```

## 🧹 Cleanup

```bash
# Delete namespace (includes PVCs!)
kubectl delete namespace wordpress

# Or delete individually
kubectl delete -f 02-wordpress.yaml
kubectl delete -f 01-mysql.yaml
kubectl delete -f 00-namespace.yaml
```

## 💡 Key Takeaways

### Why Raw YAML is Painful:

1. **Manual PVC Creation**: Can't use `persistence.enabled=true`
2. **Base64 Encoding**: Must encode secrets manually
3. **No Plugin Management**: Manual installation per pod
4. **No Auto-Scaling**: Edit YAML, reapply
5. **No Backup Tools**: Write your own scripts
6. **Hard to Customize**: No simple --set flags

### Why Helm Shines Here:

1. **Bitnami Chart**: Production-ready WordPress
2. **Dependency Management**: MySQL included
3. **One-Command Deploy**: `helm install`
4. **Easy Customization**: `--set` flags
5. **Built-in Backups**: Available in chart
6. **Plugin Management**: Part of values.yaml

## 🎓 Conclusion

Even a "simple" WordPress deployment shows Helm's value:
- **3 YAML files** vs **1 helm command**
- **Manual secret encoding** vs **plain values**
- **No plugin management** vs **built-in support**
- **Manual backups** vs **automated solutions**

**WordPress without Helm is manageable but inefficient.** For production, use Helm! 🚀

---

**Next Challenge**: Try Lab 8 (Monitoring Stack) without Helm for the ultimate pain! 😱
