{
"title": "Shadow system audit",
"group": "DATED NOTES",
"weight": 50,
"sources": [],
"build": {
"render": "link",
"list": "always"
}
}

Audit date: **2026-10-11**. Goal: modern hardware support, measured battery efficiency, recoverability, and understandable maintenance. Recommendations and primary sources: [research](research.md).

## Follow-up: 2026-10-21

This review started from a clean worktree and covered the flake/lock, host and disk declarations, NixOS modules, Home Manager applications/shell/desktop configuration, and the existing security/recovery roadmap. The main host Nixpkgs input maps to lock node `nixpkgs_2`, revision `02c087f3fe673c9e317f206a627cb6b910336dbe`, dated 2026-10-20. The older `nixpkgs` node belongs to a separate input dependency; it is not the host pin. No input revisions were changed.

The merged configuration and read-only host sample confirmed a 20-thread CPU and approximately 14 GiB usable RAM on the nominal 16 GiB laptop. Nix defaulted to automatic concurrent jobs and all-core builders. DNSCrypt, PPD and smartd were running. The firewall declares no open TCP/UDP ports, SSH is disabled, and the listening-socket sample had only loopback DNS TCP listeners. UDP sockets included WireGuard and multicast DNS; this sample does not establish effective firewall rules or which application owns every multicast socket.

| Finding | Declarative revision | Practical limit |
| --- | --- | --- |
| Disabling systemd-coredump left `kernel.core_pattern = core`; the live sysctl agreed. | Discard the kernel dump stream instead of writing a working-directory core file. | Application-owned crash reports and existing files are separate; saved kernel dumps need an explicit debugging policy. |
| File/FIFO sticky-directory protections were at level 1 in the live sample. | Extend both to group-writable sticky directories at level 2. | Legacy scripts relying on prohibited cross-owner opens need repair. |
| Atuin had no declared privacy settings and its configuration/data directories used mode 0755. | Disable automatic sync/update checks, retain the built-in secret filter, and use private directory modes for Atuin and GitHub CLI state. | Manual sync remains possible; historical/local/remote entries are not deleted. |
| NetworkManager had no declared connection privacy defaults beyond the existing address randomization. | Default IPv4/IPv6 DHCP hostname sending to false. | Explicit stored-profile choices can override this; local DHCP name registration can change. |
| Build defaults can oversubscribe the laptop during parallel source builds. | Start with two Nix jobs and four cores per builder in the host configuration. | This is a contention-reduction policy, not a measured speedup or hard resource limit. |
| Persistent `nh-clean` catch-up had normal scheduling priority. | Use idle CPU/I/O scheduling and nice 19. | Retention stays unchanged; Nix optimisation and scrub already have low priority upstream. |
| Scrub/PPD state was not retained; smartd had no explicit writable save-state prefix. | Preserve the actual service-state paths and give smartd an explicit private state directory/prefix. | Migrate existing state before new mounts hide it; reboot survival and alert delivery remain unverified. |

The host's only failed unit in this sample was `fwupd-refresh.service`. Its journal showed an LVFS HTTP 503 response and a later metadata download timeout. This is evidence of failed firmware-metadata retrieval, not evidence that a Nix module is malformed. Firmware support remains enabled; no firmware was installed or runtime service restarted.

Formatting, the flake check including gitleaks, and the complete no-link Shadow system build passed for the configuration revision. The guide includes the new behavior and pre-activation migration notes. No activation, state migration, cleanup, reboot, firmware update, account sync or history deletion was performed. These are source/build results; battery improvement, DHCP behavior, resumed-session behavior and persistence after reboot require host acceptance.

The highest remaining priorities are independently recoverable encrypted backups and a restore drill; prepared Secure Boot recovery/enrollment; actual AppArmor profile coverage; the Signal database-key migration rehearsal; and repeatable battery/suspend measurements. The PAM workaround and known-working graphics/power defaults retain their existing acceptance requirements. These decisions need concrete recovery material or measurements, so this pass does not replace them with speculative settings.

## Follow-up: 2026-10-12

The initial audit below is dated evidence. The current source selects the NVIDIA
`latest` branch, uses Home Manager's built-in Noctalia module instead of a separate
Noctalia flake input, and removes the Superfile integration and unused recorder
packages. DNSCrypt's minimum cache TTL is reduced to 60 seconds. Power management
uses PPD and UPower, with TLP and auto-cpufreq disabled; the Razer hardware module
continues to own PRIME and runtime power defaults. The initrd option spelling and
storage comments have been corrected.

The changed Nix files passed formatting checks, `nix flake check` passed, and the
complete no-link Shadow system build passed. This supersedes the initial sandbox
build limitation and the warning about an unverified dirty build. No configuration
was activated in this follow-up; battery duration, suspend/resume and editor/provider
behavior still require observation on the running laptop. Current declarations and
input revisions are generated in Configuration, under Build details.

## Evidence and scope

- Read `AGENTS.md`, the flake/lock, `shadow/`, and targeted boot, power, graphics, networking, security, storage/preservation, desktop and service modules. Audited the **dirty working tree**, not just HEAD; existing files were not edited.
- **Declared** below means local source plus explicitly identified pinned hardware defaults; a complete merged NixOS evaluation was unavailable. **Observed** means a read-only sample through the editor's container/sandbox namespace, not a full host acceptance test.
- Root nixpkgs lock: `151fa4e8ddfdd8dd25d945ad94ed54a13de9f6e4`, tracking `nixos-unstable`. `stateVersion = "26.05"` selects compatibility defaults; it is not the installed release or an upgrade instruction.
- `nix flake check --offline --no-write-lock-file` and the no-link system build failed **before evaluation**, writing `/home/aqua/.cache/nix/fetcher-cache-v4.sqlite` (read-only). `git diff --check` passed. No activation, firmware changes, suspend tests, or Disko formatting were performed.
- Host D-Bus/service queries were denied; EFI/ESP visibility and host socket inspection were unavailable. Container `bootctl` reporting no EFI does **not** establish the host's boot mode or Secure Boot status. Read-only sandbox mounts are not evidence of host mount failure.

## Declared architecture

| Area / owning source                                                | Current design and implication                                                                                                                                                                                                                                                                                |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Composition: `flake.nix`, `shadow/default.nix`, `shadow/home.nix`   | One host/user; host and home directly select domain modules. Keep this structure; another composition layer would currently add indirection. Flake inputs include Home Manager, Disko, Preservation, SOPS, nixos-hardware and application integrations.                                                       |
| Boot: `modules/nixos/core/boot.nix`                                 | systemd-boot, eight visible entries, systemd initrd (option spelling corrected after the initial audit), Plymouth, `linuxPackages_latest`. Memory/IOMMU/sysctl hardening is deliberate; module signature enforcement/lockdown is omitted for NVIDIA/OpenRazer compatibility. No local Lanzaboote integration. |
| Hardware inheritance: pinned `razer/blade/14/RZ09-0530/default.nix` | AMD CPU/iGPU, NVIDIA PRIME offload with helper, AMD `PCI:197:0:0` / NVIDIA `PCI:196:0:0`; defaults enable NVIDIA suspend support and fine-grained runtime PM. These settings are **not missing** merely because the local graphics file omits them.                                                           |
| Graphics: `modules/nixos/hardware/graphics.nix`                     | NVIDIA beta branch, open kernel module, modesetting; persistence daemon disabled. Niri source selects AMD render node and `2880x1800@120.000`, scale 2, VRR; active renderer/output remains unverified.                                                                                                       |
| Power: `modules/nixos/services/power.nix`                           | PPD enabled, TLP and auto-cpufreq explicitly disabled, fstrim enabled. Hardware laptop defaults only enable TLP when PPD/TuneD are absent. No local TuneD or automatic Powertop tuning found.                                                                                                                 |
| Idle: `modules/home/wm/noctalia/config.toml`                        | Lock after 600 seconds, screen off after 720, lock-and-suspend after 1800. Runtime idle handling, inhibitors and locking on resume need testing.                                                                                                                                                              |
| Disk: `shadow/disk.nix`                                             | 4 GiB tmpfs root; 1 GiB FAT ESP; LUKS2 on one NVMe, with Btrfs `/nix`, `/saved`, `/swap`; zstd/noatime on nix/saved, 16 GiB swapfile. `/nix` and `/saved` are boot-critical. Discards pass through encryption.                                                                                                |
| Integrity: `modules/nixos/storage/default.nix`                      | Monthly scrub on `/saved` covers the shared Btrfs filesystem; zram precedes disk swap; smartd enabled. Scheduling, completion, health and notification delivery are not thereby proven.                                                                                                                       |
| Persistence: `modules/nixos/storage/preservation.nix`               | Explicit system/home state, including machine identity, NM connections, journal, browsers, keyrings, SSH/GPG/SOPS, documents/projects, application data and credentials. Downloads are not listed. Direct `/saved` paths already survive without another bind mount.                                          |
| DNS/network: `modules/nixos/networking/`                            | NetworkManager, loopback dnscrypt-proxy, NM DNS management and resolved disabled; randomized Wi-Fi MAC and IPv6 temporary addresses. Pinned hardware defaults select iwd with per-network address randomization and NM-owned IP configuration; confirm their combined effective behavior.                     |
| Security: `modules/nixos/security/`, `core/users.nix`               | Firewall enabled, SSH disabled; immutable users, root password locked, Aqua password from SOPS, root-only Nix trust, sudo-rs, USBGuard, AppArmor enabled, coredumps disabled. AppArmor availability is **not universal confinement**; Aqua can authorize USB devices.                                         |
| Secrets                                                             | Machine age key at `/saved/var/lib/sops-nix/key.txt`, not automatically generated; boot/user credentials depend on recovery of it. Persisted home state includes sensitive tokens. LUKS protects powered-off storage, not a logged-in compromised session.                                                    |
| Services                                                            | PipeWire/rtkit; fwupd enabled (LVFS support not guaranteed); hardened Kavita on loopback 8083, on-demand rather than boot-started. Managed Flatpaks update daily, independently of `flake.lock`, with per-app permission exceptions. Steam/Gamemode/Xwayland add a separate gaming stack.                     |
| Maintenance: `modules/nixos/core/nix.nix`                           | Friday nh cleanup: keep at least three generations and seven days; `--no-gcroots` **skips gcroot cleanup**, verified using installed help. Friday store optimization; no local automatic OS upgrade. Extra binary-cache keys are supply-chain trust decisions.                                                |

## Read-only observations (not deployment proof)

- `nixos-version`: **26.11.20261006.151fa4e (Zokor)**; kernel **7.2.9**; NVIDIA **open kernel module 615.71.09**. The current-system version agrees with the root pin prefix, but does not prove the dirty edits are deployed.
- AMD pstate was active, using `amd-pstate-epp`, with EPP `power`. This does not prove PPD's selected profile or service health. The legacy platform-profile attributes were absent; no class-profile files were found by the limited check.
- NVIDIA `0000:c4:00.0` and audio `.1`: `power/control=auto`, `runtime_status=suspended`; NVIDIA proc status: **fine-grained RTD3 enabled, video memory off**. Preserve this working baseline; recheck after offload, monitors and resume.
- System sleep advertised **`[s2idle]`** only. NVIDIA reported S0ix platform support but its S0ix status disabled. Runtime D3, NVIDIA S0ix and system sleep are distinct; no overnight drain/resume measurement was performed.
- BAT0: 112 cycles; charge-full/design `3749000/4417000` ≈ **84.9% charge-based health**. Discharging samples around 36–38% implied approximately **10.6–11.8 W instantaneous**; unknown workload, brightness and settling mean this is **not an idle benchmark** or a battery-life estimate.
- zram approximately 7.4 GiB, priority 5; disk swap 16 GiB, priority −1. Visible mounts agreed with encrypted Btrfs saved/nix/swap and tmpfs root. No local resume declaration was found; hibernation is not established by swap capacity alone.

## Preflight blocker in the dirty boot configuration

`modules/nixos/core/boot.nix:15` declares `initrd.systemd = true;` inside `boot`. The [pinned Nixpkgs initrd module](https://raw.githubusercontent.com/NixOS/nixpkgs/151fa4e8ddfdd8dd25d945ad94ed54a13de9f6e4/nixos/modules/system/boot/systemd/initrd.nix) defines `boot.initrd.systemd.enable`, with sibling service/package options; `systemd` is an attribute namespace, not a boolean switch. This is a source/schema mismatch and **likely evaluation blocker**, not an observed running-system failure. Full evaluation never reached this point because of the cache restriction.

The handbook pass corrected this declaration to `initrd.systemd.enable = true;`. Before deployment, validate:

```sh
nix eval .#nixosConfigurations.shadow.config.boot.initrd.systemd.enable --no-write-lock-file
```

The initial audit did not edit Nix files; a subsequent pass corrected the option spelling and clarified selected comments. Do not treat the dirty configuration as build-verified.

## Gaps ranked by consequence

1. **Recovery assurance:** no local restic/Borg/btrbk/snapshot automation found; external backups may exist, but coverage, independent keys and a successful restore are unknown. Persistence, encryption, scrub and Nix generations are not backups.
2. **Ephemeral service state:** no explicit local persistence found for `/var/lib/btrfs`, smartmontools state, dnscrypt-proxy's catalog cache or PPD profile state. Inspect actual unit/package paths before changes; lost scrub progress/history or forgotten preferences are different from lost user data. Persistent timer stamps do not prove successful jobs.
3. **Maintenance assurance:** verify scrub/SMART alerts and missed-job behavior on a sleeping laptop. One NVMe offers no independent failure domain; scrub can repair only from valid redundant copies. Confirm data/metadata profiles, don't assume all corruption is repairable.
4. **Rollback assurance:** eight boot entries are not eight retained system generations. Latest kernel plus beta NVIDIA increases update surface; retain a known-good generation and test reboot/suspend/offload. Flatpak or persisted database migrations are not undone by Nix rollback.
5. **Session/network edge cases:** greetd bypasses the nested `user@` PAM stack for a reported deadlock; review lifecycle/keyring effects. Loopback-only DNS may interfere with captive portals/VPN split DNS; raised minimum TTL can delay changed answers. No host listening-port or firewall-rule audit completed.

## Host-side validation and battery experiment

Run these in a real host terminal, not the editor namespace. Commands inspect state unless explicitly labelled as a change; some tools may require a temporary Nix shell. Logs/network details can contain private information.

```sh
nixos-version; uname -r; readlink -f /run/current-system
systemctl --failed
systemctl status power-profiles-daemon smartd dnscrypt-proxy
systemctl list-timers --all
powerprofilesctl list; powerprofilesctl get; powerprofilesctl list-holds
cat /sys/devices/system/cpu/amd_pstate/status
cat /sys/devices/system/cpu/cpufreq/policy0/energy_performance_preference
cat /sys/power/mem_sleep
niri msg outputs
niri validate --config ~/.config/niri/config.kdl
cat /proc/driver/nvidia/gpus/0000:c4:00.0/power
cat /sys/bus/pci/devices/0000:c4:00.0/power/control
cat /sys/bus/pci/devices/0000:c4:00.0/power/runtime_status
cat /sys/bus/pci/devices/0000:c4:00.1/power/runtime_status
```

1. Record profile, brightness, actual display mode, ambient conditions, battery level/health, network, peripherals and workload. Unplug AC; stop builds, downloads, games and GPU applications; allow 5–10 minutes to settle. Avoid `nvidia-smi` polling during measurements because it can wake the GPU.
2. Compare PPD balanced and power-saver in repeated 10–20 minute windows, reversing order on another run. **Profile changes:** `powerprofilesctl set balanced`, then `powerprofilesctl set power-saver`; restore the originally recorded profile afterward. Compare median watts plus responsiveness and task completion energy, not one instantaneous sample.
3. Sample BAT0 without tuning anything (µV × µA ÷ 10¹² = watts). If `power_now`/`energy_now` exist, use their documented units; do not confuse charge with energy:

```sh
for sample in 1 2 3 4 5 6 7 8 9 10; do
  date --iso-8601=seconds
  cat /sys/class/power_supply/BAT0/status
  cat /sys/class/power_supply/BAT0/voltage_now
  cat /sys/class/power_supply/BAT0/current_now
  sleep 60
done
```

4. Separately compare an advertised 60 Hz mode against 120 Hz at fixed brightness; only use modes reported by `niri msg outputs`, then restore the original mode. Test realistic browsing/video/idle, not only an empty desktop. Never blindly stack PPD, TLP, TuneD, auto-cpufreq or `powertop --auto-tune`.
5. Test a short suspend/resume while supervised, then an overnight unplugged interval only after reliable resume; record charge/energy and elapsed time, locking, Wi-Fi, audio and post-resume RTD3. Save work first. Do not force unsupported `deep` sleep or assume hibernation works. Check supported charge-threshold attributes before proposing longevity limits; do not deep-cycle solely for this audit.

## Storage, recovery, network and security checks

```sh
findmnt -T /saved; findmnt -T /home/aqua/Documents; findmnt -T /home/aqua/Downloads
sudo btrfs filesystem usage /saved
sudo btrfs device stats /saved
sudo btrfs scrub status /saved
sudo smartctl -x /dev/nvme0n1
journalctl -u smartd --since '30 days ago'
systemctl list-units --all 'btrfs-scrub*'
sudo ls -ld /var/lib/btrfs /var/lib/smartmontools /var/lib/dnscrypt-proxy
sudo ss -lntup
sudo nft list ruleset
nmcli general status; nmcli connection show --active
getent ahosts nixos.org
sudo aa-status
sudo usbguard list-devices
bootctl status; df -h /boot
fwupdmgr get-devices; fwupdmgr get-updates
```

- Use the discovered scrub unit name to inspect its journal and timer; inspect `systemctl cat smartd` and generated device configuration. Confirm the notification destination and test delivery deliberately. Reading health is safe; extended self-tests/scrubs generate I/O and should be separately scheduled on AC. Do not run `btrfs check --repair` as an audit.
- For persistence, inspect exact paths with `findmnt -T` and `readlink -f`, verify permissions, then do a controlled reboot with disposable test data. Check newly introduced service state, Noctalia generated includes and user credentials; document intentional losses such as Downloads. Do not expose secret contents in logs.
- Inventory a backup of valuable `/saved` state and declarative configuration, including encrypted-secret files and independently recoverable age/LUKS credentials. Keep an encrypted off-device copy and LUKS header backup on a separate failure domain; neither ciphertext without keys nor keys only on this disk constitute recovery.
- Restore a selected backup snapshot to an isolated **external** test directory, not over production and not a large `/tmp` restore on the 4 GiB root. Verify files, ownership, application data and ability to recover without the laptop; agree on recovery-point/time objectives and exclusions for caches/store/games.
- Test DNS after reboot, with IPv4-only Wi-Fi, a captive portal and VPN internal names. Inspect real firewall rules/listeners rather than assuming local declarations cover all imported services. Review direct `input`/`dialout` access and Flatpak exceptions. fwupd queries can contact remote servers; no firmware update was executed.

## Safe update and clarity policy

From `/saved/nixos-config`, run `nix flake check --no-write-lock-file`, `git diff --check`, and `nix build .#nixosConfigurations.shadow.config.system.build.toplevel --no-link --no-write-lock-file`. Review lock/source diffs before `sudo nh os test /saved/nixos-config`; test activation does not load a new kernel or undo mutable data changes. Bootloader/kernel/storage changes also need a reviewed boot generation, actual reboot, and recovery media. Never test with destructive Disko commands.

Before weekly cleanup, inspect `nh clean all --dry --keep 3 --keep-since 7d --no-gcroots` and bootable generations; keep a durable known-good rollback until a new generation passes AC/battery, boot, resume, offload and networking checks. Review cache trust and independently updating Flatpaks as part of this policy.

Suggested future comment improvements (no source edits made):

- `boot.nix`: distinguish hardening from “performance” flags; explain each backlight override's measured need and removal test.
- `disk.nix`: swap size is not hibernation configuration and “16G = full RAM” needs verification; explain discard allocation-pattern leakage alongside TRIM, and don't imply TPM auto-unlock alone authenticates boot.
- `graphics.nix`: reference inherited PRIME/PM ownership; document why beta/latest is necessary, affected hardware and a stable-driver/kernel retest criterion.
- `greetd.nix`: retain the deadlock explanation, add a reproducer/upstream issue and conditions to remove the nested-PAM bypass; test session cleanup and keyring behavior.
- Keep accurate AppArmor/DNS/scrub comments. The former checklist has been replaced by the source-backed technology tables; scrub/SMART and confinement distinctions are recorded there. Do not add extra module layers or comments that only restate assignments.
