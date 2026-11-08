#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Never read an export: even encrypted exports can contain credentials and PII.
python3 - "$root/config.toml" "$root/reviewed.rayconfig" <<'PYEOF'
import gzip
import json
import sys
import tomllib

with open(sys.argv[1], "rb") as source:
    settings = tomllib.load(source)

payload = json.dumps(settings, separators=(",", ":")).encode()
wrapper = {
    "appVersion": "1.0.0",
    "schemaVersion": 2,
    "data": gzip.compress(payload, mtime=0).hex(),
}

# Exclude host details, timestamps and source filenames from both gzip layers.
with open(sys.argv[2], "wb") as output:
    output.write(gzip.compress(json.dumps(wrapper).encode(), mtime=0))
print("Built reviewed.rayconfig from config.toml only.")
PYEOF
