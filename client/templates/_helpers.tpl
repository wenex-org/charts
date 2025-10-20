{{/*
Expand the name of the chart.
*/}}
{{- define "client.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "client.fullname" -}}
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
{{- define "client.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "client.labels" -}}
helm.sh/chart: {{ include "client.chart" . }}
{{ include "client.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "client.selectorLabels" -}}
app.kubernetes.io/name: {{ include "client.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "client.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "client.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the configuration variables
*/}}
{{- define "client.global.configuration" -}}
{{- range $service, $config := .Values.global.configuration }}
- name: {{ $service | upper }}_HOST
  value: {{ $config.host | quote }}
- name: {{ $service | upper }}_API_PORT
  value: {{ $config.api | default "80" | quote }}
{{- end }}
{{- end }}

{{/*
Create the secrets variable
*/}}
{{- define "client.global.secrets" -}}
# **********************
# Application Secrets
# **********************
- name: AES_KEY
  valueFrom:
    secretKeyRef:
      name: client-secrets
      key: AES_KEY
# **********************
# Captcha Services
# **********************
# Altcha
- name: ALTCHA_HMAC_KEY
  valueFrom:
    secretKeyRef:
      name: client-secrets
      key: HMAC_KEY
# **********************
# Coworkers Secrets
# **********************
# PHC Client
- name: INIT_PHC_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: client-init-secrets
      key: INIT_PHC_ROOT_PASSWORD
- name: INIT_PHC_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: client-init-secrets
      key: INIT_PHC_CLIENT_SECRET
# RSCH Client
- name: INIT_RSCH_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: client-init-secrets
      key: INIT_RSCH_ROOT_PASSWORD
- name: INIT_RSCH_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: client-init-secrets
      key: INIT_RSCH_CLIENT_SECRET
# COPD Client
- name: INIT_COPD_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: client-init-secrets
      key: INIT_COPD_ROOT_PASSWORD
- name: INIT_COPD_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: client-init-secrets
      key: INIT_COPD_CLIENT_SECRET
{{- end }}

{{/*
Create the environments variable
*/}}
{{- define "client.global.environments" -}}
- name: APP_VERSION
  value: {{ .Values.global.image.tag | quote }}
# **********************
# Global Configuration
# **********************
- name: NODE_ENV
  value: {{ .Values.global.environments.nodeEnv | default "develop" | quote }}
- name: DEBUG
  value: {{ .Values.global.environments.debug | default "clt:*" | quote }}
- name: TIMEOUT
  value: {{ .Values.global.environments.timeout | default "90000" | quote }}
- name: GRAPHQL_MUTATION_SUPPORT
  value: {{ .Values.global.environments.graphqlMutationSupport | quote }}
# **********************
# Internationalization
# **********************
- name: LOCALE
  value: {{ .Values.global.environments.locale | default "fa" | quote }}
- name: REGION
  value: {{ .Values.global.environments.region | default "IR" | quote }}
- name: TZ
  value: {{ .Values.global.environments.tz | default "Asia/Tehran" | quote }}
# *****************************
# Messaging Config
# *****************************
# Kavenegar
- name: KAVENEGAR_SENDERS
  value: {{ .Values.global.environments.kavenegar.senders | quote }}
- name: KAVENEGAR_API_KEY
  value: {{ .Values.global.environments.kavenegar.apiKey | quote }}
# Melipayamak
- name: MELIPAYAMAK_USER
  value: {{ .Values.global.environments.melipayamak.user | quote }}
- name: MELIPAYAMAK_PASS
  value: {{ .Values.global.environments.melipayamak.pass | quote }}
- name: MELIPAYAMAK_FROM
  value: {{ .Values.global.environments.melipayamak.from | quote }}
# *****************************
# Client Config
# *****************************
- name: STRICT_TOKEN
  value: {{ .Values.global.environments.strictToken | default "true" | quote }}
# Client
- name: UID
  value: {{ .Values.global.environments.uid | quote }}
- name: CID
  value: {{ .Values.global.environments.cid | quote }}
- name: APP_ID
  value: {{ .Values.global.environments.appId | quote }}
- name: CLIENT_ID
  value: {{ .Values.global.environments.clientId | quote }}
- name: CLIENT_SECRET
  value: {{ .Values.global.environments.clientSecret | quote }}
# Platform
- name: ROOT_DOMAIN
  value: {{ .Values.global.environments.root.domain | default "wenex.org" | quote }}
- name: ROOT_SUBJECT
  value: {{ .Values.global.environments.root.subject | default "root@wenex.org" | quote }}
- name: PLATFORM_URL
  value: {{ .Values.global.environments.platformUrl | default "http://platform-gateway.wenex-platform.svc.cluster.local" | quote }}
# Backend
- name: CLIENT_AUTHORIZATION_CQRS
  value: {{ .Values.global.environments.backend.authorizationCqrs | quote }}
- name: API_KEY
  value: {{ .Values.global.environments.apiKey | quote }}
# Frontend
- name: CLIENT_BASE_URL
  value: {{ .Values.global.environments.frontend.baseUrl | default "https://platform.wenex.org" | quote }}
- name: CLIENT_ASSETS_URL
  value: {{ .Values.global.environments.frontend.assetsUrl | default "https://assets.wenex.org" | quote }}
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
  value: {{ .Values.global.environments.redis.prefix | default "clt" | quote }}
- name: REDIS_PASSWORD
  value: {{ .Values.global.environments.redis.password | quote }}
# Mongo
- name: MONGO_HOST
  value: {{ .Values.global.environments.mongo.host | quote }}
- name: MONGO_DB
  value: {{ .Values.global.environments.mongo.db | default "wenex" | quote }}
- name: MONGO_PREFIX
  value: {{ .Values.global.environments.mongo.prefix | default "clt" | quote }}
- name: MONGO_USER
  value: {{ .Values.global.environments.mongo.user | quote }}
- name: MONGO_PASS
  value: {{ .Values.global.environments.mongo.pass | quote }}
- name: MONGO_QUERY
  value: {{ .Values.global.environments.mongo.query | default "replicaSet=rs0&authSource=admin" | quote }}
# **********************
# Broker Services
# **********************
# Nats
- name: NATS_USER
  value: {{ .Values.global.environments.nats.user | default "w3x" | quote }}
- name: NATS_PASS
  value: {{ .Values.global.environments.nats.pass | default "w3x" | quote }}
- name: NATS_TIMEOUT
  value: {{ .Values.global.environments.nats.timeout | default "90000" | quote }}
- name: NATS_SERVERS
  value: {{ .Values.global.environments.nats.servers | default "nats://nats.nats.svc.cluster.local:4222" | quote }}
# *****************************
# OAuth Information
# *****************************
# Google
- name: GOOGLE_CLIENT_ID
  value: {{ .Values.global.environments.google.client.id | quote }}
- name: GOOGLE_CLIENT_SECRET
  value: {{ .Values.global.environments.google.client.secret | quote }}
- name: GOOGLE_REDIRECT_URI
  value: {{ .Values.global.environments.google.client.redirectUri | default "https://platform.wenex.org/oauth" | quote }}
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
# Wenex Coworkers
# **********************
- name: COWORKERS
  value: {{ .Values.global.environments.coworkers | toJson | quote }}
{{- end }}
