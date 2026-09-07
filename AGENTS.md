# home-ops

GitOps repo for a home Kubernetes lab: Proxmox VMs -> K3s -> Argo CD (App-of-Apps)
-> Istio service mesh. Terraform provisions the "platform" layer (namespaces +
Helm releases for Istio, cert-manager, CNPG, csi-driver-nfs, Argo CD); Argo CD
then syncs everything under `clusters/` and `apps/` from this git repo. There
is no application source code here — only Kubernetes manifests, Helm values,
Terraform, and shell scripts.

## Layout

- `terraform/` — provisions the platform layer via `module.bootstrap`
  (`terraform/modules/bootstrap/main.tf`): namespaces + `helm_release`
  resources for Istio (base/istiod/ingress), cert-manager, CNPG, csi-driver-nfs,
  and Argo CD itself.
- `clusters/prod/` — one Argo CD `Application` YAML per addon/app (e.g.
  `platform-istiod.yaml`, `jellyfin.yaml`). `clusters/app-of-apps.yaml` is the
  root Application that syncs everything in `clusters/prod` — this is the only
  thing you apply manually to bootstrap Argo CD.
- `apps/<name>/` — raw manifests per application (namespace.yaml, pvc.yaml,
  ingress.yaml, certificate.yaml, database.yaml, kustomization.yaml). Wired
  together by `apps/<name>/kustomization.yaml`. Some Argo CD Applications
  (e.g. `jellyfin.yaml`) use multiple `sources:` — one pointing at `apps/<name>`
  in this repo, one at the upstream Helm chart, with inline `helm.values`.
- `helm/istio-config/` — a local Helm chart (Gateway, VirtualService,
  ServiceEntry, AuthorizationPolicy, Certificate templates) for Istio routing
  config, not for an application itself.
- `scripts/` — operational shell scripts, run manually (not CI), see below.
- `apps/observability/` — the mesh observability layer that lands in
  `istio-system`: the `Kiali` CR (the operator chart is installed with
  `cr.create: false`), plus Gateway/VirtualService/Certificate for
  `kiali.home.arpa` and `grafana.home.arpa`.
- `docs/` — troubleshooting.md, nfs-setup.md, roadmap.md.

## Dev environment / tools

No package manager, no build step, no test suite — this is a pure
infra-as-code repo. Tools needed: `terraform` (or `tofu`), `kubectl`, `helm`,
`ssh` access to the k3s nodes.

## Common commands

Terraform (run from `terraform/`):
```bash
terraform init -backend-config="./backend.tfvars"
terraform plan -var-file="./terraform.tfvars"
terraform apply -var-file="./terraform.tfvars"
```
Both `backend.tfvars` and `terraform.tfvars` are untracked local files you
must create yourself (see README for what they need).

Bootstrap a new k3s node without Traefik (Istio owns ingress):
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s - --disable=traefik
```
Join a worker (`scripts/bootstrap-k3s.sh`, needs `K3S_TOKEN` env var from the
master's `/var/lib/rancher/k3s/server/token`).

Patch out orphaned Terraform-managed platform resources so Argo CD can own
them instead (`scripts/fix-platform-addon-state.sh`, run from `scripts/`,
dry-run by default, pass `--apply` to actually run `terraform state rm`).

Update all cluster nodes over SSH: `scripts/update-nodes.sh` (hardcoded host
aliases: k3s-master, k3s-worker-1, k3s-worker-2, srv-1 — needs SSH config/keys
already set up).

Hand off the previously hand-installed observability stack to Argo CD
(`scripts/fix-observability-state.sh`, dry-run by default, pass `--apply`).
One-time migration only — it uninstalls the manual `kiali-operator` Helm
release so `platform-kiali-operator` can own it.

Bootstrap Argo CD itself (once the platform Helm release exists):
```bash
kubectl apply -f clusters/app-of-apps.yaml
```
After that, everything under `clusters/prod` and `apps/` syncs automatically
(`selfHeal: true`, `prune: true`) — do not `kubectl apply` individual app
manifests by hand, edit the YAML and let Argo CD sync it.

## Conventions

- Every deployable thing has a matching Argo CD `Application` in
  `clusters/prod/<name>.yaml`, named `platform-*.yaml` for
  Terraform-adjacent/infra addons vs plain `<name>.yaml` for user apps
  (jellyfin, jellyseerr, immich).
- Per-app manifest dirs under `apps/<name>/` follow a consistent file split:
  `namespace.yaml`, `pvc.yaml`/`storageclass.yaml`, `certificate.yaml`,
  `ingress.yaml`, `database.yaml` where relevant — wired via
  `kustomization.yaml`.
- Databases are CloudNativePG `Cluster` + `Database` CRs (see
  `apps/immich/database.yaml`), not raw StatefulSets.
- Ingress/TLS go through cert-manager `Certificate` + Istio `Gateway`, not
  plain Kubernetes Ingress objects, except where noted (e.g. jellyseerr).
- Terraform locals define chart repos/versions once (`local.argocd_repo`,
  `local.argocd_version` etc. in the bootstrap module) rather than inlining
  them per resource.
- Platform Applications carry `argocd.argoproj.io/sync-wave` annotations to
  order the bootstrap: istio-base/cnpg `1`, istiod `2`, istio-ingress `3`,
  kiali-operator/prometheus/grafana `4`, observability (the `Kiali` CR, which
  needs the operator's CRD) `5`. Anything without an annotation is wave `0`.

## Pitfalls

- `terraform/backend.tfvars` and `terraform/terraform.tfvars` contain live AWS
  credentials and are checked into this working tree — never print, log, or
  quote their contents; treat them as secrets.
- K3s ships with Traefik enabled by default, which fights Istio for ingress
  ports; always bootstrap/re-verify `--disable=traefik`.
- Argo CD apps have `selfHeal: true` + `prune: true` — manual `kubectl edit`
  on synced resources gets reverted on the next sync; change the source YAML
  instead.
- Immich's Postgres user needs `ALTER USER app WITH SUPERUSER;` after first
  creation (already baked into `apps/immich/database.yaml`'s
  `postInitApplicationSQL`, but re-apply manually if the DB was created
  another way — see `docs/troubleshooting.md`).
- Prometheus and Grafana come from Istio's `samples/addons` (Argo CD points
  straight at `github.com/istio/istio`, path `samples/addons`, with
  `directory.include` picking one file). Their `targetRevision`
  (`release-1.29`) must track the istiod chart version — bump both together.
  The sample Prometheus uses an `emptyDir`, so metrics do not survive a pod
  restart.
- Kiali auth is `strategy: anonymous`. That is only safe because the mesh
  console is exposed solely on `kiali.home.arpa` behind the home-network
  ingress gateway; do not expose it externally without changing this.
- Immich's PVC can get stuck on delete; clear finalizers per
  `docs/troubleshooting.md` (`kubectl patch pvc -n immich immich-pvc -p
  '{"metadata":{"finalizers":null}}'`).
