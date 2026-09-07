#!/usr/bin/env bash
set -euo pipefail

# One-time handoff of the hand-installed observability stack to Argo CD.
#
# scripts/observability.sh used to install Kiali (via `helm install
# kiali-operator`) and Istio's Prometheus/Grafana sample addons (via
# `kubectl apply -f <raw github url>`) by hand. That stack is now codified:
#
#   clusters/prod/platform-kiali-operator.yaml  -> kiali/kiali-operator chart
#   clusters/prod/platform-prometheus.yaml      -> istio samples/addons
#   clusters/prod/platform-grafana.yaml         -> istio samples/addons
#   clusters/prod/platform-observability.yaml   -> apps/observability
#
# Prometheus and Grafana are adopted by Argo CD in place (same names, same
# namespace) and need nothing here. The Kiali operator does: its Helm release
# owns a Kiali CR that apps/observability/kiali.yaml now owns instead, so the
# manual release has to go before Argo CD installs its own.
#
# Dry-run by default; pass --apply to actually run the commands.

APPLY=${1:-0}

RELEASE_NAME=kiali-operator
RELEASE_NS=kiali-operator

run() {
  if [[ "$APPLY" = "--apply" ]]; then
    echo "+ $*"
    "$@"
  else
    echo "would run: $*"
  fi
}

if helm status "$RELEASE_NAME" -n "$RELEASE_NS" >/dev/null 2>&1; then
  echo "Found hand-installed Helm release $RELEASE_NS/$RELEASE_NAME."
  echo "Uninstalling it also removes its Kiali CR, so the Kiali console is"
  echo "down until Argo CD syncs platform-kiali-operator and"
  echo "platform-observability. The kialis.kiali.io CRD is not removed."
  run helm uninstall "$RELEASE_NAME" -n "$RELEASE_NS"
else
  echo "No hand-installed Helm release $RELEASE_NS/$RELEASE_NAME — nothing to do."
fi

if [[ "$APPLY" != "--apply" ]]; then
  echo
  echo "Dry run. Re-run with --apply to execute."
fi
