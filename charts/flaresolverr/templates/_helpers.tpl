{{/*
Expand the name of the chart.
*/}}
{{- define "flaresolverr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "flaresolverr.fullname" -}}
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
{{- define "flaresolverr.labels" -}}
app: {{ include "flaresolverr.name" . }}
instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "flaresolverr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "flaresolverr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the tmp PVC name
*/}}
{{- define "flaresolverr.tmpPVCName" -}}
{{- if .Values.persistence.tmp.existingClaim }}
{{- .Values.persistence.tmp.existingClaim }}
{{- else }}
{{- printf "%s-tmp" (include "flaresolverr.fullname" .) }}
{{- end }}
{{- end }}