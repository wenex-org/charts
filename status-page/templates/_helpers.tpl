{{/*
Expand the name of the chart.
*/}}
{{- define "status-page.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "status-page.fullname" -}}
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
{{- define "status-page.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "status-page.labels" -}}
helm.sh/chart: {{ include "status-page.chart" . }}
{{ include "status-page.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "status-page.selectorLabels" -}}
app.kubernetes.io/name: {{ include "status-page.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "status-page.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "status-page.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the configuration variables
*/}}
{{- define "status-page.global.configuration" -}}
{{- range $service, $config := .Values.global.configuration }}
- name: {{ $service | upper }}_HOST
  value: {{ $config.host | quote }}
- name: {{ $service | upper }}_API_PORT
  value: {{ $config.api | default "80" | quote }}
{{- end }}
{{- end }}

{{/*
Create the envs variable
*/}}
{{- define "status-page.global.envs" -}}
- name: APP_VERSION
  value: {{ .Values.global.image.tag | quote }}
# **********************
# Global Configuration
# **********************
- name: RETENTION_DAYS
  value: {{ .Values.global.envs.retentionDays | default "90" | quote }}
- name: CHECK_TIMEOUT_MS
  value: {{ .Values.global.envs.checkTimeoutMs | default "10000" | quote }}
{{- end }}

{{/*
Create the secrets variable
*/}}
{{- define "status-page.global.secrets" -}}
- name: ADMIN_USERNAME
  valueFrom:
    secretKeyRef:
      name: credential
      key: ADMIN_USERNAME
- name: ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: credential
      key: ADMIN_PASSWORD
{{- end }}
