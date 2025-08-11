#!/bin/bash

# Generate README for GitHub Pages
set -e

echo "# 🏠 Homelab Helm Charts Repository"
echo ""
echo "Welcome to CubanCodeLab's collection of Helm charts for self-hosted homelab applications."
echo ""
echo "## 🚀 Quick Start"
echo ""
echo "Add this repository to your Helm:"
echo ""
echo '```bash'
echo "helm repo add cubancodelab https://charts.cubancodelab.net"
echo "helm repo update"
echo '```'
echo ""
echo "## 📦 Available Charts"
echo ""

# Generate chart table
echo "| Chart | Description | Version | App Version |"
echo "|-------|-------------|---------|-------------|"

for chart_dir in charts/*/; do
    if [[ -f "$chart_dir/Chart.yaml" ]]; then
        chart_name=$(basename "$chart_dir")
        
        # Extract information from Chart.yaml
        version=$(grep '^version:' "$chart_dir/Chart.yaml" | cut -d' ' -f2 | tr -d '"')
        app_version=$(grep '^appVersion:' "$chart_dir/Chart.yaml" | cut -d' ' -f2 | tr -d '"')
        description=$(grep '^description:' "$chart_dir/Chart.yaml" | cut -d':' -f2- | sed 's/^ *//' | tr -d '"')
        
        echo "| **$chart_name** | $description | $version | $app_version |"
    fi
done

echo ""
echo "## 💻 Installation Examples"
echo ""

# Add installation examples for each chart
for chart_dir in charts/*/; do
    if [[ -f "$chart_dir/Chart.yaml" && -f "$chart_dir/README.md" ]]; then
        chart_name=$(basename "$chart_dir")
        
        echo "### $chart_name"
        echo ""
        echo '```bash'
        echo "helm install my-$chart_name cubancodelab/$chart_name"
        echo '```'
        echo ""
        echo "For detailed configuration options, see the [${chart_name} chart documentation](https://github.com/barbar0jav1er/homelab-charts/blob/main/charts/${chart_name}/README.md)."
        echo ""
    fi
done

echo "## 🔧 Prerequisites"
echo ""
echo "- Kubernetes cluster (1.19+)"
echo "- Helm 3.0+"
echo "- Ingress controller (recommended: Traefik)"
echo "- Cert-manager (for TLS certificates)"
echo ""
echo "## 📚 Documentation"
echo ""
echo "For detailed configuration and examples, visit the [main repository](https://github.com/barbar0jav1er/homelab-charts)."
echo ""
echo "---"
echo ""
echo "*Last updated: $(date -u '+%Y-%m-%d %H:%M:%S UTC')*"