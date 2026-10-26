{ pkgs, ... }:
{
  # Parked experiment; check compatibility before enabling Rust-based init.
  # system.nixos-init.enable = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 8;
    };

    # REVISE: GET IT BACK? (there was nixos error when building from this)
    # initrd.systemd.enable = true;

    # Track new hardware support; reboot-test NVIDIA and suspend on each bump.
    kernelPackages = pkgs.linuxPackages_latest;

    # Graphical LUKS prompt and boot progress; Esc still reveals diagnostics.
    plymouth = {
      enable = true;
      theme = "motion";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "motion" ];
        })
      ];
    };

    # Security hardening and hardware overrides; not blanket performance tuning.
    kernelParams = [
      # Prevent data leaks in uninitialized memory
      "init_on_alloc=1"
      "init_on_free=1"
      # Thwart kernel heap exploits
      "slab_nomerge"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"

      # Strict IOMMU for DMA protection (complements USBGuard)
      "amd_iommu=on"
      "iommu.passthrough=0"
      "iommu.strict=1"

      # Disable vsyscalls as they are fixed-address (ASLR bypass)
      "vsyscall=none"

      # Unsigned NVIDIA/OpenRazer modules prevent enforcing module signatures.

      # AMD EPP policy and laptop backlight overrides; recheck after driver updates.
      "amd_pstate=active"
      "acpi_backlight=native"
      "nvidia_wmi_ec_backlight.force=1"
    ];

    # Kernel Security Hardening
    kernel.sysctl = {
      "kernel.unprivileged_bpf_disabled" = 1; # Blocks BPF JIT spraying
      # Scope 1 keeps descendant debugging and Proton working; scope 2 blocks them.
      "kernel.yama.ptrace_scope" = 1;
      "kernel.dmesg_restrict" = 1;
      "kernel.kptr_restrict" = 2; # Hides kernel pointers from dmesg
    };
  };
}
