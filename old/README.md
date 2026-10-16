# old

Retired configs, not imported anywhere. Kept for reference.

- `hyprland/` - Hyprland home-manager config, raw `hyprland.conf` and IME toggle script, replaced by niri. Needs the `ags`, `Hyprspace` and `Hedge` flake inputs.
- `spicetify.nix` - Spotify with spicetify. Needs the `spicetify-nix` flake input.
- `uuplugin/` - NetEase UU accelerator (Steam Deck plugin) packaged as a systemd service.
- `hardware-configuration.nix.old` - previous generated hardware config.

To revive one, uncomment its flake inputs and add it back to the imports in
`modules/nixos/default.nix` or `home/default.nix`.
