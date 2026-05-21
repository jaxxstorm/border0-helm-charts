# tailzero-connector

Helm chart to deploy the Tailzero Connector

## Installation

Add this Helm repository:

```bash
helm repo add border0 https://borderzero.github.io/helm-charts
helm repo update
```

Get an invite code from the Border0 admin portal connectors page, then:

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.inviteCode="YOUR_INVITE_CODE_HERE"
```

The connector will exchange the invite code for credentials (connector token + Tailscale auth key)
and persist them in a Kubernetes secret automatically. On restart, credentials are loaded from
the secret — no re-exchange needed.

## Advanced Configuration

### Custom Container Image

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.inviteCode="YOUR_INVITE_CODE" \
  --set image.override="ghcr.io/borderzero/tailzero:dev"
```

### Custom Hostname

By default the connector uses the Helm release name as its hostname. Override it with:

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.inviteCode="YOUR_INVITE_CODE" \
  --set config.hostname="my-connector"
```

### RBAC Modes

The chart supports two RBAC modes for cluster-level permissions:

#### api-admin (default)
Full cluster access + impersonation, required for Kubernetes API proxying through tailzero.

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.inviteCode="YOUR_INVITE_CODE" \
  --set rbac.clusterRoleMode="api-admin"
```

#### none
No ClusterRole created. Use this when you don't need Kubernetes API proxying.

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.inviteCode="YOUR_INVITE_CODE" \
  --set rbac.clusterRoleMode="none"
```

**Note:** A namespaced Role for credential secret management is always created regardless of `clusterRoleMode`.

### Custom Namespace

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.inviteCode="YOUR_INVITE_CODE" \
  --namespace "YOUR_CUSTOM_NS" --create-namespace
```

## Upgrading

### When Using `image.tag: latest` (Default)

Restart the deployment to pull the latest image:

```bash
kubectl --namespace "YOUR_NS" rollout restart deployment tailzero-connector
```

### When Using a Specific Image Tag

```bash
helm upgrade tailzero-connector border0/tailzero-connector \
  --namespace "YOUR_NS" \
  --reuse-values \
  --set image.tag="v1.2.3"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `config.inviteCode` | string | `""` | Invite code from the Border0 portal (required) |
| `config.hostname` | string | `""` | Connector hostname (defaults to release name) |
| `image.repository` | string | `"ghcr.io/borderzero/tailzero"` | Container image repository |
| `image.tag` | string | `"latest"` | Container image tag |
| `image.pullPolicy` | string | `"Always"` | Image pull policy |
| `image.override` | string | `null` | Override the full image reference |
| `serviceAccount.name` | string | `""` | Service account name (auto-generated if empty) |
| `rbac.clusterRoleMode` | string | `"api-admin"` | ClusterRole mode: `"api-admin"` or `"none"` |
| `rbac.name` | string | `""` | ClusterRole name (auto-generated if empty) |
| `serviceAccount.annotations` | object | `{}` | Annotations to add to the ServiceAccount (e.g. for AWS IRSA, GCP Workload Identity, Azure Workload Identity) |
| `extraEnv` | list | `[]` | Extra environment variables for the connector container (standard k8s env schema) |
| `extraVolumes` | list | `[]` | Extra volumes attached to the pod |
| `extraVolumeMounts` | list | `[]` | Extra volume mounts on the connector container |
