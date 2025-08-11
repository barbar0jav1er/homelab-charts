# Pi-hole Helm Chart

A comprehensive Helm chart for deploying Pi-hole DNS ad-blocker on Kubernetes with DNSCrypt-proxy integration.

## Overview

Pi-hole is a network-wide ad blocker that acts as a DNS sinkhole, protecting your network from ads and trackers. This chart includes:

- Pi-hole DNS ad-blocker
- DNSCrypt-proxy sidecar for encrypted DNS queries
- Persistent storage for configuration and logs
- LoadBalancer service for DNS queries
- Web interface with ingress support

## Features

- **DNS Ad-Blocking**: Block ads, trackers, and malicious domains network-wide
- **Encrypted DNS**: DNSCrypt-proxy sidecar for secure upstream DNS queries
- **Web Interface**: Clean web dashboard for management and statistics
- **Persistent Storage**: Configuration and query logs stored persistently
- **High Availability**: Kubernetes-native deployment with health checks

## Installation

```bash
helm install pihole ./charts/pihole
```

## Configuration

### Basic Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Pi-hole Docker image repository | `pihole/pihole` |
| `image.tag` | Pi-hole Docker image tag | `2025.08.0` |
| `password.create` | Create admin password secret | `true` |
| `password.value` | Admin password (change this!) | `changeme123` |
| `password.existingSecret` | Use existing secret for password | `""` |
| `password.existingSecretKey` | Key in existing secret | `admin-password` |

### DNS Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.timezone` | Container timezone | `Europe/Madrid` |
| `config.dnsUpstreams` | Upstream DNS servers | `127.0.0.1#5053` |
| `services.dns.enabled` | Enable DNS service | `true` |
| `services.dns.type` | DNS service type | `LoadBalancer` |
| `services.dns.loadBalancerIP` | Static IP for DNS service | `""` |

### DNSCrypt-proxy Sidecar

| Parameter | Description | Default |
|-----------|-------------|---------|
| `sidecar.dnscrypt.enabled` | Enable DNSCrypt-proxy sidecar | `true` |
| `sidecar.dnscrypt.image.repository` | DNSCrypt-proxy image | `klutchell/dnscrypt-proxy` |
| `sidecar.dnscrypt.image.tag` | DNSCrypt-proxy tag | `latest` |
| `sidecar.dnscrypt.port` | DNSCrypt-proxy port | `5053` |
| `sidecar.dnscrypt.config.server_names` | DNS servers to use | `['cloudflare', 'quad9']` |
| `sidecar.dnscrypt.config.cache` | Enable DNS caching | `true` |
| `sidecar.dnscrypt.config.cache_size` | DNS cache size | `4096` |

### Web Interface & Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `services.web.enabled` | Enable web service | `true` |
| `services.web.type` | Web service type | `ClusterIP` |
| `services.web.port` | Web service port | `80` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `traefik` |
| `ingress.host` | Ingress hostname | `pihole.local` |
| `ingress.tls.enabled` | Enable TLS | `true` |
| `ingress.tls.secretName` | TLS secret name | `pihole-tls` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.config.enabled` | Enable config persistence | `true` |
| `persistence.config.size` | Config storage size | `1Gi` |
| `persistence.config.storageClass` | Config storage class | `""` |
| `persistence.dnsmasq.enabled` | Enable dnsmasq persistence | `true` |
| `persistence.dnsmasq.size` | Dnsmasq storage size | `500Mi` |
| `persistence.dnsmasq.storageClass` | Dnsmasq storage class | `""` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |

## Installation Examples

### Basic Installation

```bash
helm install pihole ./charts/pihole \
  --set password.value=MySecurePassword123
```

### Custom Domain and Static IP

```bash
helm install pihole ./charts/pihole \
  --set ingress.host=dns.mydomain.com \
  --set services.dns.loadBalancerIP=192.168.1.100 \
  --set password.value=MySecurePassword123
```

### Using Existing Secret

```bash
# Create secret first
kubectl create secret generic pihole-admin --from-literal=password=MySecurePassword123

# Install with existing secret
helm install pihole ./charts/pihole \
  --set password.create=false \
  --set password.existingSecret=pihole-admin \
  --set password.existingSecretKey=password
```

### Disable DNSCrypt-proxy Sidecar

```bash
helm install pihole ./charts/pihole \
  --set sidecar.dnscrypt.enabled=false \
  --set config.dnsUpstreams="8.8.8.8,1.1.1.1"
```

### High Storage Configuration

```bash
helm install pihole ./charts/pihole \
  --set persistence.config.size=5Gi \
  --set persistence.dnsmasq.size=2Gi \
  --set resources.limits.memory=1Gi
```

## Post-Installation

1. **Access Web Interface**: Navigate to your configured ingress host or service IP
2. **Login**: Use the password you configured
3. **Configure DNS**: Point your devices to the Pi-hole DNS service IP
4. **Add Blocklists**: Configure additional ad and tracker blocklists
5. **Monitor**: Check the dashboard for blocked queries and statistics

## Architecture

```
[Clients] -> [Pi-hole DNS Service] -> [Pi-hole Container] -> [DNSCrypt-proxy] -> [Upstream DNS]
                                           |
[Web Interface] <- [Pi-hole Ingress] <- [Pi-hole Web Service]
```

## Security Considerations

- **Change Default Password**: Always change the default admin password
- **Use TLS**: Enable TLS for the web interface
- **Network Policies**: Consider implementing Kubernetes network policies
- **Resource Limits**: Configure appropriate resource limits
- **Regular Updates**: Keep Pi-hole image updated

## Troubleshooting

### DNS Not Working
- Check if DNS service has an external IP: `kubectl get svc pihole-dns`
- Verify pods are running: `kubectl get pods -l app.kubernetes.io/name=pihole`
- Check logs: `kubectl logs -l app.kubernetes.io/name=pihole`

### Web Interface Inaccessible
- Verify ingress is configured: `kubectl get ingress`
- Check web service: `kubectl get svc pihole-web`
- Confirm TLS certificate: `kubectl get certificate`

### DNSCrypt-proxy Issues
- Check sidecar logs: `kubectl logs <pod-name> -c dnscrypt-proxy`
- Verify configuration: `kubectl get configmap pihole-dnscrypt`

## Requirements

- Kubernetes 1.19+
- Helm 3.0+
- LoadBalancer support (for DNS service)
- Ingress controller (for web interface)
- Persistent volume support

## License

This chart is open source and available under the MIT license.