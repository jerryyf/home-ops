#!/usr/bin/env bash
set -euo pipefail

cd ../terraform

ADDRESSES=(
  module.bootstrap.kubernetes_namespace_v1.istio_system
  module.bootstrap.kubernetes_namespace_v1.istio_config
  module.bootstrap.helm_release.istio_base
  module.bootstrap.helm_release.istiod
  module.bootstrap.kubernetes_namespace_v1.istio_ingress
  module.bootstrap.helm_release.istio_ingress
  module.bootstrap.kubernetes_namespace_v1.cnpg_system
  module.bootstrap.helm_release.cnpg
  module.bootstrap.helm_release.csi_driver_nfs
  module.bootstrap.kubernetes_namespace_v1.cert_manager
  module.bootstrap.helm_release.cert_manager
)

FOUND=()

for addr in "${ADDRESSES[@]}"; do
  if terraform state show "$addr" >/dev/null 2>&1; then
    FOUND+=("$addr")
  fi
done

if [[ ${#FOUND[@]} -eq 0 ]]; then
  echo "Nothing to remove."
else
  echo "Targets in state:"
  for addr in "${FOUND[@]}"; do
    echo "  - $addr"
  done

  if [[ "$1" = "--apply" ]]; then
    for addr in "${FOUND[@]}"; do
      echo "Removing: $addr"
      terraform state rm "$addr"
    done
    echo "State removals complete."
  else
    echo "Dry-run only. Re-run with --apply to remove these addresses."
  fi
fi

