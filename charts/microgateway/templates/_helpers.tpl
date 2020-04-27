{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "microgateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "microgateway.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "microgateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "microgateway.labels" -}}
helm.sh/chart: {{ include "microgateway.chart" . }}
{{ include "microgateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels}}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "microgateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "microgateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Return true if a secret object should be created
*/}}
{{- define "microgateway.createSecret" -}}
{{- if not .Values.config.existingSecret -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the secret name
*/}}
{{- define "microgateway.secretName" -}}
{{- if and .Values.config.passphrase .Values.config.existingSecret }}
  {{- fail "Please either specify an existing secret or the passphrase itself" }}
{{- end }}
{{- if and .Values.config.license .Values.config.existingSecret }}
  {{- fail "Please either specify an existing secret or the license itself" }}
{{- end }}
{{- if .Values.config.existingSecret }}
  {{- printf "%s" .Values.config.existingSecret -}}
{{- else -}}
  {{- printf "%s" (include "microgateway.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if apache expert settings should be created
*/}}
{{- define "microgateway.apacheExpertSettings" -}}
{{- if or .Values.config.expert.apache .Values.config.IPHeader.trustedProxies .Values.config.default.virtualHost.tls.protocol .Values.config.default.virtualHost.tls.cipherSuite -}}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if securityGate expert settings should be created
*/}}
{{- define "microgateway.securityGateExpertSettings" -}}
{{- if or .Values.config.expert.security_gate .Values.config.default.backend.tls.serverCa .Values.config.default.backend.tls.clientCert .Values.config.default.backend.tls.verifyHost .Values.config.default.backend.tls.version .Values.config.default.backend.tls.cipherSuite .Values.config.default.backend.tls.cipherSuitev13 -}}
  {{- true -}}
{{- end -}}
{{- end -}}