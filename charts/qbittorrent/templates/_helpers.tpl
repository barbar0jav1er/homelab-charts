{{/*
Expand the name of the chart.
*/}}
{{- define "qbittorrent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "qbittorrent.fullname" -}}
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
Common labels
*/}}
{{- define "qbittorrent.labels" -}}
app: {{ include "qbittorrent.name" . }}
instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "qbittorrent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "qbittorrent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the config PVC name
*/}}
{{- define "qbittorrent.configPVCName" -}}
{{- if .Values.persistence.config.existingClaim }}
{{- .Values.persistence.config.existingClaim }}
{{- else }}
{{- printf "%s-config" (include "qbittorrent.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Get the downloads PVC name
*/}}
{{- define "qbittorrent.downloadsPVCName" -}}
{{- if .Values.persistence.downloads.existingClaim }}
{{- .Values.persistence.downloads.existingClaim }}
{{- else }}
{{- printf "%s-downloads" (include "qbittorrent.fullname" .) }}
{{- end }}
{{- end }}