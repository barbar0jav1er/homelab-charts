# 🏠 My Home Lab Helm Charts

Collection of Helm charts for self-hosted applications in my personal homelab. These charts are designed for Kubernetes deployments with focus on simplicity, security and functionality.

## 🚀 Quick Start

Add the repository to your Helm:

```bash
# Add the repository
helm repo add homelab https://barbar0jav1er.github.io/homelab-charts

# Update repositories
helm repo update
```

## 📦 Available Charts

| Chart | Description | Version | App Version |
|-------|-------------|---------|-------------|
| **actual-server** | Self-hosted personal finance management with Actual Budget | Latest | 25.8.0 |
| **zero-api** | API service to integrate Actual Budget with ZeroTap mobile app | Latest | - |

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
```

### Zero API
API bridge for mobile integration:

```bash
helm install zero-api homelab/zero-api
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