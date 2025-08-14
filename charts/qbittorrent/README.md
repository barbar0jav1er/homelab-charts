# qBittorrent Helm Chart

A Helm chart for deploying qBittorrent on Kubernetes with optional VPN sidecar integration using Gluetun.

![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)
![Type](https://img.shields.io/badge/type-application-informational.svg)
![AppVersion](https://img.shields.io/badge/app%20version-5.1.2-informational.svg)

## ✨ Features

- 🔄 **qBittorrent**: Modern web-based BitTorrent client
- 🔒 **VPN Sidecar**: Optional VPN integration using Gluetun (supports NordVPN, ExpressVPN, Surfshark, and many more)
- 🛡️ **Kill Switch**: Automatic protection if VPN disconnects
- 📦 **Persistent Storage**: For configuration and downloads
- 🌐 **Ingress**: Support for external access with TLS
- ⚡ **Multi-Protocol**: Support for both OpenVPN and Wireguard

## 🚀 Quick Start

### Basic Installation (without VPN)
```bash
helm repo add qbittorrent https://your-repo.com/charts
helm install qbittorrent qbittorrent/qbittorrent
```

### Installation with VPN (Recommended)

#### Using OpenVPN with NordVPN
```bash
helm install qbittorrent qbittorrent/qbittorrent \
  --set vpn.enabled=true \
  --set vpn.vpnType="openvpn" \
  --set vpn.openvpnUser="your-nordvpn-service-username" \
  --set vpn.openvpnPassword="your-nordvpn-service-password" \
  --set vpn.serverCountries="Spain" \
  --set persistence.downloads.enabled=true \
  --set persistence.downloads.size="500Gi"
```

#### Using Wireguard with NordVPN
```bash
helm install qbittorrent qbittorrent/qbittorrent \
  --set vpn.enabled=true \
  --set vpn.vpnType="wireguard" \
  --set vpn.wireguardPrivateKey="your-wireguard-private-key" \
  --set vpn.serverCountries="Spain" \
  --set persistence.downloads.enabled=true \
  --set persistence.downloads.size="500Gi"
```

#### Using Shared PVC with SubPath
```bash
# Share downloads folder with other *arr applications
helm install qbittorrent qbittorrent/qbittorrent \
  --set vpn.enabled=true \
  --set vpn.vpnType="openvpn" \
  --set vpn.openvpnUser="your-service-username" \
  --set vpn.openvpnPassword="your-service-password" \
  --set persistence.downloads.enabled=true \
  --set persistence.downloads.existingClaim="shared-media-pvc" \
  --set persistence.downloads.subPath="downloads"
```

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Configured StorageClass for persistent volumes
- **For VPN**: VPN provider credentials (see Configuration section)

## ⚙️ Configuration

### VPN Setup

#### NordVPN Credentials

**For OpenVPN:**
1. Go to [NordVPN Manual Configuration](https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/service-credentials/)
2. Generate service credentials (NOT your regular login)
3. Use the service username/password in configuration

**For Wireguard:**
1. Go to NordVPN manual setup section
2. Generate a Wireguard private key
3. Use the private key in configuration

#### Other VPN Providers

Gluetun supports many providers. Change `serviceProvider` to:
- `expressvpn`
- `surfshark`
- `mullvad`
- `privatevpn`
- And many more...

### Server Selection

```yaml
vpn:
  serverCountries: "Spain,Netherlands"  # Comma-separated countries
  serverRegions: "Madrid,Barcelona"     # Specific regions
  serverCities: "Madrid"                # Specific cities
  serverCategories: "P2P"               # Server categories (if supported)
```

### Recommended Configuration

```yaml
vpn:
  enabled: true
  serviceProvider: "nordvpn"
  vpnType: "openvpn"              # or "wireguard"
  
  # OpenVPN credentials
  openvpnUser: "your-service-username"
  openvpnPassword: "your-service-password"
  
  # Server selection
  serverCountries: "Spain,Netherlands"
  
  # Health check
  healthCheckUrl: "google.com:443"

persistence:
  downloads:
    enabled: true
    # Option 1: Create new PVC
    size: 500Gi
    storageClass: "fast-storage"
    
    # Option 2: Use shared PVC with subPath (recommended for *arr integration)
    existingClaim: "shared-media-pvc"
    subPath: "downloads"          # Share downloads folder with Sonarr/Radarr
```

### Shared Storage with *arr Applications

For optimal integration with Sonarr/Radarr, use a shared PVC:

```yaml
# Single PVC structure:
shared-media-pvc/
├── downloads/              # qBittorrent writes here, *arr apps read from here
├── media/
│   ├── tv-shows/          # Sonarr manages, Bazarr reads
│   └── movies/            # Radarr manages, Bazarr reads
└── incomplete/            # qBittorrent temp downloads
```

Configuration for shared setup:
```yaml
vpn:
  enabled: true
  serviceProvider: "nordvpn"
  vpnType: "openvpn"
  openvpnUser: "your-service-username"
  openvpnPassword: "your-service-password"
  serverCountries: "Spain,Netherlands"

persistence:
  downloads:
    enabled: true
    existingClaim: "shared-media-pvc"
    subPath: "downloads"

## 📊 Configuration Examples

### Basic Development Setup
```yaml
# values-dev.yaml
persistence:
  downloads:
    enabled: true
    size: 10Gi

service:
  webui:
    type: NodePort

ingress:
  enabled: false
```

### Production Setup with VPN
```yaml
# values-prod.yaml
vpn:
  enabled: true
  serviceProvider: "nordvpn"
  vpnType: "openvpn"
  openvpnUser: "your-service-username"
  openvpnPassword: "your-service-password"
  serverCountries: "Spain"

persistence:
  config:
    enabled: true
    size: 5Gi
    storageClass: "fast-ssd"
  downloads:
    enabled: true
    size: 2Ti
    storageClass: "bulk-storage"

ingress:
  enabled: true
  className: "nginx"
  host: "torrents.mydomain.com"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
  tls:
    enabled: true
    secretName: "torrents-tls"

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 256Mi

vpn:
  resources:
    limits:
      cpu: 200m
      memory: 128Mi
    requests:
      cpu: 50m
      memory: 64Mi
```

### Install with values file
```bash
helm install qbittorrent qbittorrent/qbittorrent -f values-prod.yaml
```

## 🔧 Configuration Parameters

### Main Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `linuxserver/qbittorrent` |
| `image.tag` | Image tag | `latest` |
| `env.PUID` | User ID | `1000` |
| `env.PGID` | Group ID | `1000` |
| `env.TZ` | Timezone | `Etc/UTC` |
| `env.WEBUI_PORT` | WebUI port | `8080` |

### VPN Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `vpn.enabled` | Enable VPN sidecar | `false` |
| `vpn.serviceProvider` | VPN provider (nordvpn, expressvpn, etc.) | `"nordvpn"` |
| `vpn.vpnType` | VPN type (openvpn, wireguard) | `"openvpn"` |
| `vpn.openvpnUser` | OpenVPN username | `""` |
| `vpn.openvpnPassword` | OpenVPN password | `""` |
| `vpn.wireguardPrivateKey` | Wireguard private key | `""` |
| `vpn.serverCountries` | Server countries | `"United States"` |
| `vpn.serverRegions` | Server regions | `""` |
| `vpn.serverCities` | Server cities | `""` |
| `vpn.serverHostnames` | Specific server hostnames | `""` |
| `vpn.serverCategories` | Server categories | `""` |
| `vpn.healthCheckUrl` | Health check URL | `"google.com:443"` |

### Services

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.webui.enabled` | Enable WebUI service | `true` |
| `service.webui.type` | Service type | `ClusterIP` |
| `service.webui.port` | Service port | `8080` |
| `service.torrenting.enabled` | Enable torrenting service | `false` |

### Storage

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.config.enabled` | Enable config volume | `true` |
| `persistence.config.size` | Config volume size | `1Gi` |
| `persistence.downloads.enabled` | Enable downloads volume | `false` |
| `persistence.downloads.size` | Downloads volume size | `100Gi` |
| `persistence.downloads.existingClaim` | Use existing PVC | `""` |
| `persistence.downloads.subPath` | Subpath within PVC | `""` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.className` | Ingress class | `""` |
| `ingress.host` | Hostname | `qbittorrent.local` |
| `ingress.tls.enabled` | Enable TLS | `false` |

## 🔍 Verification and Troubleshooting

### Verify VPN is working
```bash
# Check external IP (should be VPN server IP)
kubectl exec deployment/qbittorrent -c qbittorrent -- curl -s ifconfig.me

# Verify VPN connection
kubectl logs deployment/qbittorrent -c gluetun

# View qBittorrent logs
kubectl logs deployment/qbittorrent -c qbittorrent
```

### Access WebUI
```bash
# Local port forward
kubectl port-forward deployment/qbittorrent 8080:8080

# Access at: http://localhost:8080
# Default user: admin
# Password: check container logs
```

### Common Issues

#### VPN won't connect
```bash
# Verify credentials and configuration
kubectl describe pod -l app=qbittorrent

# View detailed VPN logs
kubectl logs deployment/qbittorrent -c gluetun -f
```

#### Slow downloads
- Use specific countries: `vpn.serverCountries: "Spain,Netherlands"`
- Try Wireguard: `vpn.vpnType: "wireguard"`
- Check server categories if supported

#### WebUI inaccessible
- Configure Ingress properly
- Use port-forward for direct access
- Check gluetun logs for network issues

## 🔐 Security

### Security Recommendations

1. **Always use VPN** for torrenting
2. **Change default password** immediately
3. **Use basic authentication** on Ingress
4. **Use Kubernetes secrets** for VPN credentials
5. **Monitor logs** regularly

### Secret Management

For sensitive credentials:
```bash
# Create secret for VPN credentials
kubectl create secret generic vpn-credentials \
  --from-literal=openvpn-user="your-username" \
  --from-literal=openvpn-password="your-password" \
  --from-literal=wireguard-private-key="your-key"

# Use in values.yaml
vpn:
  credentialsSecret:
    name: "vpn-credentials"
    openvpnUserKey: "openvpn-user"
    openvpnPasswordKey: "openvpn-password"
    wireguardPrivateKeyKey: "wireguard-private-key"
```

## 🔗 Links

- [qBittorrent](https://github.com/qbittorrent/qBittorrent)
- [Gluetun VPN Client](https://github.com/qdm12/gluetun)
- [NordVPN Manual Configuration](https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/)
- [Gluetun Wiki](https://github.com/qdm12/gluetun-wiki)