# Intel GPU plugin compatibility overlay

The upstream `devel` manifest gained `-prefix=/host` and `/host/dev` in
commit `2a5b9e590844889f5895807271e62f05ebd66766`. The cached live image
(`sha256:0f3c856b1ee31ccb8584d972b7720ff9273dc022e3efc156835ec356f1a67383`)
uses the older prefix semantics: prefix both devfs and sysfs, then return
that prefixed device path to kubelet. Adding `/host/sys` alone restores
discovery but makes containerd fail with `lstat /host/dev/dri/card1`.

Pin that exercised image and use native `/dev/dri` and `/sys` paths without
a prefix. Sysfs and DRM discovery mounts remain read-only; socket/CDI
mounts, selectors, resource limits and security context are retained.
The upstream manifest revision is pinned independently of its moving HEAD.

Validation (requires kubectl and PyYAML):

```sh
python scripts/test-intel-gpu-plugin.py
kubectl kustomize apps/intel-gpu-plugin | kubectl -n node-feature-discovery apply --dry-run=server -f -
```

Deployment changes only the GPU source (third source) of the existing
`platform-node-feature-discovery` Argo Application to this directory on
`fix/intel-gpu-sysfs`. Keep NFD chart/rules sources and sync settings unchanged.
Do not sync or redirect the root app-of-apps. The root remains on `main`
with automation disabled; a future manual root sync can overwrite this
branch pointer. Integrate the reviewed repair before returning to main.

Rollback: restore the third source to
`repoURL: https://github.com/intel/intel-device-plugins-for-kubernetes`,
`path: deployments/gpu_plugin/overlays/nfd_labeled_nodes`, with no
`targetRevision`, retaining the other sources and syncPolicy. This restores
the original tracking configuration, NOT a healthy GPU deployment. Prefer
reverting a bad follow-up commit on the authorized branch. Do not delete
PVCs or disable Jellyfin's GPU request. Existing failed pod allocations may
need a normal pod recreation after the plugin rollout; never force-delete.

The legacy binary also reuses existing CDI entries without comparing their
contents (`pkg/deviceplugin/server.go`, `writeCdiSpecToFilesystem`). During
migration, `/var/run/cdi/intel.cdi.k8s.io-gpu-card1.yaml` still contained
`/host/dev/dri/*`. Back up and remove only that proven-stale generated file
on the GPU node, then recreate the failed Jellyfin pod normally so Allocate
regenerates it. Verify regenerated host paths are `/dev/dri/*`. This is a
one-time runtime-cache cleanup, not an application data or PVC change.
A temporary restricted maintenance pod mounting only `/var/run/cdi` was
removed after verification. Do not restore the broken CDI cache on rollback.
