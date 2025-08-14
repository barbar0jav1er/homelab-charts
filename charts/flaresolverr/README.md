# FlareSolverr Helm Chart

A Helm chart for deploying FlareSolverr on Kubernetes - a proxy server to bypass Cloudflare and other anti-bot protection for *arr applications.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Type](https://img.shields.io/badge/type-application-informational.svg)
![AppVersion](https://img.shields.io/badge/app%20version-latest-informational.svg)

## ✨ Features

- 🛡️ **Cloudflare Bypass**: Automatically resolves Cloudflare challenges and anti-bot protection
- 🤖 **Anti-Bot Protection**: Handles captchas and browser verification challenges
- 🔗 **HTTP Proxy**: Acts as a proxy server for *arr application requests
- 🌐 **Multiple Providers**: Supports various captcha solving services (2captcha, anticaptcha)
- 📦 **Lightweight**: Minimal resource footprint when idle
- 🔧 **Flexible**: Configurable timeouts and logging levels

## 🚀 Quick Start

### Basic Installation
```bash
helm install flaresolverr ./flaresolverr
```

### Installation with Custom Configuration
```bash
helm install flaresolverr ./flaresolverr \
  --set env.LOG_LEVEL=debug \
  --set env.BROWSER_TIMEOUT=60000 \
  --set resources.limits.memory=2Gi
```

### Installation with Ingress (if needed)
```bash
helm install flaresolverr ./flaresolverr \
  --set ingress.enabled=true \
  --set ingress.host=flaresolverr.mydomain.com \
  --set ingress.className=nginx
```

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- At least 256Mi RAM available (1Gi recommended for heavy usage)
- CPU with decent single-thread performance

## ⚙️ Configuration

### Basic Configuration

```yaml
# Basic configuration for most use cases
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 100m
    memory: 256Mi

env:
  LOG_LEVEL: "info"
  BROWSER_TIMEOUT: "40000"  # 40 seconds
```

### Production Configuration Example

```yaml
# values-prod.yaml
replicaCount: 2  # For high availability

resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 200m
    memory: 512Mi

env:
  LOG_LEVEL: "warning"
  BROWSER_TIMEOUT: "60000"  # 60 seconds for slow sites
  CAPTCHA_SOLVER: "2captcha"  # Optional captcha solving
  CAPTCHA_SOLVER_KEY: "your-2captcha-api-key"

# Only expose via ingress if you need external access
ingress:
  enabled: false  # Keep internal for security

# Optional: Enable persistence for sessions (usually not needed)
persistence:
  tmp:
    enabled: false

# Security context
podSecurityContext:
  fsGroup: 1000
  runAsNonRoot: true

securityContext:
  runAsUser: 1000
  readOnlyRootFilesystem: false  # Browser needs to write temp files
```

## 🔧 Configuration Parameters

### Main Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/flaresolverr/flaresolverr` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Environment Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `env.LOG_LEVEL` | Logging level (debug, info, warning, error) | `info` |
| `env.BROWSER_TIMEOUT` | Browser timeout in milliseconds | `40000` |
| `env.TEST_URL` | Test URL to verify service | `https://www.google.com` |
| `env.PORT` | Service port | `8191` |
| `env.CAPTCHA_SOLVER` | Captcha solver (none, 2captcha, anticaptcha) | `none` |
| `env.CAPTCHA_SOLVER_KEY` | Captcha solver API key | `""` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8191` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.className` | Ingress class | `""` |
| `ingress.host` | Hostname | `flaresolverr.local` |
| `ingress.tls.enabled` | Enable TLS | `false` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `256Mi` |

## 🔗 Integration with *arr Applications

### Prowlarr Integration

1. **Deploy FlareSolverr first**:
```bash
helm install flaresolverr ./flaresolverr
```

2. **In Prowlarr Settings**:
   - Go to Settings > Indexers > FlareSolverr
   - Host: `flaresolverr-service` (or your service name)
   - Port: `8191`
   - Test the connection

3. **Configure Indexers**:
   - For indexers that need Cloudflare bypass
   - Select FlareSolverr in indexer settings

### Direct Integration with Sonarr/Radarr

If not using Prowlarr, configure directly in Sonarr/Radarr:

```yaml
# In *arr application settings
Indexers:
  - Name: "YourIndexer"
    FlareSolverr: "http://flaresolverr-service:8191"
```

### Complete Stack Deployment

```yaml
# Deploy FlareSolverr first
flaresolverr:
  resources:
    limits:
      memory: 1Gi

# Then deploy Prowlarr with FlareSolverr URL
prowlarr:
  flareSolverr:
    enabled: true
    url: "http://flaresolverr-service:8191"

# Other *arr apps get indexers from Prowlarr
sonarr: {}
radarr: {}
```

## 🔍 Usage and Testing

### Test FlareSolverr

```bash
# Port forward to test locally
kubectl port-forward service/flaresolverr 8191:8191

# Test basic functionality
curl -X POST http://localhost:8191/v1 \
  -H "Content-Type: application/json" \
  -d '{
    "cmd": "request.get",
    "url": "https://www.google.com"
  }'

# Test Cloudflare bypass (replace with actual Cloudflare-protected site)
curl -X POST http://localhost:8191/v1 \
  -H "Content-Type: application/json" \
  -d '{
    "cmd": "request.get", 
    "url": "https://example-cloudflare-site.com"
  }'
```

### Monitor FlareSolverr

```bash
# Check logs
kubectl logs deployment/flaresolverr -f

# Check resource usage
kubectl top pod -l app=flaresolverr
```

## 🔍 Troubleshooting

### Common Issues

#### **High Memory Usage**
FlareSolverr runs a headless Chrome browser, which can use significant memory:

```yaml
# Increase memory limits
resources:
  limits:
    memory: 2Gi
  requests:
    memory: 512Mi
```

#### **Timeout Errors**
Some sites take longer to load:

```yaml
env:
  BROWSER_TIMEOUT: "60000"  # Increase to 60 seconds
```

#### **Connection Refused**
Check service and pod status:

```bash
# Check if pod is running
kubectl get pods -l app=flaresolverr

# Check service
kubectl get svc flaresolverr

# Test internal connectivity
kubectl exec -it deployment/prowlarr -- curl http://flaresolverr:8191
```

#### **Captcha Challenges**
For sites with captcha challenges:

```yaml
env:
  CAPTCHA_SOLVER: "2captcha"
  CAPTCHA_SOLVER_KEY: "your-api-key"
```

### Performance Optimization

#### **Resource Sizing**

```yaml
# Light usage (few requests per hour)
resources:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

# Heavy usage (many concurrent requests)
resources:
  requests:
    cpu: 200m
    memory: 512Mi
  limits:
    cpu: 2000m
    memory: 2Gi
```

#### **Multiple Replicas**

```yaml
# For high availability and load distribution
replicaCount: 2

# Add anti-affinity to spread across nodes
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - flaresolverr
        topologyKey: kubernetes.io/hostname
```

## 📊 Monitoring

### Health Checks

FlareSolverr includes built-in health checks:

```bash
# Check health endpoint
curl http://flaresolverr:8191/

# Should return: "FlareSolverr is ready!"
```

### Metrics and Logging

Monitor through logs and resource usage:

```bash
# Watch logs for errors
kubectl logs deployment/flaresolverr -f | grep -i error

# Monitor resource usage
kubectl top pod -l app=flaresolverr --containers
```

## 🔐 Security Considerations

### Network Security

```yaml
# Recommended: Keep FlareSolverr internal
service:
  type: ClusterIP  # Don't expose externally

ingress:
  enabled: false   # Only enable if absolutely needed
```

### Pod Security

```yaml
# Security context (already configured in values.yaml)
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
    - ALL
```

### Network Policies

```yaml
# Example network policy to restrict access
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: flaresolverr-netpol
spec:
  podSelector:
    matchLabels:
      app: flaresolverr
  policyTypes:
  - Ingress
  ingress:
  # Only allow access from *arr applications
  - from:
    - podSelector:
        matchLabels:
          app: prowlarr
  - from:
    - podSelector:
        matchLabels:
          app: sonarr
  - from:
    - podSelector:
        matchLabels:
          app: radarr
```

## 🔗 Links

- [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)
- [FlareSolverr Docker](https://github.com/flaresolverr/flaresolverr-docker)
- [FlareSolverr Wiki](https://github.com/FlareSolverr/FlareSolverr/wiki)
- [API Documentation](https://github.com/FlareSolverr/FlareSolverr/wiki/API)