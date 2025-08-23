# 🏠 My Home Lab Helm Charts

Collection of Helm charts for self-hosted applications in my personal homelab. These charts are designed for Kubernetes deployments with focus on simplicity, security and functionality.

## 🚀 Quick Start

Add the repository to your Helm:

```bash
# Add the repository
helm repo add cubancodelab https://helms.cubancodelab.net

# Update repositories
helm repo update
```

## 📦 Available Charts

| Chart | Description | Version | App Version |
|-------|-------------|---------|-------------|
| **actual-server** | Self-hosted personal finance management with Actual Budget (supports OpenID Connect) | 0.3.0 | 25.8.0 |
| **bazarr** | Subtitle management for TV shows and movies, companion to Sonarr/Radarr | 0.1.2 | latest |
| **flaresolverr** | Cloudflare bypass proxy for indexers with headless browser automation | 0.1.0 | latest |
| **jellyfin** | Media server with emptyDir cache support for better performance | 0.2.0 | 10.10.7 |
| **jellyseerr** | Media request and discovery tool for Jellyfin and Plex servers | 0.1.1 | latest |
| **pihole** | Network-wide DNS ad-blocker with DNSCrypt-proxy integration | Latest | 2025.08.0 |
| **prowlarr** | Centralized indexer manager for all *arr applications | 0.1.2 | latest |
| **qbittorrent** | qBittorrent with Gluetun VPN sidecar for secure torrenting | 0.4.1 | 5.1.0 |
| **radarr** | Movie collection manager with simplified media volume configuration | 0.2.2 | latest |
| **sonarr** | TV series collection manager with automated episode monitoring | 0.1.2 | latest |
| **transmission-openvpn** | Transmission BitTorrent client with OpenVPN support | 0.1.0 | latest |

## 💻 Installation Examples

### Actual Budget Server
Deploy your own personal finance management system:

```bash
# Basic installation
helm install actual-budget cubancodelab/actual-server

# With custom domain and TLS
helm install actual-budget cubancodelab/actual-server \
  --set ingress.host=budget.yourdomain.com \
  --set ingress.tls.enabled=true

# With persistent storage and custom storage class
helm install actual-budget cubancodelab/actual-server \
  --set persistence.enabled=true \
  --set persistence.size=10Gi \
  --set persistence.storageClass=fast-ssd

# Using existing PVC
helm install actual-budget cubancodelab/actual-server \
  --set persistence.enabled=true \
  --set persistence.existingClaim=my-actual-pvc

# With OpenID Connect authentication
helm install actual-budget cubancodelab/actual-server \
  --set actualBudget.loginMethod=openid \
  --set actualBudget.openid.enabled=true \
  --set actualBudget.openid.discoveryUrl="https://auth.example.com/.well-known/openid_configuration" \
  --set actualBudget.openid.clientId="your-client-id" \
  --set actualBudget.openid.serverHostname="https://budget.yourdomain.com"
```

### Pi-hole DNS Ad-Blocker
Deploy network-wide ad-blocking with encrypted DNS:

```bash
# Basic installation
helm install pihole cubancodelab/pihole

# With custom domain and static IP
helm install pihole cubancodelab/pihole \
  --set ingress.host=dns.yourdomain.com \
  --set services.dns.loadBalancerIP=192.168.1.100 \
  --set password.value=MySecurePassword

# Without DNSCrypt-proxy sidecar
helm install pihole cubancodelab/pihole \
  --set sidecar.dnscrypt.enabled=false \
  --set config.dnsUpstreams="8.8.8.8,1.1.1.1"
```

### Jellyfin Media Server
Deploy your media streaming server:

```bash
# Basic installation with emptyDir cache (default)
helm install jellyfin cubancodelab/jellyfin

# With persistent cache storage
helm install jellyfin cubancodelab/jellyfin \
  --set persistence.cache.type=pvc \
  --set persistence.cache.storageClass=fast-ssd

# With custom domain and hardware acceleration
helm install jellyfin cubancodelab/jellyfin \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=media.yourdomain.com \
  --set hardwareAcceleration.enabled=true \
  --set hardwareAcceleration.type=intel
```

### Transmission with OpenVPN
Deploy BitTorrent client with VPN protection:

```bash
# Basic installation
helm install transmission cubancodelab/transmission-openvpn

# With NordVPN and persistent storage
helm install transmission cubancodelab/transmission-openvpn \
  --set openvpn.provider=NORDVPN \
  --set openvpn.credentials.existingSecret=nordvpn-credentials \
  --set persistence.enabled=true \
  --set persistence.size=100Gi \
  --set persistence.storageClass=fast-ssd

# With custom configuration and shared downloads
helm install transmission cubancodelab/transmission-openvpn \
  --set transmission.settings.TRANSMISSION_SPEED_LIMIT_UP=2048 \
  --set transmission.settings.TRANSMISSION_DOWNLOAD_DIR=/downloads \
  --set extraVolumes[0].name=shared-media \
  --set extraVolumes[0].persistentVolumeClaim.claimName=shared-media-pvc
```


## 🔧 Prerequisites

- Kubernetes cluster (1.19+)
- Helm 3.0+
- Ingress controller (recommended: Traefik)
- Cert-manager (for TLS certificates)

## 🏗️ Chart Development

Each chart includes:
- Comprehensive values.yaml with sensible defaults
- Health checks and probes
- Resource limits and requests
- Ingress configuration with TLS support
- Service account management
- Detailed README with configuration options

## 📝 Contributing

Feel free to submit issues and enhancement requests. This is a personal homelab setup, but contributions are welcome.

## 🛡️ Security

All charts follow Kubernetes security best practices:
- Non-root containers when possible
- Resource constraints
- Network policies support
- Secret management
- RBAC configuration