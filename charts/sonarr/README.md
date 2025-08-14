# Sonarr Helm Chart

A Helm chart for deploying Sonarr on Kubernetes - a PVR for Usenet and BitTorrent users to monitor multiple RSS feeds for TV shows.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Type](https://img.shields.io/badge/type-application-informational.svg)
![AppVersion](https://img.shields.io/badge/app%20version-latest-informational.svg)

## ✨ Features

- 📺 **TV Show Management**: Automatically monitor, search, and download TV episodes
- 🔍 **Smart Search**: Integration with indexers and download clients
- 📦 **Persistent Storage**: Configurable persistent volumes for config, TV shows, and downloads
- 🌐 **Ingress Support**: Optional ingress controller integration with TLS
- 🔧 **Flexible PVC**: Support for existing PVCs or automatic PVC creation
- ⚙️ **Customizable**: Full control over resources, probes, and security contexts

## 🚀 Quick Start

### Basic Installation
```bash
helm install sonarr ./sonarr
```

### Installation with Storage
```bash
helm install sonarr ./sonarr \
  --set persistence.tv.enabled=true \
  --set persistence.tv.size=2Ti \
  --set persistence.downloads.enabled=true \
  --set persistence.downloads.size=500Gi \
  --set ingress.enabled=true \
  --set ingress.host=sonarr.mydomain.com
```

### Using Existing PVCs
```bash
helm install sonarr ./sonarr \
  --set persistence.config.existingClaim=sonarr-config \
  --set persistence.tv.enabled=true \
  --set persistence.tv.existingClaim=media-tv \
  --set persistence.downloads.enabled=true \
  --set persistence.downloads.existingClaim=downloads-shared
```

### Using Shared PVC with SubPaths
```bash
# Single shared PVC for all media and downloads
helm install sonarr ./sonarr \
  --set persistence.tv.enabled=true \
  --set persistence.tv.existingClaim=shared-media-pvc \
  --set persistence.tv.subPath=media/tv-shows \
  --set persistence.downloads.enabled=true \
  --set persistence.downloads.existingClaim=shared-media-pvc \
  --set persistence.downloads.subPath=downloads
```

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Configured StorageClass for persistent volumes
- Download client (qBittorrent, Transmission, etc.)
- Indexer access (Prowlarr recommended)

## ⚙️ Configuration

### Storage Configuration

Sonarr needs storage for configuration, TV shows library, and download monitoring:

#### Option 1: Separate PVCs
```yaml
persistence:
  config:
    enabled: true
    size: 5Gi
    storageClass: "fast-ssd"
  
  tv:
    enabled: true
    size: 2Ti
    storageClass: "bulk-storage"
    # Or use existing PVC
    existingClaim: "media-tv"
  
  downloads:
    enabled: true
    size: 500Gi
    storageClass: "fast-storage"
    # Or use existing PVC
    existingClaim: "downloads-shared"
```

#### Option 2: Shared PVC with SubPaths (Recommended)
```yaml
persistence:
  config:
    enabled: true
    size: 5Gi
    storageClass: "fast-ssd"    # Keep config separate for performance
  
  tv:
    enabled: true
    existingClaim: "shared-media-pvc"
    subPath: "media/tv-shows"   # Mount only TV shows folder
  
  downloads:
    enabled: true
    existingClaim: "shared-media-pvc"
    subPath: "downloads"        # Mount only downloads folder
```

This allows you to organize a single large PVC like:
```
shared-media-pvc/
├── media/
│   ├── tv-shows/           # Sonarr/Bazarr access
│   └── movies/             # Radarr/Bazarr access
├── downloads/              # All *arr + qBittorrent access
└── temp/
```

### Production Configuration Example

```yaml
# values-prod.yaml
persistence:
  config:
    enabled: true
    size: 10Gi
    storageClass: "fast-ssd"
  tv:
    enabled: true
    existingClaim: "media-tv-nfs"
  downloads:
    enabled: true
    existingClaim: "downloads-nfs"

ingress:
  enabled: true
  className: "nginx"
  host: "sonarr.mydomain.com"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
  tls:
    enabled: true
    secretName: "sonarr-tls"

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 512Mi

# Timezone configuration
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
| `image.repository` | Image repository | `linuxserver/sonarr` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `env.PUID` | User ID | `1000` |
| `env.PGID` | Group ID | `1000` |
| `env.TZ` | Timezone | `Etc/UTC` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8989` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.config.enabled` | Enable config volume | `true` |
| `persistence.config.size` | Config volume size | `1Gi` |
| `persistence.config.storageClass` | Storage class | `""` |
| `persistence.config.existingClaim` | Use existing PVC | `""` |
| `persistence.tv.enabled` | Enable TV volume | `false` |
| `persistence.tv.size` | TV volume size | `100Gi` |
| `persistence.tv.storageClass` | Storage class | `""` |
| `persistence.tv.existingClaim` | Use existing PVC | `""` |
| `persistence.tv.subPath` | Subpath within PVC | `""` |
| `persistence.downloads.enabled` | Enable downloads volume | `false` |
| `persistence.downloads.size` | Downloads volume size | `50Gi` |
| `persistence.downloads.storageClass` | Storage class | `nfs-media-direct` |
| `persistence.downloads.existingClaim` | Use existing PVC | `""` |
| `persistence.downloads.subPath` | Subpath within PVC | `""` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.className` | Ingress class | `""` |
| `ingress.host` | Hostname | `sonarr.local` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.tls.enabled` | Enable TLS | `false` |
| `ingress.tls.secretName` | TLS secret name | `sonarr-tls` |

## 🔍 Usage and Management

### Access Sonarr WebUI

```bash
# Via port-forward (for testing)
kubectl port-forward deployment/sonarr 8989:8989

# Access at: http://localhost:8989
```

### Initial Setup

1. **First Access**: Navigate to your Sonarr WebUI
2. **Media Management**: 
   - Set root folder to `/tv`
   - Configure file naming and quality profiles
3. **Download Client**: Configure your download client (qBittorrent, etc.)
   - Use Kubernetes service names for internal communication
4. **Indexers**: Add indexers or connect to Prowlarr
5. **Quality Profiles**: Set up quality profiles for different types of shows

### Integration with Download Clients

If using qBittorrent in the same cluster:
```yaml
# In Sonarr settings - Download Clients
Host: qbittorrent-service  # Kubernetes service name
Port: 8080
Username: admin
Password: [your-password]
Category: tv-sonarr
```

### Common Mount Paths

When configuring Sonarr, use these paths:

- **Config**: `/config` (always mounted)
- **TV Shows**: `/tv` (if TV volume enabled) 
- **Downloads**: `/downloads` (if downloads volume enabled)

## 🔍 Troubleshooting

### Check Logs
```bash
kubectl logs deployment/sonarr -f
```

### Common Issues

#### **Downloads not importing**
- Check file permissions (PUID/PGID should match across all containers)
- Verify download path matches between Sonarr and download client
- Check that both containers can access the downloads volume

#### **Shows not found**
- Verify indexer configuration
- Check API keys and connectivity
- Test indexer from Sonarr settings

#### **Permission errors**
```bash
# Check current permissions
kubectl exec deployment/sonarr -- ls -la /tv
kubectl exec deployment/sonarr -- ls -la /downloads

# Verify PUID/PGID in container
kubectl exec deployment/sonarr -- id
```

#### **Database locked errors**
- Usually indicates multiple instances or unclean shutdown
- Delete pod to restart cleanly:
```bash
kubectl delete pod -l app=sonarr
```

## 🏗️ Architecture Patterns

### Shared Storage Pattern

#### Option 1: Multiple Shared PVCs
Use shared PVCs across multiple *arr applications:

```yaml
# Create shared PVCs first
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-tv-shared
spec:
  accessModes: [ReadWriteMany]  # NFS or similar
  resources:
    requests:
      storage: 5Ti
---
apiVersion: v1  
kind: PersistentVolumeClaim
metadata:
  name: downloads-shared
spec:
  accessModes: [ReadWriteMany]
  resources:
    requests:
      storage: 1Ti
```

#### Option 2: Single PVC with SubPaths (Recommended)
Use one large PVC with subPaths for better management:

```yaml
# Create one large shared PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-shared
spec:
  accessModes: [ReadWriteMany]
  resources:
    requests:
      storage: 10Ti
```

Then reference with subPaths in multiple charts:
```yaml
# sonarr values
persistence:
  tv:
    existingClaim: "media-shared"
    subPath: "media/tv-shows"
  downloads:
    existingClaim: "media-shared"
    subPath: "downloads"

# radarr values (for movies)  
persistence:
  movies:
    existingClaim: "media-shared"
    subPath: "media/movies"
  downloads:
    existingClaim: "media-shared"
    subPath: "downloads"    # Same downloads folder

# qbittorrent values
persistence:
  downloads:
    existingClaim: "media-shared"
    subPath: "downloads"    # Same downloads folder
```

### Resource Recommendations

```yaml
# For small library (< 100 shows)
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

# For large library (> 1000 shows)  
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
# Check if Sonarr is responding
kubectl get pods -l app=sonarr

# Test HTTP endpoint
kubectl exec deployment/sonarr -- curl -f http://localhost:8989
```

### Database Maintenance
```bash
# Access container to run maintenance
kubectl exec -it deployment/sonarr -- /bin/bash

# Check database size
ls -lh /config/sonarr.db
```

## 🔗 Integration Examples

### With Prowlarr (Indexer Management)
1. Deploy Prowlarr in same namespace
2. In Prowlarr, configure Sonarr connection:
   - URL: `http://sonarr-service:8989`
   - API Key: From Sonarr settings

### With qBittorrent (Download Client)
```yaml
# Ensure same downloads volume
sonarr:
  persistence:
    downloads:
      existingClaim: "downloads-shared"

qbittorrent:  
  persistence:
    downloads:
      existingClaim: "downloads-shared"  # Same PVC
```

## 🔗 Links

- [Sonarr](https://github.com/Sonarr/Sonarr)
- [LinuxServer Sonarr](https://hub.docker.com/r/linuxserver/sonarr)
- [Sonarr Wiki](https://wiki.servarr.com/sonarr)