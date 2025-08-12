# Radarr

A Helm chart for Radarr movie collection manager for Usenet and BitTorrent users.

## Description

Radarr is a movie collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new movies and will interface with clients and indexers to grab, sort, and rename them.

## Installation

Add the repository and install the chart:

```bash
# Add the repository
helm repo add cubancodelab https://helms.cubancodelab.net

# Update repositories
helm repo update

# Install Radarr
helm install radarr cubancodelab/radarr
```

## Configuration

### Basic Installation Examples

```bash
# Basic installation with default settings
helm install radarr cubancodelab/radarr

# With custom timezone and user IDs
helm install radarr cubancodelab/radarr \
  --set env.TZ="America/New_York" \
  --set env.PUID="1000" \
  --set env.PGID="1000"

# With ingress and custom domain
helm install radarr cubancodelab/radarr \
  --set ingress.enabled=true \
  --set ingress.host="radarr.yourdomain.com" \
  --set ingress.tls.enabled=true

# With media storage PVC
helm install radarr cubancodelab/radarr \
  --set persistence.media.enabled=true \
  --set persistence.media.size="500Gi" \
  --set persistence.movies.enabled=true \
  --set persistence.movies.size="100Gi"
```

## Storage Configuration

### Create New PVC for Media
The chart can create a new PVC for media storage:

```yaml
persistence:
  media:
    enabled: true
    existingClaim: ""  # Leave empty to create new PVC
    size: 100Gi
    storageClass: "fast-ssd"  # Optional
    mountPath: "/media"
```

### Use Existing PVC
To use an existing PVC for shared media storage:

```yaml
persistence:
  media:
    enabled: true
    existingClaim: "shared-media-storage"
    mountPath: "/media"
```

## Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `env.TZ` | Timezone | `Etc/UTC` |
| `env.PUID` | Process User ID | `1000` |
| `env.PGID` | Process Group ID | `1000` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `7878` |
| `ingress.enabled` | Enable ingress | `false` |
| `persistence.config.enabled` | Enable config persistence | `true` |
| `persistence.config.size` | Config volume size | `1Gi` |
| `persistence.movies.enabled` | Enable movies persistence | `false` |
| `persistence.movies.size` | Movies volume size | `50Gi` |
| `persistence.media.enabled` | Enable media persistence | `false` |
| `persistence.media.size` | Media volume size | `100Gi` |
| `persistence.media.existingClaim` | Use existing PVC | `""` |

## Production Example

```yaml
# values.yaml
image:
  tag: "4.7.5"

env:
  TZ: "America/New_York"
  PUID: "1000"
  PGID: "1000"

ingress:
  enabled: true
  className: "traefik"
  host: "radarr.example.com"
  tls:
    enabled: true
    secretName: "radarr-tls"

persistence:
  config:
    enabled: true
    size: 5Gi
    storageClass: "local-path"
  media:
    enabled: true
    size: 500Gi
    storageClass: "local-path"
    mountPath: "/media"
  movies:
    enabled: true
    size: 100Gi

resources:
  limits:
    cpu: 1000m
    memory: 2Gi
  requests:
    cpu: 100m
    memory: 256Mi
```

Then install with:
```bash
helm install radarr cubancodelab/radarr -f values.yaml
```

## Links

- [Radarr Wiki](https://wiki.servarr.com/radarr)
- [Docker Image](https://hub.docker.com/r/linuxserver/radarr)