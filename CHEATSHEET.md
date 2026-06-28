# CHEATSHEET — shadow (Razer Blade 14 · NixOS 26.05)

> **Host:** shadow · **User:** aqua · **Shell:** fish · **DE:** GNOME (Wayland)
> **GPU:** AMD Radeon 890M (iGPU / panel) + NVIDIA RTX (dGPU / PRIME offload)
> **Disk:** tmpfs `/` (4G, wiped on reboot) · LUKS2 btrfs on nvme0n1 · `/nix` + `/saved` persistent

---

## 1 ⸺ NixOS System Management (nh)

| Command | What it does |
|---|---|
| `nx-rebuild` | Rebuild & switch to current config (`nh os switch`) |
| `nx-test` | Test a build without switching (`nh os test`) |
| `nx-clean` | Clean old generations (keep 10, max 14d) |
| `nh os switch /saved/nixos-config` | Full rebuild + switch (the raw command) |
| `nh os test /saved/nixos-config` | Build only, activate on next boot |
| `nh os boot /saved/nixos-config` | Build & set as default boot entry only |
| `nh clean all --keep-since 14d --keep 10` | Garbage-collect old generations |
| `nix-store --gc` | Manual garbage collection |
| `nix flake check /saved/nixos-config` | Validate the flake |
| `nix flake update` | Update flake inputs (do inside `/saved/nixos-config`) |
| `nixos-rebuild list-generations` | List all bootable generations |
| `systemctl list-boot` | Same as above (systemd-boot) |
| `sudo nix-collect-garbage -d` | Delete ALL old generations (dangerous) |

---

## 2 ⸺ Disk & Storage

| Command | What it does |
|---|---|
| **Info / Usage** | |
| `df` | Human disk usage per filesystem (aliased → `duf`) |
| `du` | Directory size, interactive tree (aliased → `dust`) |
| `lsblk -f` | List block devices + filesystems |
| `lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE` | Detailed block device view |
| `sudo btrfs filesystem df /` | Btrfs usage breakdown (data / metadata) |
| `sudo btrfs filesystem show /saved` | Show btrfs volumes + UUIDs |
| `sudo btrfs subvolume list /` | List all btrfs subvolumes |
| `sudo btrfs device stats /` | Btrfs device error counters |
| `findmnt /` | Confirm `/` is tmpfs |
| `findmnt /nix` | Confirm `/nix` is btrfs on LUKS |
| `sudo fdisk -l /dev/nvme0n1` | Partition table |
| `sudo cryptsetup status crypted` | LUKS container status |
| `mount \| grep '^/'` | Everything currently mounted |
| **Maintenance** | |
| `sudo btrfs scrub start /saved` | Scrub btrfs for corruption |
| `sudo btrfs scrub status /saved` | Check scrub progress |
| `sudo btrfs balance start -dusage=50 /saved` | Re-balance btrfs chunks |
| **Swap** | |
| `swapon --show` | Show active swap |
| `free -h` | RAM + swap summary |

### Disk layout (quick reference)

| Mount | fs | Persistence |
|---|---|---|
| `/` | tmpfs (4G cap) | ❌ wiped every reboot |
| `/boot` | vfat (ESP) | ✅ |
| `/nix` | btrfs (LUKS2) | ✅ |
| `/saved` | btrfs (LUKS2) | ✅ |
| `/swap` | btrfs swapfile (16G) | ✅ (file inside LUKS) |
| `/home/aqua/Downloads` | tmpfs (via `/`) | ❌ wiped every reboot |
| `/home/aqua/*` (most) | bind-mount → `/saved/home/aqua` | ✅ |

---

## 3 ⸺ GPU / NVIDIA / AMD

| Command | What it does |
|---|---|
| **Which GPU is active?** | |
| `glxinfo \| grep "OpenGL renderer"` | Shows which GPU renders OpenGL |
| `__NV_PRIME_RENDER_OFFLOAD=1 glxinfo \| grep renderer` | Force dGPU OpenGL query |
| `vulkaninfo --summary \| grep deviceName` | List Vulkan-capable GPUs |
| `prime-run glxinfo \| grep renderer` | dGPU via wrapper (if installed) |
| `nvidia-offload glxinfo \| grep renderer` | dGPU via nixos-hardware wrapper |
| **NVIDIA status** | |
| `nvidia-smi` | NVIDIA GPU stats (temp, VRAM, processes) |
| `nvidia-smi -l 1` | Live monitor (1s interval) |
| `nvidia-smi -q -d TEMPERATURE` | GPU temp only |
| `lspci \| grep -i nvidia` | Is NVIDIA PCI device present? |
| `lsmod \| grep nvidia` | Are NVIDIA kernel modules loaded? |
| `cat /proc/driver/nvidia/version` | NVIDIA driver version |
| **AMD status** | |
| `lspci \| grep -i amd` | AMD GPU PCI device |
| `lsmod \| grep amdgpu` | AMDGPU kernel module loaded? |
| `cat /sys/class/drm/card*/device/gpu_busy_percent` | AMD GPU utilization % |
| `radeontop` | AMD GPU live monitor (if installed) |
| **PRIME offload** | |
| `env \| grep PRIME` | Check PRIME env vars |
| `echo $__NV_PRIME_RENDER_OFFLOAD` | 1 = PRIME active in current shell |
| **Kernel params (check)** | |
| `cat /proc/cmdline` | Show all kernel boot params |
| `dmesg \| grep -i "nvidia\|amdgpu\|drm"` | GPU-related kernel messages |

---

## 4 ⸺ Performance & System Monitoring

| Command | What it does |
|---|---|
| `btop` | Full interactive system monitor (CPU, RAM, net, disk, GPU if supported) |
| `top` | Classic `top` — rerouted to btop |
| `procs` | Modern process list (aliased → `ps`) |
| `ps aux \| grep <name>` | Classic process search |
| `fastfetch` | Hardware + system summary on terminal open |
| `htop` | Also → btop |
| **CPU** | |
| `lscpu` | CPU architecture details |
| `cat /proc/cpuinfo \| grep "model name" \| head -1` | CPU model |
| `watch -n1 "cat /proc/cpuinfo \| grep MHz"` | Live CPU frequency |
| `cpupower frequency-info` | CPU frequency policy |
| **RAM** | |
| `free -h` | RAM + swap |
| `cat /proc/meminfo` | Detailed memory stats |
| `vmstat 1` | System-wide: procs, memory, swap, io, cpu (1s) |
| **Disk I/O** | |
| `iostat -x 1` | Disk I/O per device (install `sysstat`) |
| `iotop` | Per-process I/O |
| **Network** | |
| `nmap localhost` | Open ports on localhost |
| `nmap -sP 192.168.1.0/24` | Scan LAN for hosts |
| `ss -tulpn` | Listening TCP/UDP ports + process |
| `nethogs` | Per-process bandwidth (install `nethogs`) |
| **Thermals / Fan** | |
| `sensors` | CPU/GPU temps (if `lm_sensors` available) |
| `cat /sys/class/thermal/thermal_zone*/temp` | Raw thermal zone temps |
| `acpi -t` | Battery/thermal (if `acpi` installed) |

---

## 5 ⸺ Power Management (Laptop)

| Command | What it does |
|---|---|
| `powerprofilesctl get` | Current power profile |
| `powerprofilesctl set performance` | Max performance |
| `powerprofilesctl set balanced` | Balanced |
| `powerprofilesctl set power-saver` | Battery saving |
| `upower -d` | Full power info (battery, AC, devices) |
| `upower -i /org/freedesktop/UPower/devices/battery_BAT0` | Battery details |
| `cat /sys/class/power_supply/BAT0/capacity` | Battery % |
| `cat /sys/class/power_supply/BAT0/status` | Charging / Discharging |

---

## 6 ⸺ Bluetooth & USB

| Command | What it does |
|---|---|
| `bluetoothctl` | Interactive Bluetooth manager |
| `bluetoothctl scan on` | Start scanning |
| `bluetoothctl devices` | Paired devices |
| `bluetoothctl connect <MAC>` | Connect to device |
| `lsusb` | List USB devices (`usbutils`) |
| `lsusb -t` | USB device tree |
| `lspci` | List PCI devices (`pciutils`) |
| `lspci -k` | PCI devices + kernel drivers |

---

## 7 ⸺ Audio (PipeWire)

| Command | What it does |
|---|---|
| `wpctl status` | WirePlumber status (devices, nodes) |
| `wpctl inspect <id>` | Inspect a specific node |
| `pw-cli info all` | Raw PipeWire state dump |
| `pactl list sinks` | Audio sinks (speakers, headphones) |
| `pactl list sources` | Audio sources (mics) |
| `pactl set-default-sink <name>` | Set default output |
| `systemctl --user status pipewire wireplumber` | Are audio services running? |

---

## 8 ⸺ Gaming Mode (Jovian / GameScope / Steam)

| Command | What it does |
|---|---|
| `gamemoderun %command%` | Launch any game with GameMode (Steam launch option) |
| `gamemoderun glxgears` | Test GameMode outside Steam |
| `systemctl --user status gamemoded` | Check if GameMode daemon runs |
| `nvidia-offload %command%` | Run anything on dGPU (desktop mode) |
| `steam` | Launch Steam desktop client |
| **Gaming Mode session** | Pick "Gaming Mode" from GDM gear menu → boots into gamescope |

---

## 9 ⸺ Networking & Internet

| Command | What it does |
|---|---|
| `dig example.com` | DNS lookup |
| `dig +short example.com` | DNS lookup, answer only |
| `dig -x 1.1.1.1` | Reverse DNS |
| `nmap -sV 192.168.1.1` | Scan a host (version detection) |
| `nmap -sV -p 1-65535 target` | Full port scan |
| `xh httpbin.org/get` | HTTP GET (like curl but prettier) |
| `xh POST httpbin.org/post key=value` | HTTP POST |
| `curl -I https://example.com` | Fetch headers only |
| `wget -r -l2 https://site.com` | Recursive download (depth 2) |
| `nmcli dev wifi list` | Scan Wi-Fi networks |
| `nmcli connection show` | Saved connections |
| `nmcli radio wifi on\|off` | Toggle Wi-Fi |

---

## 10 ⸺ Git

| Command | What it does |
|---|---|
| **Shortcuts (fish abbr)** | |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --decorate` |
| `gd` | `git diff` |
| `gh` | GitHub CLI |
| `gh pr create` | Create pull request |
| `gh issue list` | List issues |
| `lazy` | Launch lazygit TUI |

---

## 11 ⸺ Shell & File Tools

### Replacements (fish aliases)

| You type… | Runs… | What it is |
|---|---|---|
| `ls` | `eza --icons --group-directories-first` | Modern ls |
| `ll` | `eza -l --icons --git` | Long listing |
| `la` | `eza -la --icons --git` | All files |
| `tree` | `eza --tree --icons --level=2` | Tree view (2 levels) |
| `cat` | `bat` | Syntax-highlighted file viewer |
| `grep` | `rg` | ripgrep (fast recursive search) |
| `find` | `fd` | fd (fast file search) |
| `top` / `htop` | `btop` | Interactive monitor |
| `ps` | `procs` | Modern process list |
| `nano` | `micro` | Modern editor |
| `df` | `duf` | Disk usage |
| `du` | `dust` | Directory size |

### Useful file commands

| Command | Purpose |
|---|---|
| `rg "pattern"` | Search code recursively (ripgrep) |
| `rg -l "pattern"` | List files containing pattern |
| `rg --type nix "imports"` | Search only .nix files |
| `fd "*.nix"` | Find .nix files (fd) |
| `fd -e nix` | Same, explicit extension |
| `fd -H "pattern"` | Include hidden files |
| `y` | Launch yazi file manager (and cd to its exit dir) |
| `z <dirname>` | Smart jump to directory (zoxide) |
| `zoxide query -l` | List zoxide database |
| `fzf` | Fuzzy finder (pipe anything into it) |
| `xh` | HTTP requests (aliased → `http`) |
| `ouch decompress file.tar.gz` | Extract anything |
| `ouch compress file.tar.gz dir/` | Compress directory |
| `micro file` | Edit file in micro editor |
| `btop` | System monitor |
| `fastfetch` | System info on terminal launch |

### Navigation shortcuts

| Shortcut | Expands to |
|---|---|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `mkcd <dir>` | Create dir + cd into it |
| `take <dir>` | Same as mkcd |

---

## 12 ⸺ Security & Encryption

| Command | What it does |
|---|---|
| `gpg --list-keys` | List GPG keys |
| `gpg --gen-key` | Generate new GPG key |
| `gpg -e -r user@example.com file` | Encrypt file for recipient |
| `gpg -d file.gpg` | Decrypt file |
| `age -r <recipient> -o file.age file` | Encrypt with age |
| `age -d -i key.txt -o file file.age` | Decrypt with age |
| `sops -e file.yaml > file.enc.yaml` | Encrypt with SOPS |
| `sops -d file.enc.yaml` | Decrypt SOPS file |
| `statix check .` | Lint Nix code |
| `deadnix .` | Find unused Nix code |
| `deadnix --edit .` | Auto-remove unused code |

---

## 13 ⸺ Services (systemctl)

| Command | Purpose |
|---|---|
| `systemctl list-units --type=service --state=running` | All running services |
| `systemctl status <service>` | Service status + last log lines |
| `systemctl --user status` | User services |
| `sudo systemctl restart <service>` | Restart a service |
| `systemctl --failed` | List failed services |
| `journalctl -u <service> --no-pager -n 50` | Last 50 log lines for a service |
| `journalctl -f` | Follow logs live |
| `journalctl -b -p 3` | Errors since boot |
| `journalctl --disk-usage` | How much space logs use |

---

## 14 ⸺ Flatpak

| Command | Purpose |
|---|---|
| `flatpak list` | Installed flatpaks |
| `flatpak search <app>` | Search Flathub |
| `flatpak update` | Update all flatpaks |
| `flatpak uninstall --unused` | Remove dangling runtimes |
| `flatpak run <app.id>` | Launch a flatpak manually |

---

## 15 ⸺ GNOME Shell Tricks

| Action | How |
|---|---|
| Re-reload shell (after extension change) | `Alt+F2` → type `r` → Enter |
| Restart GNOME Shell | `systemctl --user restart org.gnome.Shell@wayland` on Wayland |
| Open looking-glass (debugger) | `Alt+F2` → `lg` |
| Toggle GSConnect on | `phone-on` (fish alias) |
| Toggle GSConnect off | `phone-off` |
| GNOME extensions list | `gnome-extensions list` |

---

## 16 ⸺ File Locations (Persistent = on /saved)

| Data | Path |
|---|---|
| **System config (flake)** | `/saved/nixos-config` |
| **Fish history** | `/saved/home/aqua/.local/share/fish` |
| **Atuin DB** | `/saved/home/aqua/.local/share/atuin` |
| **Firefox profile** | `/saved/home/aqua/.mozilla` |
| **SSH keys** | `/saved/home/aqua/.ssh` |
| **GPG keys** | `/saved/home/aqua/.gnupg` |
| **GitHub CLI auth** | `/saved/home/aqua/.config/gh` |
| **GNOME dconf** | `/saved/home/aqua/.config/dconf/user` |
| **Zed state** | `/saved/home/aqua/.local/share/zed` + `.config/zed` |
| **Steam games** | `/saved/home/aqua/.local/share/Steam` |
| **Flatpak data** | `/var/lib/flatpak` (bind-mounted) |
| **Decky Loader** | `/var/lib/decky-loader` (bind-mounted) |
| **Bluetooth pairings** | `/var/lib/bluetooth` |
| **Wi-Fi passwords** | `/etc/NetworkManager/system-connections` |
| **Machine ID** | `/saved/etc/machine-id` → `/etc/machine-id` (symlink) |
| **SSH host keys** | `/saved/etc/ssh/ssh_host_ed25519_key*` → `/etc/ssh/` (symlink) |
| **Secrets (nix config)** | `/saved/secrets/nix.conf` → `~/.config/nix/nix.conf` (symlink) |

---

## 17 ⸺ Quick Diagnostics Checklist

```
# Is everything mounted?
findmnt / /nix /saved /boot /swap

# Is the GPU stack healthy?
lspci -k | grep -A 3 -E "VGA|3D"
nvidia-smi && echo "NVIDIA OK" || echo "NVIDIA not found"

# Is PipeWire running?
systemctl --user status pipewire wireplumber

# Are services clean?
systemctl --failed
journalctl -b -p 3 --no-pager -n 20

# Disk healthy?
sudo btrfs device stats /saved

# Enough free RAM / tmpfs?
df -h /
free -h

# What generation am I on?
readlink /run/current-system
```
