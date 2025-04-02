{{/*
Expand the name of the chart.
*/}}
{{- define "platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "platform.fullname" -}}
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
{{- define "platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "platform.labels" -}}
helm.sh/chart: {{ include "platform.chart" . }}
{{ include "platform.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "platform.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "platform.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the configuration variables
*/}}
{{- define "platform.configuration" -}}
{{- range $service, $config := .Values.configuration }}
- name: {{ $service | upper }}_HOST
  value: {{ $config.host | quote }}
- name: {{ $service | upper }}_API_PORT
  value: {{ $config.api | default "80" | quote }}
- name: {{ $service | upper }}_GRPC_PORT
  value: {{ $config.grpc | default "8080" | quote }}
{{- end }}
{{- end }}

{{/*
Create the environments variable
*/}}
{{- define "platform.environments" -}}
# **********************
# Global Configuration
# **********************
- name: NODE_ENV
  value: {{ .Values.environments.nodeEnv | default "develop" | quote }}
- name: DEBUG
  value: {{ .Values.environments.debug | default "wnx:*" | quote }}
- name: TIMEOUT
  value: {{ .Values.environments.timeout | default "90000" | quote }}
# **********************
# Internationalization
# **********************
- name: LOCALE
  value: {{ .Values.environments.locale | default "fa" | quote }}
- name: REGION
  value: {{ .Values.environments.region | default "IR" | quote }}
- name: TZ
  value: {{ .Values.environments.tz | default "Asia/Tehran" | quote }}
# **********************
# Storage Services
# **********************
# Redis
- name: REDIS_HOST
  value: {{ .Values.environments.redis.host | quote }}
- name: REDIS_PORT
  value: {{ .Values.environments.redis.port | default "6379" | quote }}
- name: REDIS_PREFIX
  value: {{ .Values.environments.redis.prefix | default "wnx" | quote }}
- name: REDIS_PASSWORD
  value: {{ .Values.environments.redis.password | quote }}
# Minio
- name: MINIO_HOST
  value: {{ .Values.environments.minio.host | quote }}
- name: MINIO_PORT
  value: {{ .Values.environments.minio.port | default "80" | quote }}
- name: MINIO_ACCESS_KEY
  value: {{ .Values.environments.minio.accessKey | quote }}
- name: MINIO_SECRET_KEY
  value: {{ .Values.environments.minio.secretKey | quote }}
# Mongo
- name: MONGO_HOST
  value: {{ .Values.environments.mongo.host | quote }}
- name: MONGO_DB
  value: {{ .Values.environments.mongo.db | default "wenex" | quote }}
- name: MONGO_PREFIX
  value: {{ .Values.environments.mongo.prefix | default "wnx" | quote }}
- name: MONGO_USER
  value: {{ .Values.environments.mongo.user | quote }}
- name: MONGO_PASS
  value: {{ .Values.environments.mongo.pass | quote }}
- name: MONGO_QUERY
  value: {{ .Values.environments.mongo.query | default "replicaSet=rs0&authSource=admin" | quote }}
# **********************
# Broker Services
# **********************
# Kafka
- name: KAFKA_HOST
  value: {{ .Values.environments.kafka.host | quote }}
- name: KAFKA_PORT
  value: {{ .Values.environments.kafka.port | default "9092" | quote }}
# EMQX
- name: EMQX_USERNAME
  value: {{ .Values.environments.emqx.username | quote }}
- name: EMQX_PASSWORD
  value: {{ .Values.environments.emqx.password | quote }}
- name: EMQX_EXHOOK_URL
  value: {{ .Values.environments.emqx.exhookUrl | default "http://platform-preserver.wenex-platform.svc.cluster.local:8080" | quote }}
- name: EMQX_BASE_URL
  value: {{ .Values.environments.emqx.baseUrl | default "http://emqx-dashboard.emqx-operator-system.svc.cluster.local:18083/api/v5" | quote }}
{{- end }}
