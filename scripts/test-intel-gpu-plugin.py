#!/usr/bin/env python3
"""Render the GPU overlay and check the pinned legacy binary's path contract.

Requires kubectl and PyYAML. Run from any directory; no cluster writes.
"""
import os
from pathlib import Path
import subprocess
import yaml

root = Path(__file__).resolve().parents[1]
rendered = subprocess.check_output(
    [os.environ.get('KUBECTL', 'kubectl'), 'kustomize', str(root / 'apps/intel-gpu-plugin')],
    text=True,
)
ds = next(x for x in yaml.safe_load_all(rendered) if x['kind'] == 'DaemonSet')
spec = ds['spec']['template']['spec']
container = next(x for x in spec['containers'] if x['name'] == 'intel-gpu-plugin')
assert not any(x.startswith('-prefix=') and x != '-prefix=' for x in container['args']), \
    'Legacy binary emits prefixed HostPath: must use native host paths'
assert '@sha256:' in container['image'], 'Pin the exercised binary, not mutable devel'
mounts = {x['name']: x for x in container['volumeMounts']}
volumes = {x['name']: x for x in spec['volumes']}
for name, path in [('devfs', '/dev/dri'), ('sysfs', '/sys')]:
    assert mounts[name]['mountPath'] == path
    assert mounts[name]['readOnly'] is True
    assert volumes[name]['hostPath']['path'] == path
assert mounts['kubeletsockets']['mountPath'] == '/var/lib/kubelet/device-plugins'
assert spec['nodeSelector']['intel.feature.node.kubernetes.io/gpu'] == 'true'
assert container['securityContext']['allowPrivilegeEscalation'] is False
print('PASS: GPU native host paths, digest pin, read-only discovery, sockets and security')
