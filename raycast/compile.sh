#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
toml="$root/config.toml"
base="$root/base.json"
export_file="$root/export.rayconfig"
json="$root/config.json"
config_file="$root/config.rayconfig"
venv="$root/.venv"

needs_update=false
if [ ! -f "$base" ]; then
  needs_update=true
elif [ -f "$export_file" ] && [ "$export_file" -nt "$base" ]; then
  needs_update=true
fi

if [ "$needs_update" = true ]; then
  if [ ! -f "$export_file" ]; then
    echo "Error: $base not found (contains personal data, gitignored)." >&2
    echo "Export from Raycast (Settings -> Advanced -> Export Settings &" >&2
    echo "Data), save the file as export.rayconfig, then re-run." >&2
    exit 1
  fi

  if [ ! -x "$venv/bin/python3" ]; then
    echo "Creating decryption environment (.venv)…"
    python3 -m venv "$venv"
    "$venv/bin/pip" install -q cryptography
  fi

  read -r -s -p "Export password: " password
  echo

  PASSWORD="$password" "$venv/bin/python3" - "$export_file" "$base" <<'PYEOF'
import gzip, json, os, sys
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.scrypt import Scrypt

export_file, base_file = sys.argv[1], sys.argv[2]

with gzip.open(export_file, "rt") as f:
    wrapper = json.load(f)

if "encryption" in wrapper:
    enc = wrapper["encryption"]
    key = Scrypt(salt=bytes.fromhex(enc["salt"]), length=32, n=16384, r=8, p=1).derive(
        os.environ["PASSWORD"].encode()
    )
    plaintext = AESGCM(key).decrypt(
        bytes.fromhex(enc["iv"]),
        bytes.fromhex(wrapper["data"]) + bytes.fromhex(enc["authTag"]),
        None,
    )
else:
    plaintext = bytes.fromhex(wrapper["data"])

try:
    config = json.loads(gzip.decompress(plaintext))
except gzip.BadGzipFile:
    config = json.loads(plaintext)

with open(base_file, "w") as f:
    json.dump(config["settings"], f, indent=2)
print(f"Derived {base_file} from {export_file}")
PYEOF
  PASSWORD=""
fi

python3 -c '
import json, sys, tomllib

def deep_merge(base, overrides):
    for k, v in overrides.items():
        if isinstance(v, dict) and isinstance(base.get(k), dict):
            deep_merge(base[k], v)
        else:
            base[k] = v
    return base

with open(sys.argv[1], "rb") as f:
    overrides = tomllib.load(f)
with open(sys.argv[2]) as f:
    payload = {"settings": json.load(f)}
json.dump(deep_merge(payload, overrides), open(sys.argv[3], "w"), indent=2)
' "$toml" "$base" "$json"

os_name="$(sw_vers -productName 2>/dev/null || echo "macOS")"
os_version="$(sw_vers -productVersion 2>/dev/null || echo "unknown")"
os_arch="$(uname -m)"
exported_at="$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")"

payload="$(gzip -c "$json" | xxd -p -c 1000000)"

jq -n \
  --arg data "$payload" \
  --arg exportedAt "$exported_at" \
  --arg appVersion "1.0.0" \
  --arg osName "$os_name" \
  --arg osVersion "$os_version" \
  --arg osArch "$os_arch" \
  '{exportedAt: $exportedAt, appVersion: $appVersion, osName: $osName, osVersion: $osVersion, osArch: $osArch, schemaVersion: 2, data: $data}' \
  | gzip -c > "$config_file"

echo "Configuration built: $config_file"
