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

- `hosts/nixos/` - host specific config, hardware and stateVersion
- `modules/nixos/` - system modules
  - `core/` - boot, nix, locale, users, networking, performance
  - `desktop/` - session, audio, fonts, theming, input method
  - `virtualisation/` - libvirt, vfio passthrough, looking-glass, samba
  - `vr/`, `gaming.nix`, `dev.nix`, `browser.nix`, `apps.nix`, `nix-ld.nix`
- `pkgs/` - local packages
- `home/` - home-manager config
- `old/` - retired configs, not imported
