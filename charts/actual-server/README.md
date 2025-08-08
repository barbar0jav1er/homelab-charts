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
| `actualBudget.loginMethod` | Login method | `password` |
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

## Health Checks

The chart includes both readiness and liveness probes using the official Actual Budget health check script.

## Requirements

- Kubernetes 1.19+
- Helm 3.0+

## License

This chart is open source and available under the MIT license.