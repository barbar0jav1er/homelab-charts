# Actual Server Helm Chart

A Helm chart for deploying Actual Budget server on Kubernetes.

## Overview

Actual is a local-first personal finance tool. This chart deploys the Actual Budget server which provides a web interface for managing your finances with full control over your data.

## Installation

```bash
helm install actual-server ./charts/actual-server
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Docker image repository | `actualbudget/actual-server` |
| `image.tag` | Docker image tag | `""` (uses chart appVersion) |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `5006` |
| `actualBudget.port` | Application port | `5006` |
| `actualBudget.loginMethod` | Login method (`password` or `openid`) | `password` |
| `actualBudget.timezone` | Container timezone (IANA format) | `Europe/Madrid` |
| `actualBudget.upload.fileSizeSyncLimitMB` | File sync size limit | `20` |
| `actualBudget.upload.syncEncryptedFileSizeLimitMB` | Encrypted file sync limit | `50` |
| `actualBudget.upload.fileSizeLimitMB` | File upload size limit | `20` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `traefik` |
| `ingress.host` | Ingress hostname | `actual.local` |
| `ingress.tls.enabled` | Enable TLS | `true` |
| `ingress.tls.secretName` | TLS secret name | `actual-server-tls` |
| `persistence.enabled` | Enable persistent storage | `false` |
| `persistence.size` | Storage size | `8Gi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |

### OpenID Connect Authentication

| Parameter | Description | Default |
|-----------|-------------|---------|
| `actualBudget.openid.enabled` | Enable OpenID Connect authentication | `false` |
| `actualBudget.openid.discoveryUrl` | OpenID Provider discovery URL | `""` |
| `actualBudget.openid.authorizationEndpoint` | Authorization endpoint (if no discovery) | `""` |
| `actualBudget.openid.tokenEndpoint` | Token endpoint (if no discovery) | `""` |
| `actualBudget.openid.userinfoEndpoint` | User info endpoint (if no discovery) | `""` |
| `actualBudget.openid.clientId` | OpenID client ID | `""` |
| `actualBudget.openid.serverHostname` | Your Actual Server URL for redirects | `""` |
| `actualBudget.openid.clientSecret.value` | Client secret value (creates new secret) | `""` |
| `actualBudget.openid.clientSecret.existingSecret` | Existing secret name | `""` |
| `actualBudget.openid.clientSecret.existingSecretKey` | Key in existing secret | `"client-secret"` |

## Examples

### Basic installation with custom hostname:

```bash
helm install actual-server ./charts/actual-server \
  --set ingress.host=budget.example.com
```

### Installation with persistent storage:

```bash
helm install actual-server ./charts/actual-server \
  --set persistence.enabled=true \
  --set persistence.size=10Gi
```

### Installation with custom resources:

```bash
helm install actual-server ./charts/actual-server \
  --set resources.limits.memory=1Gi \
  --set resources.limits.cpu=1000m
```

### Installation with custom timezone:

```bash
helm install actual-server ./charts/actual-server \
  --set actualBudget.timezone="America/New_York"
```

### OpenID Connect with Discovery (Recommended):

```bash
helm install actual-server ./charts/actual-server \
  --set actualBudget.loginMethod=openid \
  --set actualBudget.openid.enabled=true \
  --set actualBudget.openid.discoveryUrl="https://auth.example.com/.well-known/openid_configuration" \
  --set actualBudget.openid.clientId="your-client-id" \
  --set actualBudget.openid.serverHostname="https://budget.example.com" \
  --set actualBudget.openid.clientSecret.value="your-client-secret"
```

### OpenID Connect with Manual Endpoints:

```bash
helm install actual-server ./charts/actual-server \
  --set actualBudget.loginMethod=openid \
  --set actualBudget.openid.enabled=true \
  --set actualBudget.openid.authorizationEndpoint="https://auth.example.com/oauth2/authorize" \
  --set actualBudget.openid.tokenEndpoint="https://auth.example.com/oauth2/token" \
  --set actualBudget.openid.userinfoEndpoint="https://auth.example.com/oauth2/userinfo" \
  --set actualBudget.openid.clientId="your-client-id" \
  --set actualBudget.openid.serverHostname="https://budget.example.com" \
  --set actualBudget.openid.clientSecret.existingSecret="my-secret" \
  --set actualBudget.openid.clientSecret.existingSecretKey="oauth-client-secret"
```

### Using Values File for OpenID:

```bash
helm install actual-server ./charts/actual-server -f openid-values.yaml
```

## Authentication Methods

### Password Authentication (Default)
Simple password-based authentication. Suitable for single-user deployments.

### OpenID Connect Authentication
Robust authentication using OpenID Connect providers (like Authentik, Keycloak, Auth0, etc.):
- **Multi-factor authentication support**
- **Multiple user support** 
- **Discovery support**: Automatic configuration via `.well-known/openid_configuration`
- **Manual endpoints**: For providers without discovery support
- **Flexible secret management**: Use existing secrets or create new ones

## Health Checks

The chart includes both readiness and liveness probes using the official Actual Budget health check script.

## Requirements

- Kubernetes 1.19+
- Helm 3.0+

## License

This chart is open source and available under the MIT license.