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
{{- define "platform.global.configuration" -}}
{{- range $service, $config := .Values.global.configuration }}
- name: {{ $service | upper }}_HOST
  value: {{ $config.host | quote }}
- name: {{ $service | upper }}_API_PORT
  value: {{ $config.api | default "80" | quote }}
- name: {{ $service | upper }}_GRPC_PORT
  value: {{ $config.grpc | default "8080" | quote }}
{{- end }}
{{- end }}

{{/*
Create the secrets variable
*/}}
{{- define "platform.global.secrets" -}}
# **********************
# Initial Secrets
# **********************
- name: INIT_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: platform-init-secrets
      key: ROOT_PASSWORD
- name: INIT_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: platform-init-secrets
      key: CLIENT_SECRET
# **********************
# Application Secrets
# **********************
- name: AES_SECRET
  valueFrom:
    secretKeyRef:
      name: platform-secrets
      key: AES_SECRET
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: platform-secrets
      key: JWT_SECRET
- name: BCRYPT_SALT
  valueFrom:
    secretKeyRef:
      name: platform-secrets
      key: BCRYPT_SALT
{{- end }}

{{/*
Create the environments variable
*/}}
{{- define "platform.global.environments" -}}
- name: APP_VERSION
  value: {{ .Values.global.image.tag | quote }}
# **********************
# Global Configuration
# **********************
- name: NODE_ENV
  value: {{ .Values.global.environments.nodeEnv | default "develop" | quote }}
- name: DEBUG
  value: {{ .Values.global.environments.debug | default "wnx:*" | quote }}
- name: TIMEOUT
  value: {{ .Values.global.environments.timeout | default "90000" | quote }}
# **********************
# Internationalization
# **********************
- name: LOCALE
  value: {{ .Values.global.environments.locale | default "fa" | quote }}
- name: REGION
  value: {{ .Values.global.environments.region | default "IR" | quote }}
- name: TZ
  value: {{ .Values.global.environments.tz | default "Asia/Tehran" | quote }}
# **********************
# Logging Services
# **********************
# Sentry
- name: SENTRY_DSN
  value: {{ .Values.global.environments.sentry.dsn | quote }}
- name: SENTRY_MAX_BREADCRUMBS
  value: {{ .Values.global.environments.sentry.maxBreadcrumbs | default "100" | quote }}
- name: SENTRY_TRACES_SAMPLE_RATE
  value: {{ .Values.global.environments.sentry.tracesSampleRate | default "0.8" | quote }}
# **********************
# Storage Services
# **********************
# Redis
- name: REDIS_HOST
  value: {{ .Values.global.environments.redis.host | quote }}
- name: REDIS_PORT
  value: {{ .Values.global.environments.redis.port | default "6379" | quote }}
- name: REDIS_PREFIX
  value: {{ .Values.global.environments.redis.prefix | default "wnx" | quote }}
- name: REDIS_PASSWORD
  value: {{ .Values.global.environments.redis.password | quote }}
# Minio
- name: MINIO_HOST
  value: {{ .Values.global.environments.minio.host | quote }}
- name: MINIO_PORT
  value: {{ .Values.global.environments.minio.port | default "80" | quote }}
- name: MINIO_ACCESS_KEY
  value: {{ .Values.global.environments.minio.accessKey | quote }}
- name: MINIO_SECRET_KEY
  value: {{ .Values.global.environments.minio.secretKey | quote }}
# Mongo
- name: MONGO_HOST
  value: {{ .Values.global.environments.mongo.host | quote }}
- name: MONGO_DB
  value: {{ .Values.global.environments.mongo.db | default "wenex" | quote }}
- name: MONGO_PREFIX
  value: {{ .Values.global.environments.mongo.prefix | default "wnx" | quote }}
- name: MONGO_USER
  value: {{ .Values.global.environments.mongo.user | quote }}
- name: MONGO_PASS
  value: {{ .Values.global.environments.mongo.pass | quote }}
- name: MONGO_QUERY
  value: {{ .Values.global.environments.mongo.query | default "replicaSet=rs0&authSource=admin" | quote }}
- name: MONGO_LOAD_BALANCED
  value: {{ .Values.global.environments.mongo.loadBalanced | default "true" | quote }}
# PostgreSQL
- name: POSTGRES_DB
  value: {{ .Values.global.environments.postgres.db | default "wenex" | quote }}
- name: POSTGRES_PREFIX
  value: {{ .Values.global.environments.postgres.prefix | default "wnx" | quote }}
- name: POSTGRES_USER
  value: {{ .Values.global.environments.postgres.user | default "postgres" | quote }}
- name: POSTGRES_PASSWORD
  value: {{ .Values.global.environments.postgres.password | quote }}
- name: POSTGRES_PORT
  value: {{ .Values.global.environments.postgres.port | default "5432" | quote }}
- name: POSTGRES_HOST
  value: {{ .Values.global.environments.postgres.host | default "postgres-cluster-rw.cnpg-system.svc.cluster.local" | quote }}
# Elasticsearch
- name: ELASTIC_PREFIX
  value: {{ .Values.global.environments.elasticsearch.prefix | default "wnx" | quote }}
- name: ELASTICSEARCH_NODE
  value: {{ .Values.global.environments.elasticsearch.node | quote }}
- name: ELASTICSEARCH_API_KEY
  value: {{ .Values.global.environments.elasticsearch.apiKey | quote }}
- name: ELASTICSEARCH_USERNAME
  value: {{ .Values.global.environments.elasticsearch.username | quote }}
- name: ELASTICSEARCH_PASSWORD
  value: {{ .Values.global.environments.elasticsearch.password | quote }}
# **********************
# Broker Services
# **********************
# Kafka
- name: KAFKA_HOST
  value: {{ .Values.global.environments.kafka.host | quote }}
- name: KAFKA_PORT
  value: {{ .Values.global.environments.kafka.port | default "9092" | quote }}
- name: KAFKAJS_NO_PARTITIONER_WARNING
  value: {{ .Values.global.environments.kafka.noPartitionerWarning | default "1" | quote }}
# EMQX
- name: EMQX_USERNAME
  value: {{ .Values.global.environments.emqx.username | default "admin" | quote }}
- name: EMQX_PASSWORD
  value: {{ .Values.global.environments.emqx.password | quote }}
- name: EMQX_EXHOOK_URL
  value: {{ .Values.global.environments.emqx.exhookUrl | quote }}
- name: EMQX_BASE_URL
  value: {{ .Values.global.environments.emqx.baseUrl | quote }}
# **********************
# OpenStreetMap
# **********************
# Nominatim
- name: NOMINATIM_API_BASE_URL
  value: {{ .Values.global.environments.nominatim.apiBaseUrl | quote }}
# **********************
# TURN/STUN Server
# **********************
# Coturn
- name: COTURN_AUTH_SECRET
  value: {{ .Values.global.environments.coturn.authSecret | quote }}
- name: COTURN_ICE_SERVERS
  value: {{ .Values.global.environments.coturn.iceServers | join "," | default "turn.wenex.org" | quote }}
# **********************
# Telemetry Services
# **********************
# OpenTelemetry
- name: OTLP_PORT
  value: {{ .Values.global.environments.otlp.port | default "4318" | quote }}
- name: OTLP_HOST
  value: {{ .Values.global.environments.otlp.host | default "jaeger-instance-collector.opentelemetry.svc.cluster.local" | quote }}
# **********************
# APM Service
# **********************
# Elastic APM
- name: ELASTIC_APM_SERVER_URL
  value: {{ .Values.global.environments.apm.serverUrl | quote }}
- name: ELASTIC_APM_SECRET_TOKEN
  value: {{ .Values.global.environments.apm.secretToken | quote }}
- name: ELASTIC_APM_VERIFY_SERVER_CERT
  value: {{ .Values.global.environments.apm.verifyServerCert | default "false" | quote }}
# **********************
# Application Configs
# **********************
# Cleaner Worker
- name: CLEANER_AUDIT_LOGS_TTL
  value: {{ .Values.global.environments.cleaner.auditLogsTTL | default "4years" | quote }}
- name: CLEANER_STASH_LOGS_TTL
  value: {{ .Values.global.environments.cleaner.stashLogsTTL | default "100day" | quote }}
- name: CLEANER_SAGA_STAGES_TTL
  value: {{ .Values.global.environments.cleaner.sagaStagesTTL | default "1year" | quote }}
{{- end }}
