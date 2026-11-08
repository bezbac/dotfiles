# Raycast configuration

Settings are managed via the commented `config.toml`.

## Apply

1. Run `./compile.sh` with Python 3.11+.
2. Review `config.toml` before importing: the generated file contains only these settings.
3. In Raycast, run **Import Settings & Data** and select `reviewed.rayconfig`.

Partial imports have not been verified against Raycast. Omitted settings may reset, or the import may be rejected. Do not use this on a configured profile without a recovery plan; apply settings manually if partial imports are unsupported.

No exports, passwords, decrypted base files, or environment snapshots are read. Generated imports omit host details, timestamps, and source filenames. They are compressed, not encrypted: never add credentials or personal data to `config.toml`.

Legacy `export.rayconfig`, `base.json`, `config.json`, and `config.rayconfig` files are no longer used. Remove existing copies separately after reviewing them; gitignore does not make them safe to retain in the checkout.
