# qBittorrent with Gluetun VPN

A Helm chart for deploying qBittorrent with Gluetun VPN sidecar container on Kubernetes. This setup ensures all qBittorrent traffic is securely routed through a VPN connection.

## Features

- **= VPN Protection**: All torrent traffic routed through VPN using Gluetun sidecar
- **< Multiple VPN Providers**: Support for NordVPN, ProtonVPN, ExpressVPN, Surfshark, Mullvad, and more
- **=' Flexible Protocols**: Both OpenVPN and WireGuard support
- **=á Built-in Firewall**: Gluetun firewall prevents traffic leaks
- **=æ Persistent Storage**: Separate volumes for config and downloads
- **>z Health Checks**: Comprehensive liveness and readiness probes
- **<¯ Easy Configuration**: Well-documented values with sensible defaults

## Architecture

This chart deploys two containers in a single pod:

1. **Gluetun VPN Container**: Handles VPN connection and network routing
2. **qBittorrent Container**: BitTorrent client using VPN network

## Quick Start

### Basic Installation

```bash
# Add the repository
helm repo add homelab-charts https://helms.cubancodelab.net

# Install with NordVPN (requires credentials)
helm install qbittorrent homelab-charts/qbittorrent \
  --set gluetun.credentials.username="your-nordvpn-username" \
  --set gluetun.credentials.password="your-nordvpn-password"
```

### Advanced Installation

```bash
# Install with custom configuration
helm install qbittorrent homelab-charts/qbittorrent \
  --set gluetun.vpn.provider="protonvpn" \
  --set gluetun.vpn.type="wireguard" \
  --set gluetun.vpn.serverCountries="Netherlands,Germany" \
  --set qbittorrent.persistence.downloads.size="500Gi" \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host="qbittorrent.example.com"
```

## Configuration

### VPN Providers

Supported VPN providers include:

| Provider | Configuration Key |
|----------|------------------|
| NordVPN | `nordvpn` |
| ProtonVPN | `protonvpn` |
| ExpressVPN | `expressvpn` |
| Surfshark | `surfshark` |
| Mullvad | `mullvad` |
| Private Internet Access | `private internet access` |
| Windscribe | `windscribe` |

### VPN Protocols

- **OpenVPN**: Traditional VPN protocol, widely supported
- **WireGuard**: Modern, faster VPN protocol (where supported by provider)

### Essential Configuration

```yaml
gluetun:
  enabled: true
  vpn:
    provider: "nordvpn"           # Your VPN provider
    type: "openvpn"               # openvpn or wireguard
    serverCountries: "Netherlands" # Target countries
  credentials:
    create: true                  # Create secret for credentials
    username: "your-username"     # VPN service username
    password: "your-password"     # VPN service password

qbittorrent:
  persistence:
    downloads:
      enabled: true
      size: "100Gi"               # Adjust for your needs
```

## Values Reference

### Global Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of pod replicas | `1` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full resource names | `""` |

### Gluetun VPN Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gluetun.enabled` | Enable Gluetun VPN sidecar | `true` |
| `gluetun.image.repository` | Gluetun image repository | `qmcgaw/gluetun` |
| `gluetun.image.tag` | Gluetun image tag | `v3.40.0` |
| `gluetun.vpn.provider` | VPN service provider | `nordvpn` |
| `gluetun.vpn.type` | VPN protocol type | `openvpn` |
| `gluetun.vpn.serverCountries` | Target server countries | `Netherlands` |
| `gluetun.credentials.create` | Create credentials secret | `true` |
| `gluetun.credentials.username` | VPN username | `""` |
| `gluetun.credentials.password` | VPN password | `""` |

### qBittorrent Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `qbittorrent.image.repository` | qBittorrent image | `linuxserver/qbittorrent` |
| `qbittorrent.image.tag` | qBittorrent image tag | `5.1.0` |
| `qbittorrent.bittorrentPort` | BitTorrent traffic port | `6881` |
| `qbittorrent.persistence.config.enabled` | Enable config persistence | `true` |
| `qbittorrent.persistence.config.size` | Config volume size | `2Gi` |
| `qbittorrent.persistence.downloads.enabled` | Enable downloads persistence | `true` |
| `qbittorrent.persistence.downloads.size` | Downloads volume size | `2Gi` |

### Network & Access

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.hosts[0].host` | Ingress hostname | `qbittorrent.example.com` |

## Usage Examples

### NordVPN with OpenVPN

```yaml
gluetun:
  vpn:
    provider: "nordvpn"
    type: "openvpn"
    serverCountries: "United States"
  credentials:
    username: "your-nordvpn-email"
    password: "your-nordvpn-password"
```

### ProtonVPN with WireGuard

```yaml
gluetun:
  vpn:
    provider: "protonvpn"
    type: "wireguard"
    serverCountries: "Switzerland,Netherlands"
  credentials:
    username: "protonvpn-username"
    password: "protonvpn-password"
```

### Using Existing Secret

```yaml
gluetun:
  credentials:
    create: false
    existingSecret: "my-vpn-secret"
    usernameKey: "vpn-user"
    passwordKey: "vpn-pass"
```

## Security Considerations

- **Network Isolation**: All qBittorrent traffic is routed through VPN
- **Kill Switch**: Built-in firewall prevents traffic leaks if VPN disconnects
- **Privileged Container**: Gluetun runs privileged for VPN functionality
- **Local Network Access**: Configured to allow access from Kubernetes networks

## Troubleshooting

### Check VPN Connection

```bash
# Check Gluetun logs
kubectl logs <pod-name> -c gluetun

# Verify IP address through VPN
kubectl exec <pod-name> -c qbittorrent -- curl -s ifconfig.me
```

### Common Issues

1. **VPN Not Connecting**: Check credentials and provider settings
2. **No Internet Access**: Verify firewall settings and allowed subnets
3. **qBittorrent Unreachable**: Check service configuration and firewall rules

### Debug Mode

Enable debug logging:

```yaml
gluetun:
  settings:
    LOG_LEVEL: "debug"
    FIREWALL_DEBUG: "on"
```

## Requirements

- Kubernetes 1.19+
- Helm 3.0+
- VPN service subscription with supported provider
- Storage class for persistent volumes

## Contributing

This chart is part of the homelab-charts collection. Please submit issues and pull requests to the main repository.