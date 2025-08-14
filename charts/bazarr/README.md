# Bazarr Helm Chart

A Helm chart for deploying Bazarr on Kubernetes - an application for managing and downloading subtitles for your movies and TV shows.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Type](https://img.shields.io/badge/type-application-informational.svg)
![AppVersion](https://img.shields.io/badge/app%20version-1.5.2-informational.svg)

## ✨ Features

- 🎬 **Subtitle Management**: Automatically download and manage subtitles for movies and TV shows
- 📦 **Persistent Storage**: Configurable persistent volumes for config, movies, and TV shows
- 🌐 **Ingress Support**: Optional ingress controller integration with TLS
- 🔧 **Flexible PVC**: Support for existing PVCs or automatic PVC creation
- ⚙️ **Customizable**: Full control over resources, probes, and security contexts

## 🚀 Quick Start

### Basic Installation
```bash
helm install bazarr ./bazarr
```

### Installation with Media Volumes
```bash
helm install bazarr ./bazarr \
  --set persistence.movies.enabled=true \
  --set persistence.movies.size=500Gi \
  --set persistence.tv.enabled=true \
  --set persistence.tv.size=1Ti \
  --set ingress.enabled=true \
  --set ingress.host=bazarr.mydomain.com
```

### Using Existing PVCs
```bash
helm install bazarr ./bazarr \
  --set persistence.config.existingClaim=my-config-pvc \
  --set persistence.movies.enabled=true \
  --set persistence.movies.existingClaim=my-movies-pvc \
  --set persistence.tv.enabled=true \
  --set persistence.tv.existingClaim=my-tv-pvc
```

### Using Shared PVC with SubPaths
```bash
# Single shared PVC for all media
helm install bazarr ./bazarr \
  --set persistence.movies.enabled=true \
  --set persistence.movies.existingClaim=shared-media-pvc \
  --set persistence.movies.subPath=media/movies \
  --set persistence.tv.enabled=true \
  --set persistence.tv.existingClaim=shared-media-pvc \
  --set persistence.tv.subPath=media/tv-shows
```

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Configured StorageClass for persistent volumes
- Media files accessible via persistent volumes

## ⚙️ Configuration

### Media Library Setup

Bazarr needs access to your media files to manage subtitles:

#### Option 1: Separate PVCs
```yaml
persistence:
  movies:
    enabled: true
    size: 500Gi
    storageClass: "nfs-media"
    # Or use existing PVC
    existingClaim: "movies-pvc"
  
  tv:
    enabled: true  
    size: 1Ti
    storageClass: "nfs-media"
    # Or use existing PVC
    existingClaim: "tv-shows-pvc"
```

#### Option 2: Shared PVC with SubPaths (Recommended)
```yaml
persistence:
  movies:
    enabled: true
    existingClaim: "shared-media-pvc"
    subPath: "media/movies"        # Mount only movies subfolder
  
  tv:
    enabled: true
    existingClaim: "shared-media-pvc"
    subPath: "media/tv-shows"      # Mount only TV shows subfolder
```

This allows you to use a single large PVC organized like:
```
shared-media-pvc/
├── media/
│   ├── movies/
│   └── tv-shows/
├── downloads/
└── configs/
    ├── sonarr/
    ├── radarr/
    └── bazarr/
```

### Production Configuration Example

```yaml
# values-prod.yaml
persistence:
  config:
    enabled: true
    size: 5Gi
    storageClass: "fast-ssd"
  movies:
    enabled: true
    existingClaim: "movies-storage"
  tv:
    enabled: true
    existingClaim: "tv-storage"

ingress:
  enabled: true
  className: "nginx"
  host: "bazarr.mydomain.com"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
  tls:
    enabled: true
    secretName: "bazarr-tls"

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 256Mi
```

## 🔧 Configuration Parameters

### Main Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `linuxserver/bazarr` |
| `image.tag` | Image tag | `1.5.2` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `env.PUID` | User ID | `1000` |
| `env.PGID` | Group ID | `1000` |
| `env.TZ` | Timezone | `Etc/UTC` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `6767` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.config.enabled` | Enable config volume | `true` |
| `persistence.config.size` | Config volume size | `1Gi` |
| `persistence.config.storageClass` | Storage class | `""` |
| `persistence.config.existingClaim` | Use existing PVC | `""` |
| `persistence.movies.enabled` | Enable movies volume | `false` |
| `persistence.movies.size` | Movies volume size | `50Gi` |
| `persistence.movies.storageClass` | Storage class | `""` |
| `persistence.movies.existingClaim` | Use existing PVC | `""` |
| `persistence.movies.subPath` | Subpath within PVC | `""` |
| `persistence.tv.enabled` | Enable TV volume | `false` |
| `persistence.tv.size` | TV volume size | `50Gi` |
| `persistence.tv.storageClass` | Storage class | `""` |
| `persistence.tv.existingClaim` | Use existing PVC | `""` |
| `persistence.tv.subPath` | Subpath within PVC | `""` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `true` |
| `ingress.className` | Ingress class | `""` |
| `ingress.host` | Hostname | `bazarr.local` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.tls.enabled` | Enable TLS | `false` |
| `ingress.tls.secretName` | TLS secret name | `bazarr-tls` |

## 🔍 Usage and Management

### Access Bazarr WebUI

```bash
# Via port-forward (for testing)
kubectl port-forward deployment/bazarr 6767:6767

# Access at: http://localhost:6767
```

### Initial Setup

1. **First Access**: Navigate to your Bazarr WebUI
2. **Language Setup**: Configure your preferred subtitle languages
3. **Provider Setup**: Add subtitle providers (OpenSubtitles, etc.)
4. **Media Integration**: 
   - Add your movie library path: `/movies`
   - Add your TV shows library path: `/tv`
5. **Sonarr/Radarr Integration**: Configure API connections to your other *arr apps

### Common Mount Paths

When configuring Bazarr, use these paths that match the volume mounts:

- **Config**: `/config` (always mounted)
- **Movies**: `/movies` (if movies volume enabled)
- **TV Shows**: `/tv` (if TV volume enabled)

## 🔍 Troubleshooting

### Check Logs
```bash
kubectl logs deployment/bazarr -f
```

### Verify Volumes
```bash
# Check PVCs
kubectl get pvc

# Check volume mounts
kubectl describe pod -l app=bazarr
```

### Common Issues

#### **Media files not accessible**
- Verify volume mounts are correct
- Check file permissions (PUID/PGID)
- Ensure storage is properly mounted

#### **Subtitles not downloading**
- Check provider configurations
- Verify API keys for subtitle providers
- Check network connectivity from pod

#### **Performance issues**
- Increase CPU/Memory resources
- Use faster storage class for config
- Check provider rate limits

## 📊 Monitoring

### Health Checks
```bash
# Check if Bazarr is responding
kubectl get pods -l app=bazarr

# Test HTTP endpoint
kubectl exec deployment/bazarr -- curl -f http://localhost:6767
```

### Resource Usage
```bash
# Monitor resource usage
kubectl top pod -l app=bazarr
```

## 🔗 Integration

### With other *arr applications

Bazarr works best when integrated with Sonarr (TV shows) and Radarr (movies):

1. **Same PVCs**: Use the same PVCs for media across all *arr apps
2. **API Integration**: Configure Bazarr to connect to Sonarr/Radarr APIs
3. **Consistent Paths**: Use identical mount paths across all applications

Example shared media setup:
```yaml
# Shared across bazarr, sonarr, radarr using subPaths
persistence:
  movies:
    existingClaim: "shared-media-pvc"
    subPath: "media/movies"
  tv:
    existingClaim: "shared-media-pvc" 
    subPath: "media/tv-shows"

# This allows all *arr apps to share the same PVC but access different folders
```

## 🔗 Links

- [Bazarr](https://github.com/morpheus65535/bazarr)
- [LinuxServer Bazarr](https://hub.docker.com/r/linuxserver/bazarr)
- [Bazarr Wiki](https://wiki.bazarr.media/)