# 🏠 My Home Lab Helm Charts

Collection of Helm charts for self-hosted applications in my personal homelab. These charts are designed for Kubernetes deployments with focus on simplicity, security and functionality.

## 🚀 Quick Start

Add the repository to your Helm:

```bash
# Add the repository
helm repo add barbar0jav1er https://barbar0jav1er.github.io/homelab-charts

# Update repositories
helm repo update
```

## 📦 Available Charts

| Chart | Description | Version | App Version |
|-------|-------------|---------|-------------|
| **actual-server** | Self-hosted personal finance management with Actual Budget (supports OpenID Connect) | v0.2.0 | 25.8.0 |
| **pihole** | Network-wide DNS ad-blocker with DNSCrypt-proxy integration | Latest | 2025.08.0 |

## 💻 Installation Examples

### Actual Budget Server
Deploy your own personal finance management system:

```bash
# Basic installation
helm install actual-budget homelab/actual-server

# With custom domain and TLS
helm install actual-budget homelab/actual-server \
  --set ingress.host=budget.yourdomain.com \
  --set ingress.tls.enabled=true

# With persistent storage
helm install actual-budget homelab/actual-server \
  --set persistence.enabled=true \
  --set persistence.size=10Gi

# With OpenID Connect authentication
helm install actual-budget homelab/actual-server \
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
helm install pihole homelab/pihole

# With custom domain and static IP
helm install pihole homelab/pihole \
  --set ingress.host=dns.yourdomain.com \
  --set services.dns.loadBalancerIP=192.168.1.100 \
  --set password.value=MySecurePassword

# Without DNSCrypt-proxy sidecar
helm install pihole homelab/pihole \
  --set sidecar.dnscrypt.enabled=false \
  --set config.dnsUpstreams="8.8.8.8,1.1.1.1"
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