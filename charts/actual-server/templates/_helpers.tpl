{{/*
Expand the name of the chart.
*/}}
{{- define "actual-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "actual-server.fullname" -}}
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
{{- define "actual-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "actual-server.labels" -}}
helm.sh/chart: {{ include "actual-server.chart" . }}
{{ include "actual-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "actual-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "actual-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "actual-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "actual-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
OpenID client secret name and key
*/}}
{{- define "actual-server.openidSecretName" -}}
{{- if .Values.actualBudget.openid.clientSecret.existingSecret }}
{{- .Values.actualBudget.openid.clientSecret.existingSecret }}
{{- else }}
{{- printf "%s-openid" (include "actual-server.fullname" .) }}
{{- end }}
{{- end }}

{{- define "actual-server.openidSecretKey" -}}
{{- if .Values.actualBudget.openid.clientSecret.existingSecret }}
{{- .Values.actualBudget.openid.clientSecret.existingSecretKey | default "client-secret" }}
{{- else }}
{{- "client-secret" }}
{{- end }}
{{- end }}