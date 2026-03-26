{{- define "api-service.name" -}}api-service{{- end -}}
{{- define "api-service.fullname" -}}{{ include "api-service.name" . }}-{{ .Release.Name }}{{- end -}}
