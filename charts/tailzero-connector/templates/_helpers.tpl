{{/*
Expand the name of the chart.
*/}}
{{- define "tailzero-connector.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tailzero-connector.fullname" -}}
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
{{- define "tailzero-connector.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tailzero-connector.labels" -}}
helm.sh/chart: {{ include "tailzero-connector.chart" . }}
{{ include "tailzero-connector.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tailzero-connector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tailzero-connector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate the name of the service account to use
*/}}
{{- define "tailzero-connector.generatedServiceAccountName" -}}
{{- if ne .Values.serviceAccount.name "" }}
{{- .Values.serviceAccount.name }}
{{- else }}
{{- include "tailzero-connector.fullname" . }}
{{- end }}
{{- end }}

{{/*
Generate the name of the cluster role to use
*/}}
{{- define "tailzero-connector.generatedClusterRoleName" -}}
{{- if ne .Values.rbac.name "" }}
{{- .Values.rbac.name }}
{{- else }}
{{- include "tailzero-connector.fullname" . }}
{{- end }}
{{- end }}

{{/*
Generate the name of the role to use for secret management
*/}}
{{- define "tailzero-connector.generatedRoleName" -}}
{{- include "tailzero-connector.fullname" . }}-secret-manager
{{- end }}

{{/*
Generate the name of the Kubernetes secret used for credential caching
*/}}
{{- define "tailzero-connector.generatedSecretName" -}}
{{- include "tailzero-connector.fullname" . }}-credentials
{{- end }}

{{/*
Resolve the Kubernetes namespace used for invite-code credential caching.
*/}}
{{- define "tailzero-connector.cacheK8sNamespace" -}}
{{- if .Values.config.cache.k8s.namespace }}
{{- .Values.config.cache.k8s.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Resolve the Kubernetes secret name used for invite-code credential caching.
*/}}
{{- define "tailzero-connector.cacheK8sSecretName" -}}
{{- if .Values.config.cache.k8s.secretName }}
{{- .Values.config.cache.k8s.secretName }}
{{- else }}
{{- include "tailzero-connector.generatedSecretName" . }}
{{- end }}
{{- end }}

{{/*
Check if ClusterRole should be created based on rbac.clusterRoleMode.
Returns "true" only if mode is "api-admin".
*/}}
{{- define "tailzero-connector.shouldCreateClusterRole" -}}
{{- $mode := .Values.rbac.clusterRoleMode | toString | trim -}}
{{- if eq $mode "api-admin" -}}
true
{{- end -}}
{{- end }}
