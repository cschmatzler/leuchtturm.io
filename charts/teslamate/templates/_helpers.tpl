{{/* vim: set filetype=mustache: */}}
{{/*
Return the proper Teslamate image name
*/}}
{{- define "teslamate.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper Teslamate Docker Image Registry Secret Names
*/}}
{{- define "teslamate.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.metrics.image) "global" .Values.global) -}}
{{- end -}}
