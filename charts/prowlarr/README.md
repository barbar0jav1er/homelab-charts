# Prowlarr Helm Chart

A Helm chart for deploying Prowlarr on Kubernetes - an indexer manager/proxy built on the popular *arr .net/reactjs base stack to integrate with various PVR apps.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Type](https://img.shields.io/badge/type-application-informational.svg)
![AppVersion](https://img.shields.io/badge/app%20version-latest-informational.svg)

## ✨ Features

- 🔍 **Indexer Management**: Centralized management of indexers for all *arr applications
- 🔄 **Auto-Sync**: Automatically sync indexer configurations to Sonarr, Radarr, etc.
- 🌐 **Proxy Support**: Built-in proxy support for indexers
- 📦 **Persistent Storage**: Configurable persistent volume for configuration
- 🌐 **Ingress Support**: Optional ingress controller integration with TLS
- 🔧 **Flexible PVC**: Support for existing PVC or automatic PVC creation
- ⚙️ **Customizable**: Full control over resources, probes, and security contexts

## 🚀 Quick Start

### Basic Installation
```bash
helm install prowlarr ./prowlarr
```

### Installation with Ingress
```bash
helm install prowlarr ./prowlarr \
  --set ingress.enabled=true \
  --set ingress.host=prowlarr.mydomain.com \
  --set persistence.config.size=2Gi
```

### Using Existing PVC
```bash
helm install prowlarr ./prowlarr \
  --set persistence.config.existingClaim=prowlarr-config-pvc
```

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Configured StorageClass for persistent volumes
- Other *arr applications (Sonarr, Radarr, etc.) for full functionality
- **FlareSolverr** (recommended) for indexers behind Cloudflare protection

## ⚙️ Configuration

### Basic Configuration

```yaml
# Basic configuration
persistence:
  config:
    enabled: true
    size: 2Gi
    storageClass: "fast-ssd"

ingress:
  enabled: true
  host: "prowlarr.mydomain.com"

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### Production Configuration Example

```yaml
# values-prod.yaml
persistence:
  config:
    enabled: true
    size: 5Gi
    storageClass: "fast-ssd"
    # Or use existing PVC
    # existingClaim: "prowlarr-config"

ingress:
  enabled: true
  className: "nginx"
  host: "prowlarr.mydomain.com"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  tls:
    enabled: true
    secretName: "prowlarr-tls"

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 256Mi

# Security context
podSecurityContext:
  fsGroup: 1000

securityContext:
  runAsNonRoot: true
  runAsUser: 1000

# Timezone
env:
  TZ: "America/New_York"
  PUID: "1000" 
  PGID: "1000"
```

## 🔧 Configuration Parameters

### Main Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `linuxserver/prowlarr` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `env.PUID` | User ID | `1000` |
| `env.PGID` | Group ID | `1000` |
| `env.TZ` | Timezone | `Etc/UTC` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `9696` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.config.enabled` | Enable config volume | `true` |
| `persistence.config.size` | Config volume size | `1Gi` |
| `persistence.config.storageClass` | Storage class | `""` |
| `persistence.config.existingClaim` | Use existing PVC | `""` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.className` | Ingress class | `""` |
| `ingress.host` | Hostname | `prowlarr.local` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.tls.enabled` | Enable TLS | `false` |
| `ingress.tls.secretName` | TLS secret name | `prowlarr-tls` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |

## 🔍 Usage and Management

### Access Prowlarr WebUI

```bash
# Via port-forward (for testing)
kubectl port-forward deployment/prowlarr 9696:9696

# Access at: http://localhost:9696
```

### Initial Setup

1. **First Access**: Navigate to your Prowlarr WebUI
2. **Authentication**: Set up authentication (recommended for production)
3. **FlareSolverr**: Configure FlareSolverr for Cloudflare-protected indexers
   - Go to Settings > FlareSolverr
   - URL: `http://flaresolverr-service:8191`
   - Test the connection
4. **Indexers**: Add your indexers (both public and private)
   - For indexers behind Cloudflare, enable FlareSolverr
5. **Apps**: Configure connections to your *arr applications
6. **Sync**: Enable auto-sync to push indexers to connected apps

### Connecting *arr Applications

To connect Sonarr, Radarr, etc. to Prowlarr:

1. **In Prowlarr**: Go to Settings > Apps
2. **Add Application**: Choose the *arr app type
3. **Configuration**:
   ```
   Name: Sonarr
   Sync Level: Full Sync
   Prowlarr Server: http://prowlarr:9696  # Internal service
   Sonarr Server: http://sonarr:8989      # Internal service
   API Key: [sonarr-api-key]
   ```

### Common Configuration

```yaml
# Example App configuration in Prowlarr
Apps:
  - Name: "Sonarr"
    Type: "Sonarr"
    Server: "http://sonarr-service:8989"
    ApiKey: "your-sonarr-api-key"
    SyncLevel: "FullSync"
  
  - Name: "Radarr" 
    Type: "Radarr"
    Server: "http://radarr-service:7878"
    ApiKey: "your-radarr-api-key"
    SyncLevel: "FullSync"
```

## 🔍 Troubleshooting

### Check Logs
```bash
kubectl logs deployment/prowlarr -f
```

### Common Issues

#### **Cannot connect to *arr applications**
- Verify service names and ports
- Check API keys are correct
- Ensure applications are in same namespace or use FQDN
- Test connectivity:
```bash
kubectl exec deployment/prowlarr -- wget -qO- http://sonarr-service:8989/api/v3/system/status
```

#### **Indexers failing**
- Check indexer logs in Prowlarr UI
- Verify indexer credentials and URLs
- **For Cloudflare errors**: Enable FlareSolverr for the indexer
- Check if indexer requires VIP/premium access
- Monitor rate limiting

#### **FlareSolverr integration issues**
- Verify FlareSolverr is running: `kubectl get pods -l app=flaresolverr`
- Test FlareSolverr connectivity from Prowlarr pod:
```bash
kubectl exec deployment/prowlarr -- curl http://flaresolverr-service:8191
```
- Check FlareSolverr logs for errors:
```bash
kubectl logs deployment/flaresolverr -f
```

#### **Sync issues with applications**
- Check app configuration in Prowlarr
- Verify API keys haven't changed
- Force manual sync from Prowlarr UI
- Check application logs for errors

#### **Performance issues**
- Increase CPU/Memory resources
- Check storage performance
- Monitor indexer response times
- Reduce number of concurrent searches

## 🏗️ Architecture Patterns

### Centralized Indexer Management

```yaml
# 1. Deploy FlareSolverr first (for Cloudflare-protected indexers)
flaresolverr:
  resources:
    limits:
      memory: 1Gi
    requests:
      memory: 256Mi

# 2. Deploy Prowlarr with FlareSolverr integration
prowlarr:
  ingress:
    enabled: true
    host: "prowlarr.example.com"
  # Configure FlareSolverr URL in Prowlarr UI after deployment

# 3. Configure other apps to use minimal indexers
sonarr:
  # Sonarr will get indexers from Prowlarr
  indexers: []  # Empty, managed by Prowlarr

radarr:
  # Radarr will get indexers from Prowlarr  
  indexers: []  # Empty, managed by Prowlarr
```

### Resource Sizing Guidelines

```yaml
# Small setup (< 5 indexers)
resources:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi

# Medium setup (5-20 indexers)
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

# Large setup (> 20 indexers)
resources:
  requests:
    cpu: 200m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi
```

## 📊 Monitoring

### Health Checks
```bash
# Check if Prowlarr is responding
kubectl get pods -l app=prowlarr

# Test HTTP endpoint
kubectl exec deployment/prowlarr -- curl -f http://localhost:9696/ping
```

### Indexer Monitoring

Monitor indexer health through Prowlarr's UI:
- Response times
- Success rates  
- Error patterns
- Rate limiting issues

### Resource Usage
```bash
# Monitor resource usage
kubectl top pod -l app=prowlarr
```

## 🔗 Integration Examples

### Complete *arr Stack with FlareSolverr

```yaml
# Deploy order: FlareSolverr -> Prowlarr -> Sonarr/Radarr -> Bazarr

# 1. Deploy FlareSolverr first
flaresolverr:
  resources:
    limits:
      memory: 1Gi
    requests:
      memory: 256Mi

# 2. Deploy Prowlarr with FlareSolverr integration
prowlarr:
  persistence:
    config:
      existingClaim: "arr-configs"

# 3. Other *arr applications
sonarr:
  persistence:
    config:
      existingClaim: "arr-configs"
    tv:
      existingClaim: "media-tv"

radarr:
  persistence:
    config:
      existingClaim: "arr-configs"
    movies:
      existingClaim: "media-movies"

bazarr:
  persistence:
    config:
      existingClaim: "arr-configs"
    movies:
      existingClaim: "media-movies"
    tv:
      existingClaim: "media-tv"
```

### Network Policies

```yaml
# Allow Prowlarr to communicate with *arr apps
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: prowlarr-to-arr-apps
spec:
  podSelector:
    matchLabels:
      app: prowlarr
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app.kubernetes.io/instance: sonarr
  - to:
    - podSelector:
        matchLabels:
          app.kubernetes.io/instance: radarr
```

## 🔐 Security

### Recommended Security Settings

```yaml
# Enable authentication
auth:
  required: true
  method: "forms"  # or "basic"

# Use HTTPS
ingress:
  tls:
    enabled: true

# Run as non-root
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true

# Network policies
networkPolicy:
  enabled: true
```

## 🔗 Links

- [Prowlarr](https://github.com/Prowlarr/Prowlarr)
- [LinuxServer Prowlarr](https://hub.docker.com/r/linuxserver/prowlarr)  
- [Prowlarr Wiki](https://wiki.servarr.com/prowlarr)