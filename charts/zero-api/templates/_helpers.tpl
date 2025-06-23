{{/*
=== HELPERS BÁSICOS DEL CHART ===
*/}}

{{/*
Expand the name of the chart.
Generate the Chart name, allow to override with nameOverride
*/}}
{{- define "zero-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Generate the app fullname combining release name + chart name
Avoid duplications if the release already contains the chart name
*/}}
{{- define "zero-api.fullname" -}}
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
Generate a tag to combine the chart name + version
Replace "+" with "_" to make it compatible with k8s labels
*/}}
{{- define "zero-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
Generate standard labels that should go in all resource
Include: chart, selector, labels, version, managed-by
*/}}
{{- define "zero-api.labels" -}}
helm.sh/chart: {{ include "zero-api.chart" . }}
{{ include "zero-api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
Just generate labels use to select the pods
This labels shouldn't be override once it is deployed
*/}}
{{- define "zero-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zero-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
=== HELPERS TO MANAGE SECRETS ===
*/}}

{{/*
Find out the secret name to use based on the managing method 
EXPLANATION:
- IF management = "existing": uses the name provided by the user
- IF management = "create" o "external": uses the name generate by the chart
*/}}
{{- define "zero-api.secretName" -}}
{{- if eq .Values.secrets.management "existing" -}}
{{- .Values.secrets.existingSecret.name -}}
{{- else -}}
{{- include "zero-api.fullname" . -}}-secrets
{{- end -}}
{{- end }}

{{/*
Find out the secret key for an specific field 
PARAMETERS: Receive a list with [context, keyName]  
EXPLANATION:
- IF management = "existing": uses the keys mapped by the user
- IF management = "create" o "external": usse the standard keys
*/}}
{{- define "zero-api.secretKey" -}}
{{- $context := index . 0 -}}
{{- $keyName := index . 1 -}}
{{- if eq $context.Values.secrets.management "existing" -}}
{{- index $context.Values.secrets.existingSecret.keys $keyName -}}
{{- else -}}
{{- if eq $keyName "actualServerUrl" -}}ACTUAL_SERVER_URL{{- end -}}
{{- if eq $keyName "actualPassword" -}}ACTUAL_PASSWORD{{- end -}}
{{- if eq $keyName "actualBudgetId" -}}ACTUAL_BUDGET_ID{{- end -}}
{{- end -}}
{{- end }}

{{/*
Find out the namespace to use
Priority .Values.namespace, if no uses .Release.Namespace
*/}}
{{- define "zero-api.namespace" -}}
{{- default .Release.Namespace .Values.namespace -}}
{{- end }}

{{/*
Validate secrets configurations
Check all the required fields are presents are presents based on the chosen method
*/}}
{{- define "zero-api.validateSecrets" -}}
{{- if eq .Values.secrets.management "existing" -}}
  {{- if not .Values.secrets.existingSecret.name -}}
    {{- fail "secrets.existingSecret.name is required when using existing secret management" -}}
  {{- end -}}
{{- else if eq .Values.secrets.management "external" -}}
  {{- if not .Values.externalSecret.enabled -}}
    {{- fail "externalSecret.enabled must be true when using external secret management" -}}
  {{- end -}}
{{- end -}}
{{- end }}

{{/*
=== HELPERS PARA SERVICE ACCOUNT ===
*/}}

{{/*
Create the name of the service account to use
*/}}
{{- define "zero-api.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "zero-api.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
=== HELPERS PARA CONFIGURACIÓN ===
*/}}

{{/*
Generate main container config
Centralize the environments variable and configuration
*/}}
{{- define "zero-api.containerEnv" -}}
{{- if .Values.config.useActualBudget -}}
- name: USE_ACTUAL_BUDGET
  value: {{ .Values.config.useActualBudget | quote }}
{{- end -}}
{{- $secretName := include "zero-api.secretName" . }}
{{- if $secretName }}
- name: ACTUAL_SERVER_URL
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ include "zero-api.secretKey" (list . "actualServerUrl") }}
- name: ACTUAL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ include "zero-api.secretKey" (list . "actualPassword") }}
- name: ACTUAL_BUDGET_ID
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ include "zero-api.secretKey" (list . "actualBudgetId") }}
{{- end }}
{{- with .Values.extraEnv }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
=== UTILS HELPERS ===
*/}}

{{/*
Determine if is necessary to create a PVC
*/}}
{{- define "zero-api.shouldCreatePVC" -}}
{{- and .Values.persistence.enabled (not .Values.persistence.existingClaim) -}}
{{- end }}

{{/*
Name the PVC to use
*/}}
{{- define "zero-api.pvcName" -}}
{{- if .Values.persistence.existingClaim -}}
{{- .Values.persistence.existingClaim -}}
{{- else -}}
{{- include "zero-api.fullname" . -}}-data
{{- end -}}
{{- end }}

{{/*
Generate resources commons annotations 
*/}}
{{- define "zero-api.commonAnnotations" -}}
{{- with .Values.commonAnnotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
DEBUG HELPER Show the actual secrets configurations
Only development/debugging
*/}}
{{- define "zero-api.debugSecrets" -}}
{{- if .Values.debug -}}
# DEBUG: Secret configuration
# Management method: {{ .Values.secrets.management }}
# Secret name: {{ include "zero-api.secretName" . }}
# Server URL key: {{ include "zero-api.secretKey" (list . "actualServerUrl") }}
# Password key: {{ include "zero-api.secretKey" (list . "actualPassword") }}
# Budget ID key: {{ include "zero-api.secretKey" (list . "actualBudgetId") }}
{{- end -}}
{{- end }}