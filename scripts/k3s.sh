#!/bin/bash

K3S_TOKEN=$(ssh -t k3s-master sudo cat /var/lib/rancher/k3s/server/node-token)
K3S_URL=https://$(ssh k3s-master "hostname -I | cut -d ' ' -f1"):6443
ssh -t k3s-worker-1 curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -
