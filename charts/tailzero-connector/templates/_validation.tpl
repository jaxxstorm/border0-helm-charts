{{/*
Validate connector authentication config.
*/}}
{{- define "tailzero-connector.validateConfig" -}}
{{- $inviteCode := .Values.config.inviteCode | toString | trim -}}
{{- $token := .Values.config.token | toString | trim -}}
{{- $tsAuthKey := .Values.config.tsAuthKey | toString | trim -}}
{{- $tsIdFedClientId := .Values.config.tsIdFedClientId | toString | trim -}}
{{- $tsIdFedToken := .Values.config.tsIdFedToken | toString | trim -}}
{{- $stateDir := .Values.config.stateDir | toString | trim -}}
{{- if and (eq $inviteCode "") (eq $token "") -}}
{{- fail "one of config.inviteCode or config.token is required" -}}
{{- end -}}
{{- if and (ne $inviteCode "") (ne $token "") -}}
{{- fail "only one of config.inviteCode or config.token may be set" -}}
{{- end -}}
{{- if and (ne $token "") (eq $inviteCode "") (eq $tsAuthKey "") (or (eq $tsIdFedClientId "") (eq $tsIdFedToken "")) -}}
{{- fail "config.tsAuthKey or both config.tsIdFedClientId and config.tsIdFedToken are required when config.token is set without config.inviteCode" -}}
{{- end -}}
{{- if eq $stateDir "" -}}
{{- fail "config.stateDir is required" -}}
{{- end -}}
{{- end }}

{{/*
Validate rbac.clusterRoleMode value.
Only accepts "api-admin" or "none". Fails on any other value.
*/}}
{{- define "tailzero-connector.validateRbacMode" -}}
{{- $mode := .Values.rbac.clusterRoleMode | toString | trim -}}
{{- if and (ne $mode "api-admin") (ne $mode "none") -}}
{{- fail (printf "rbac.clusterRoleMode must be either \"api-admin\" or \"none\", got: %q" $mode) -}}
{{- end -}}
{{- end }}
