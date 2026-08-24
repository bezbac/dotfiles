# Raycast configuration

Settings are managed via the commented `config.toml`.

## Apply

1. If this is a fresh machine (or your settings changed in Raycast): export from Raycast → Settings → Advanced → **Export Settings & Data**, save the file as `export.rayconfig` in this directory.
2. Run `./compile.sh`. If `export.rayconfig` is newer than `base.json`, it asks for the export password and regenerates `base.json` from it.
3. In Raycast, run **Import Settings & Data**, press `Cmd+Shift+G`, paste the path to `config.rayconfig`, press Enter twice.

`config.toml` overrides are applied on top of your exported settings; all other keys stay as exported.

## Manual Setup

1. Install https://www.raycast.com/akshay_k/vim-leader-key from the Store
2. Run `open raycast-x://extensions/akshay_k/vim-leader-key/import-config` to import LeaderKey config
3. Import config from https://github.com/bezbac/dotfiles/blob/b92194925793a18859266e70f2c112aec40b03b3/leader-key/config.json 
