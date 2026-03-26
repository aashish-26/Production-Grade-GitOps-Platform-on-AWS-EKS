{{- define "worker-service.name" -}}worker-service{{- end -}}
{{- define "worker-service.fullname" -}}{{ include "worker-service.name" . }}-{{ .Release.Name }}{{- end -}}
