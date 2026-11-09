{ pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 8;
    };

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

    # Local hardening and hardware workarounds.
    kernelParams = [
      # Clear newly allocated and freed memory.
      "init_on_alloc=1"
      "init_on_free=1"
      # Harden heap layout.
      "slab_nomerge"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"

      # Strict IOMMU for DMA protection (complements USBGuard)
      "amd_iommu=on"
      "iommu.passthrough=0"
      "iommu.strict=1"

      # Disable legacy fixed-address vsyscalls.
      "vsyscall=none"

      # AMD EPP and this laptop's backlight controls.
      "amd_pstate=active"
      "acpi_backlight=native"
      "nvidia_wmi_ec_backlight.force=1"
    ];

    kernel.sysctl = {
      "kernel.unprivileged_bpf_disabled" = 1; # Restrict unprivileged BPF.
      # Scope 1 keeps descendant debugging and Proton working; scope 2 blocks them.
      "kernel.yama.ptrace_scope" = 1;
      "kernel.dmesg_restrict" = 1;
      "kernel.kptr_restrict" = 2; # Hide kernel pointers.
    };
  };
}
