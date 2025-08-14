{{/*
Expand the name of the chart.
*/}}
{{- define "bazarr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "bazarr.fullname" -}}
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
{{- define "bazarr.labels" -}}
app: {{ include "bazarr.name" . }}
instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "bazarr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "bazarr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the config PVC name
*/}}
{{- define "bazarr.configPVCName" -}}
{{- if .Values.persistence.config.existingClaim }}
{{- .Values.persistence.config.existingClaim }}
{{- else }}
{{- printf "%s-config" (include "bazarr.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Get the movies PVC name
*/}}
{{- define "bazarr.moviesPVCName" -}}
{{- if .Values.persistence.movies.existingClaim }}
{{- .Values.persistence.movies.existingClaim }}
{{- else }}
{{- printf "%s-movies" (include "bazarr.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Get the tv PVC name
*/}}
{{- define "bazarr.tvPVCName" -}}
{{- if .Values.persistence.tv.existingClaim }}
{{- .Values.persistence.tv.existingClaim }}
{{- else }}
{{- printf "%s-tv" (include "bazarr.fullname" .) }}
{{- end }}
{{- end }}