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

You can also deploy with an existing Border0 connector token. When using a token directly,
provide either a Tailscale auth key or Tailscale identity federation credentials:

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.token="YOUR_CONNECTOR_TOKEN" \
  --set config.tsAuthKey="YOUR_TAILSCALE_AUTH_KEY"
```

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

### Tailscale Control Plane

Use `config.tsControlUrl` for self-hosted deployments:

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.inviteCode="YOUR_INVITE_CODE" \
  --set config.tsControlUrl="https://headscale.example.com"
```

### Tailscale Identity Federation

When using `config.token` without `config.tsAuthKey`, provide both identity federation values:

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.token="YOUR_CONNECTOR_TOKEN" \
  --set config.tsIdFedClientId="YOUR_CLIENT_ID" \
  --set config.tsIdFedToken="YOUR_IDENTITY_FEDERATION_TOKEN"
```

### Credential Cache

Invite-code installs use a Kubernetes Secret cache by default. Override the cache location with:

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.inviteCode="YOUR_INVITE_CODE" \
  --set config.cache.k8s.namespace="tailzero-cache" \
  --set config.cache.k8s.secretName="tailzero-credentials"
```

Or use AWS SSM Parameter Store instead:

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.inviteCode="YOUR_INVITE_CODE" \
  --set config.cache.ssmPath="/border0/tailzero/connector"
```

### Startup Env File Directory

Mount credential or secret env files and point the connector at them with `config.configDir`:

```bash
helm install tailzero-connector border0/tailzero-connector \
  --set config.inviteCode="YOUR_INVITE_CODE" \
  --set config.configDir="/etc/tailzero/config" \
  --set extraVolumes[0].name="tailzero-config" \
  --set extraVolumes[0].secret.secretName="tailzero-config" \
  --set extraVolumeMounts[0].name="tailzero-config" \
  --set extraVolumeMounts[0].mountPath="/etc/tailzero/config"
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
| `config.token` | string | `""` | Border0 connector token. Required unless `config.inviteCode` is set |
| `config.inviteCode` | string | `""` | Invite code from the Border0 portal. Required unless `config.token` is set |
| `config.hostname` | string | `""` | Connector hostname (defaults to release name) |
| `config.stateDir` | string | `"/var/lib/tailzero"` | Directory for Tailscale state |
| `config.configDir` | string | `""` | Directory containing credential and secret env files loaded at startup |
| `config.tsAuthKey` | string | `""` | Tailscale auth key. Required when using `config.token` unless identity federation credentials are set |
| `config.tsControlUrl` | string | `""` | Tailscale coordination server URL. Leave empty for the public Tailscale control plane |
| `config.tsIdFedClientId` | string | `""` | Tailscale identity federation client ID |
| `config.tsIdFedToken` | string | `""` | Tailscale identity federation token |
| `config.tsVaultUrl` | string | `""` | TsVault URL for recording uploads |
| `config.cache.k8s.namespace` | string | `""` | Kubernetes namespace for invite-code credential caching (defaults to release namespace) |
| `config.cache.k8s.secretName` | string | `""` | Kubernetes secret name for invite-code credential caching (defaults to a generated release-specific name) |
| `config.cache.ssmPath` | string | `""` | AWS SSM Parameter Store path for invite-code credential caching. When set, SSM caching is used instead of Kubernetes secret caching |
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
