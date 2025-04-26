#!/bin/bash
# General script to deploy istio, cert-manager, immich on a fresh k3s cluster

set -e

# check env vars
if [ "$IMMICH_HOSTNAME" == "" ]; then
  echo "IMICH_HOSTNAME is not set"
  exit 1
fi
if [ "$NFS_SERVER" == "" ]; then
  echo "NFS_SERVER is not set"
  exit 1
fi
if [ "$NFS_IMMICH_SHARE" == "" ]; then
  echo "NFS_SHARE is not set"
  exit 1
fi
if [ "$NFS_VOLUMEHANDLE" == "" ]; then
  echo "NFS_VOLUMEHANDLE is not set"
  exit 1
fi

# Install istio with ingress gateway
echo "Installing istio..."
kubectl create namespace istio-ingress
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
helm install istiod istio/istiod -n istio-system --set global.platform=k3s --wait 
helm install istio-ingress istio/gateway -n istio-ingress --set global.platform=k3s --wait

echo "Installing postgres operator..."
# Install cnpg operator
helm upgrade --install cnpg \
    --namespace cnpg-system \
    --create-namespace \
    cnpg/cloudnative-pg

echo "Configuring immich requirements..."
# Setup immich
kubectl create namespace immich
kubectl label ns immich istio-injection=enabled --overwrite

# Configure istio
helm upgrade --install istio-config ./istio-config \
    --namespace istio-system \
    --create-namespace \
    --set immich.hostname="IMMICH_HOSTNAME"

# Configure immich
helm upgrade --install immich-config ./immich-config/ \
    --namespace immich \
    --create-namespace \
    --set nfs.server="$NFS_SERVER" \
    --set nfs.share="$NFS_IMMICH_SHARE" \
    --set nfs.volumeHandle="$NFS_VOLUMEHANDLE" \
    -f ./immich-config/values.yaml

echo "Installing immich..."
# Install immich
helm install --create-namespace --namespace immich immich oci://ghcr.io/immich-app/immich-charts/immich -f ./immich/values.yaml

echo "Installing cert-manager..."
# Install cert-manager
helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.17.0 \
    --set crds.enabled=true

# Create cloudflare issuer and certs
# kubectl apply -f ./origin-ca-issuer/templates/issuer.yaml
# kubectl apply -f ./origin-ca-issuer/templates/cert.yaml

echo "Done!"
