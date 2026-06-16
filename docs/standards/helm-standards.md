# Helm Standards

Standards for Helm chart development, packaging, and deployment across the platform.

---

## Chart Structure

Every Helm chart must follow this standard structure:

```text
my-chart/
├── Chart.yaml
├── README.md
├── values.yaml
├── values-tst.yaml
├── values-acc.yaml
├── values-prd.yaml
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   ├── configmap.yaml
│   ├── ingress.yaml
│   ├── networkpolicy.yaml
│   ├── poddisruptionbudget.yaml
│   ├── servicemonitor.yaml
│   └── NOTES.txt
└── tests/
    └── test-connection.yaml
```

---

## Chart.yaml

```yaml
apiVersion: v2
name: my-application
description: A Helm chart for My Application.
type: application
version: 1.0.0
appVersion: "2.3.1"
maintainers:
  - name: Platform Engineering
    email: platform@example.com
keywords:
  - platform
  - my-application
sources:
  - https://github.com/example/my-application
```

### Version Policy

- `version` (chart version) and `appVersion` are independent — increment both explicitly.
- Follow SemVer for both.
- `appVersion` should reflect the application image tag.

---

## Values Files

### Environment Split

Never embed environment conditionals in a single `values.yaml`. Use environment-specific override files:

```
values.yaml         # Non-environment-specific defaults
values-tst.yaml     # Test environment overrides
values-acc.yaml     # Acceptance environment overrides
values-prd.yaml     # Production environment overrides
```

### values.yaml — Defaults Only

```yaml
replicaCount: 1

image:
  repository: registry.example.com/my-application
  tag: ""  # Set via appVersion or CI/CD
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70

podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL

monitoring:
  enabled: false
  serviceMonitor:
    enabled: false

networkPolicy:
  enabled: true
  ingress: []
  egress: []
```

### values-prd.yaml — Production Overrides

```yaml
replicaCount: 3

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10

monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
```

---

## Helpers Template

Use `_helpers.tpl` for all reusable template fragments:

```
{{/*
Expand the name of the chart.
*/}}
{{- define "my-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "my-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "my-chart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app: {{ include "my-chart.name" . }}
managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Selector labels used for pod selection.
*/}}
{{- define "my-chart.selectorLabels" -}}
app: {{ include "my-chart.name" . }}
release: {{ .Release.Name }}
{{- end }}
```

---

## Deployment Template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-chart.fullname" . }}
  labels:
    {{- include "my-chart.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "my-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "my-chart.selectorLabels" . | nindent 8 }}
    spec:
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: /ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

---

## Deployment Rules

| Rule | Detail |
|---|---|
| No `helm template \| kubectl apply` | Use ArgoCD or a GitOps controller in production |
| Pin image tags | Use `appVersion` or an explicit immutable tag — never `latest` |
| CRD upgrades | Apply CRDs before `helm upgrade`; document in release notes |
| Test before promote | Run `helm lint` and `helm template` in CI before deploying |
| Values review | Review values diff for every environment promotion |

---

## Linting

Every chart must pass `helm lint` with no warnings or errors:

```bash
helm lint charts/my-application/
helm lint charts/my-application/ -f charts/my-application/values-prd.yaml
```

---

## Scaling Considerations

- Use HPA for workloads with variable load; set both CPU and memory metrics.
- Use KEDA for event-driven scaling (queue depth, Kafka lag, etc.).
- Set `minReplicas >= 2` in production for availability during rolling updates.
- Combine HPA with PDB to ensure minimum availability during scale-down.
