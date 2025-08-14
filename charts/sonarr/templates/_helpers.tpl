{{/*
Expand the name of the chart.
*/}}
{{- define "sonarr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "sonarr.fullname" -}}
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
{{- define "sonarr.labels" -}}
app: {{ include "sonarr.name" . }}
instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sonarr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sonarr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the config PVC name
*/}}
{{- define "sonarr.configPVCName" -}}
{{- if .Values.persistence.config.existingClaim }}
{{- .Values.persistence.config.existingClaim }}
{{- else }}
{{- printf "%s-config" (include "sonarr.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Get the tv PVC name
*/}}
{{- define "sonarr.tvPVCName" -}}
{{- if .Values.persistence.tv.existingClaim }}
{{- .Values.persistence.tv.existingClaim }}
{{- else }}
{{- printf "%s-tv" (include "sonarr.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Get the downloads PVC name
*/}}
{{- define "sonarr.downloadsPVCName" -}}
{{- if .Values.persistence.downloads.existingClaim }}
{{- .Values.persistence.downloads.existingClaim }}
{{- else }}
{{- printf "%s-downloads" (include "sonarr.fullname" .) }}
{{- end }}
{{- end }}