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
import gzip, json, os, struct, sys
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.scrypt import Scrypt

export_file, base_file = sys.argv[1], sys.argv[2]

with open(export_file, "rb") as f:
    raw_export = f.read()

if raw_export.startswith(b"RAYCFG3\n"):
    metadata_length = struct.unpack("<I", raw_export[8:12])[0]
    metadata_end = 12 + metadata_length
    wrapper = json.loads(gzip.decompress(raw_export[12:metadata_end]))
    encrypted_data = raw_export[metadata_end:]
else:
    wrapper = json.loads(gzip.decompress(raw_export))
    encrypted_data = None

if "encryption" in wrapper:
    enc = wrapper["encryption"]
    key = Scrypt(salt=bytes.fromhex(enc["salt"]), length=32, n=16384, r=8, p=1).derive(
        os.environ["PASSWORD"].encode()
    )
    if encrypted_data is not None:
        plaintext = AESGCM(key).decrypt(bytes.fromhex(enc["iv"]), encrypted_data, None)
    else:
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
        # TOML arrays of tables with ids are sparse overrides. Merge matching
        # entries by id so config.toml can change one extension without
        # discarding other exported extensions or their metadata.
        elif (
            isinstance(v, list)
            and isinstance(base.get(k), list)
            and all(isinstance(item, dict) and "id" in item for item in v)
            and all(isinstance(item, dict) and "id" in item for item in base[k])
        ):
            base_by_id = {item["id"]: item for item in base[k]}
            for item in v:
                if item["id"] in base_by_id:
                    deep_merge(base_by_id[item["id"]], item)
                else:
                    base[k].append(item)
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
