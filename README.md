# NixOS flake

> tfw your system is more reproducable than you

- System-wide sane defaults (must-have
  - `adw-gtk3` as default gtk3 theme
  - `KvLibadwiata` as default qt kvantum theme
  - allow pipewire to set different sample rates
  - Fonts
    - noto as CJK font
    - Inter as UI font
    - Fira mono/code as monospace font
- Packages
  - All GNOME default packages
  - VSCodium and Zed
  - Zen Browser
  - Vesktop (discord
  - more
- niri + noctalia config with home-manager
- GPU passthrough VM setup with looking-glass
- VR with monado

## Layout

- `hosts/<host>/` - per host config, hardware and stateVersion
  - `nixos` - desktop, imports vr/virtualisation/gaming on top of the shared modules
  - `macbook` - apple silicon (asahi), build with `--impure` so firmware is read from the ESP
- `modules/nixos/` - system modules, `default.nix` is shared by all hosts
  - `core/` - nix, locale, users, networking, performance
  - `desktop/` - session, audio, fonts, theming, input method
  - `virtualisation/`, `vr/`, `gaming.nix` - imported by the desktop only
- `pkgs/` - local packages
- `home/` - home-manager config, `hosts/<host>.nix` for host specific bits
  - `niri/config.kdl` includes `host.kdl`, from `niri/hosts/<host>.kdl`
- `old/` - retired configs, not imported

```
sudo nixos-rebuild switch --flake .#nixos
sudo nixos-rebuild switch --flake .#macbook --impure
home-manager switch --flake .#kzdkm@<host>
```
