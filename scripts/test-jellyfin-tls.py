#!/usr/bin/env python3
"""Check that Jellyfin's ingress workload can resolve its TLS credential."""
from pathlib import Path
import yaml

root = Path(__file__).resolve().parents[1]
app = root / 'apps/jellyfin'
docs = [doc for resource in app.glob('*.yaml')
        for doc in yaml.safe_load_all(resource.read_text()) if doc]
gateway = next(doc for doc in docs if doc['kind'] == 'Gateway')
credential = next(s['tls']['credentialName'] for s in gateway['spec']['servers'] if s['port']['number'] == 443)
assert any(doc['kind'] == 'Certificate'
           and doc['metadata']['namespace'] == 'istio-ingress'
           and doc['spec']['secretName'] == credential
           and 'jellyfin.home.arpa' in doc['spec']['dnsNames']
           and doc['spec']['issuerRef']['name'] == 'home-ca-issuer'
           for doc in docs), 'TLS credential must be issued in gateway workload namespace istio-ingress'
print('PASS: Jellyfin TLS credential issued in ingress workload namespace with home CA')
