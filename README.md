# home-ops

GitOps for the homelab - featuring Proxmox, K3S and Argo CD.

## Repository Contents

- [`apps/`](./apps): Kubernetes manifests for application workloads (e.g., Immich, Jellyfin).
- [`clusters/`](./clusters): ArgoCD Application definitions for the cluster, using the App-of-Apps pattern.
- [`docs/`](./docs): Documentation files, including architecture diagrams and troubleshooting guides.
- [`helm/`](./helm): Helm charts for reusable configuration of Kubernetes applications.
- [`scripts/`](./scripts): Utility scripts for node bootstrap and one-off state migrations.
- [`terraform/`](./terraform): Modular Terraform code for provisioning infrastructure on various cloud providers or on-premises.

## Core Components

The homelab setup focuses on the following core components:

- [**Istio**](https://istio.io): An open-source service mesh that provides traffic management, security, and observability for microservices.
- [**cert-manager**](https://cert-manager.io): A native Kubernetes certificate management controller that helps with issuing and renewing TLS certificates from various issuing sources.
- [**ArgoCD**](https://argo-cd.readthedocs.io): GitOps tool for continuous delivery of Kubernetes resources.
- [**CloudNativePG**](https://cloudnative-pg.io): PostgreSQL operator for managing databases on Kubernetes.
- [**Proxmox VE**](https://www.proxmox.com): Virtualization platform hosting the Kubernetes cluster and other VMs.
- [**csi-driver-nfs**](https://github.com/kubernetes-csi/csi-driver-nfs): CSI driver for provisioning NFS volumes.
- [**Kiali**](https://kiali.io): Console for the Istio service mesh — topology graph, config validation and traffic health, backed by Prometheus and Grafana.

## Setup

### Terraform Provisioning

> Replace `terraform` with `tofu` if using OpenTofu.

In the [`terraform/`](./terraform) directory:

1. Create `backend.tfvars` to set the region, bucket, and key for remote state storage.
2. Create `terraform.tfvars` for all required variables (e.g., cloud provider credentials, cluster size, networking).
3. Initialize the backend with:
   ```bash
   terraform init -backend-config="./backend.tfvars"
   ```
4. Review the planned changes:
   ```bash
   terraform plan -var-file="./terraform.tfvars"
   ```
5. Apply the configuration:
   ```bash
   terraform apply -var-file="./terraform.tfvars"
   ```

### Bootstrapping K3S

K3S comes installed with Traefik by default which conflicts with Istio's ingress gateway because Traefik reserves the ingress ports for itself. To install K3S without Traefik:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s - --disable=traefik
```

Or if it's already installed, you can edit the systemctl service to start k3s with `--disable=traefik` then restart it:

```bash
sudo systemctl daemon-reload && sudo systemctl restart k3s
```

Copy the kubeconfig to use kubectl remotely:

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

## Observability

Kiali, Prometheus and Grafana are deployed by Argo CD alongside the rest of the
platform — there is nothing to install by hand:

| Argo CD Application | Source |
| --- | --- |
| `platform-kiali-operator` | `kiali/kiali-operator` Helm chart, namespace `kiali-operator` |
| `platform-prometheus` | Istio `samples/addons/prometheus.yaml` (`release-1.29`) |
| `platform-grafana` | Istio `samples/addons/grafana.yaml` (`release-1.29`) |
| `platform-observability` | [`apps/observability/`](./apps/observability) — the `Kiali` CR plus Gateways, VirtualServices and Certificates |

The operator chart is installed with `cr.create: false`; the `Kiali` custom
resource lives in [`apps/observability/kiali.yaml`](./apps/observability/kiali.yaml)
so it can be edited without a chart upgrade. Auth strategy is `anonymous`,
which is fine only because both consoles are reachable only from the home
network:

- <https://kiali.home.arpa>
- <https://grafana.home.arpa>

Both terminate TLS at the Istio ingress gateway using `home-ca-issuer`
certificates, the same as every other app in this repo.

Istio's sample Prometheus stores metrics in an `emptyDir`, so history is lost
whenever the pod restarts. That is deliberate — it keeps the addon a
zero-config drop-in — but it means Kiali graphs only cover the current pod's
lifetime.

Keep the `targetRevision` of `platform-prometheus` / `platform-grafana`
(`release-1.29`) in step with the istiod chart version in
`clusters/prod/platform-istiod.yaml`.
