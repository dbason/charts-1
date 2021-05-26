{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "logging-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "logging-operator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Provides the namespace the chart will be installed in using the builtin .Release.Namespace,
or, if provided, a manually overwritten namespace value.
*/}}
{{- define "logging-operator.namespace" -}}
{{- if .Values.namespaceOverride -}}
{{ .Values.namespaceOverride -}}
{{- else -}}
{{ .Release.Namespace }}
{{- end -}}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "logging-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "logging-operator.labels" -}}
app.kubernetes.io/name: {{ include "logging-operator.name" . }}
helm.sh/chart: {{ include "logging-operator.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "system_default_registry" -}}
{{- if .Values.global.cattle.systemDefaultRegistry -}}
{{- printf "%s/" .Values.global.cattle.systemDefaultRegistry -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{- define "windowsEnabled" }}
  {{- if not (kindIs "invalid" .Values.global.cattle.windows) }}
  {{- if not (kindIs "invalid" .Values.global.cattle.windows.enabled) }}
  {{- if .Values.global.cattle.windows.enabled }}
true
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}

{{/*
Set the controlplane selector based on kubernetes distribution
*/}}
{{- define "controlplaneSelector" -}}
{{- $master := or .Values.additionalLoggingSources.rke2.enabled .Values.additionalLoggingSources.k3s.enabled -}}
{{- $defaultSelector := $master | ternary (dict "node-role.kubernetes.io/master" "true") (dict "node-role.kubernetes.io/controlplane" "true") -}}
{{ default $defaultSelector .Values.additionalLoggingSources.kubeAudit.nodeSelector | toYaml }}
{{- end -}}

{{/*
Set kube-audit file path prefix based on distribution
*/}}
{{- define "kubeAuditPathPrefix" -}}
{{- if .Values.additionalLoggingSources.rke.enabled -}}
{{ default "/var/log/kube-audit" .Values.additionalLoggingSources.kubeAudit.pathPrefix }}
{{- else if .Values.additionalLoggingSources.rke2.enabled -}}
{{ default "/var/lib/rancher/rke2/server/logs" .Values.additionalLoggingSources.kubeAudit.pathPrefix }}
{{- else -}}
{{ required "Directory PathPrefix of the kube-audit location is required" .Values.additionalLoggingSources.kubeAudit.pathPrefix }}
{{- end -}}
{{- end -}}

{{/*
Set kube-audit file name based on distribution
*/}}
{{- define "kubeAuditFilename" -}}
{{- if .Values.additionalLoggingSources.rke.enabled -}}
{{ default "audit-log.json" .Values.additionalLoggingSources.kubeAudit.auditFilename }}
{{- else if .Values.additionalLoggingSources.rke2.enabled -}}
{{ default "audit.log" .Values.additionalLoggingSources.kubeAudit.auditFilename }}
{{- else -}}
{{ required "Filename of the kube-audit log is required" .Values.additionalLoggingSources.kubeAudit.auditFilename }}
{{- end -}}
{{- end -}}