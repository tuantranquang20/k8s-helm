{{/*
Expand the name of the chart.
*/}}
{{- define "lab5-handons.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lab5-handons.fullname" -}}
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
{{- define "lab5-handons.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lab5-handons.labels" -}}
helm.sh/chart: {{ include "lab5-handons.chart" . }}
{{ include "lab5-handons.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lab5-handons.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lab5-handons.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lab5-handons.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lab5-handons.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate database connection string
*/}}
{{- define "lab5-handons.databaseURL" -}}
{{- if .Values.database.enabled -}}
postgresql://{{ .Values.database.username }}:{{ .Values.database.password }}@{{ .Values.database.host }}:{{ .Values.database.port }}/{{ .Values.database.name }}
{{- else -}}
sqlite:///tmp/db.sqlite
{{- end -}}
{{- end -}}

{{/*
Generate Redis URL
*/}}
{{- define "lab5-handons.redisURL" -}}
{{- if .Values.redis.enabled -}}
redis://:{{ .Values.redis.password }}@{{ .Values.redis.host }}:{{ .Values.redis.port }}/0
{{- else -}}
redis://localhost:6379/0
{{- end -}}
{{- end -}}

{{/*
Calculate resource limits based on environment
*/}}
{{- define "lab5-handons.resourceLimits" -}}
{{- if eq .Values.app.environment "production" -}}
cpu: 500m
memory: 512Mi
{{- else if eq .Values.app.environment "staging" -}}
cpu: 250m
memory: 256Mi
{{- else -}}
cpu: 100m
memory: 128Mi
{{- end -}}
{{- end -}}

