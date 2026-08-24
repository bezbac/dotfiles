#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
toml="$root/config.toml"
leader_key="$root/leader-key.json"
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

LEADER_KEY_EXTENSION_ID = "e:n:7eaf27c8-43af-40f1-a8d7-a7c3e76c8df0"

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

# Vim Leader Key stores imported configs with generated item ids inside a
# versioned wrapper. Keep the editable source in leader-key.json and reproduce
# that storage shape here. Schema reference (pinned to the inspected version):
# https://github.com/raycast/extensions/blob/f77874eacd6326b223483590c91bd61cd64fc977/extensions/vim-leader-key/src/storage.ts
def convert_leader_key_item(item, path):
    if not isinstance(item, dict):
        raise ValueError(f"Leader Key item at {path} must be an object")

    item_type = item.get("type")
    common_keys = {"key", "type", "label", "browser"}
    if item_type == "group":
        allowed_keys = common_keys | {"actions"}
    elif item_type in {"application", "url", "command", "folder"}:
        allowed_keys = common_keys | {"value"}
    else:
        raise ValueError(f"Unsupported Leader Key item type at {path}: {item_type!r}")

    unknown_keys = item.keys() - allowed_keys
    if unknown_keys:
        raise ValueError(f"Unsupported Leader Key keys at {path}: {sorted(unknown_keys)}")
    if not isinstance(item.get("key"), str):
        raise ValueError(f"Leader Key item at {path} must have a string key")

    converted = {"id": "rayconfig-" + "-".join(map(str, path))}
    converted.update({k: v for k, v in item.items() if k != "actions"})
    if item_type == "group":
        actions = item.get("actions")
        if not isinstance(actions, list):
            raise ValueError(f"Leader Key group at {path} must have an actions array")
        converted["actions"] = [
            convert_leader_key_item(child, (*path, index))
            for index, child in enumerate(actions)
        ]
    elif not isinstance(item.get("value"), str):
        raise ValueError(f"Leader Key action at {path} must have a string value")
    return converted

with open(sys.argv[1], "rb") as f:
    overrides = tomllib.load(f)
with open(sys.argv[2]) as f:
    payload = {"settings": json.load(f)}
with open(sys.argv[3]) as f:
    leader_key_config = json.load(f)

if leader_key_config.get("type") != "group" or not isinstance(leader_key_config.get("actions"), list):
    raise ValueError("leader-key.json must contain a root group with an actions array")

payload = deep_merge(payload, overrides)
leader_key_extension = next(
    extension
    for extension in payload["settings"]["nodeExtensions"]
    if extension["id"] == LEADER_KEY_EXTENSION_ID
)
leader_key_extension["localStorage"] = {
    "leader-key-config": json.dumps(
        {
            "root": {
                "type": "group",
                "actions": [
                    convert_leader_key_item(item, (index,))
                    for index, item in enumerate(leader_key_config["actions"])
                ],
            },
            "version": 1,
        },
        separators=(",", ":"),
    )
}
json.dump(payload, open(sys.argv[4], "w"), indent=2)
' "$toml" "$base" "$leader_key" "$json"

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
