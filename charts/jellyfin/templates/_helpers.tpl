{{/*
Expand the name of the chart.
*/}}
{{- define "jellyfin.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "jellyfin.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "jellyfin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "jellyfin.labels" -}}
helm.sh/chart: {{ include "jellyfin.chart" . }}
{{ include "jellyfin.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "jellyfin.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jellyfin.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate the JELLYFIN_PublishedServerUrl
Priority:
1. If explicitly set in values, use that
2. If Ingress is enabled, auto-generate from first host
3. Otherwise, return empty (don't set the env var)
*/}}
{{- define "jellyfin.publishedServerUrl" -}}
{{- if .Values.env.JELLYFIN_PublishedServerUrl -}}
{{- .Values.env.JELLYFIN_PublishedServerUrl -}}
{{- else if and .Values.ingress.enabled .Values.ingress.hosts -}}
{{- $protocol := "http" -}}
{{- if .Values.ingress.tls -}}
{{- $protocol = "https" -}}
{{- end -}}
{{- printf "%s://%s" $protocol (index .Values.ingress.hosts 0).host -}}
{{- end -}}
{{- end }}

{{/*
Check if JELLYFIN_PublishedServerUrl should be set
*/}}
{{- define "jellyfin.shouldSetPublishedServerUrl" -}}
{{- if or .Values.env.JELLYFIN_PublishedServerUrl (and .Values.ingress.enabled .Values.ingress.hosts) -}}
true
{{- end -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "jellyfin.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "jellyfin.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Check if hardware acceleration is enabled
*/}}
{{- define "jellyfin.hardwareAcceleration.enabled" -}}
{{- .Values.hardwareAcceleration.enabled -}}
{{- end }}

{{/*
Check if Intel/AMD hardware acceleration is enabled (requires /dev/dri)
*/}}
{{- define "jellyfin.hardwareAcceleration.needsDevices" -}}
{{- if and (include "jellyfin.hardwareAcceleration.enabled" .) (or (eq .Values.hardwareAcceleration.type "intel") (eq .Values.hardwareAcceleration.type "amd")) -}}
true
{{- end -}}
{{- end }}

{{/*
Check if NVIDIA hardware acceleration is enabled
*/}}
{{- define "jellyfin.hardwareAcceleration.isNvidia" -}}
{{- if and (include "jellyfin.hardwareAcceleration.enabled" .) (eq .Values.hardwareAcceleration.type "nvidia") -}}
true
{{- end -}}
{{- end }}

{{/*
Get the render group ID for Intel/AMD
*/}}
{{- define "jellyfin.hardwareAcceleration.renderGroup" -}}
{{- if eq .Values.hardwareAcceleration.type "intel" -}}
{{- .Values.hardwareAcceleration.intel.renderGroup | default 109 -}}
{{- else if eq .Values.hardwareAcceleration.type "amd" -}}
{{- .Values.hardwareAcceleration.amd.renderGroup | default 109 -}}
{{- else -}}
109
{{- end -}}
{{- end }}