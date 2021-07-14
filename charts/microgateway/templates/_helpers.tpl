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
Get the passphrase secret name
*/}}
{{- define "microgateway.passphraseSecretName" -}}

{{- if .Values.config.passphrase.useExistingSecret }}
  {{- if not .Values.config.passphrase.secretName }}
    {{- fail "Value 'config.passphrase.secretName' is required to mount external passphrase secret." }}
  {{- end -}}
  {{- printf "%s" .Values.config.passphrase.secretName -}}
{{- else -}}
  {{- printf "%s" (include "microgateway.fullname" .) -}}-passphrase
{{- end -}}
{{- end -}}

{{/*
Get the license secret name
*/}}
{{- define "microgateway.licenseSecretName" -}}

{{- if .Values.config.license.useExistingSecret }}
  {{- if not .Values.config.license.secretName }}
    {{- fail "Value 'config.license.secretName' is required to mount external license secret." }}
  {{- end -}}
  {{- printf "%s" .Values.config.license.secretName -}}
{{- else -}}
  {{- printf "%s" (include "microgateway.fullname" .) -}}-license
{{- end -}}
{{- end -}}

{{/*
Returns true if a licence secret should be created
*/}}
{{- define "microgateway.createLicenseSecret" -}}

{{- if and (not .Values.config.license.useExistingSecret) .Values.config.license.key }}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/*
return true if license secret should be mounted
*/}}
{{- define "microgateway.mountLicense" -}}

{{- if .Values.config.license.useExistingSecret }}
  {{- true -}}
{{- else if .Values.config.license.key -}}  
  {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Create imagePullSecret
*/}}
{{- define "imagePullSecret" }}
{{- if .Values.imageCredentials.enabled }}
  {{- printf "{\"auths\": {\"%s\": {\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" .Values.imageCredentials.registry .Values.imageCredentials.username .Values.imageCredentials.password (printf "%s:%s" .Values.imageCredentials.username .Values.imageCredentials.password | b64enc) | b64enc }}
{{- end -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "microgateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "microgateway.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
