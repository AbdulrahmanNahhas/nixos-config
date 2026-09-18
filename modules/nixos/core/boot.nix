# boot.nix
{ pkgs, ... }:
{
  # Bootloader Configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 8;
    };

    # Latest kernel for Zen 5 / RTX 50-series support
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

    # Modern Performance and Graphics Flags
    kernelParams = [
      # Prevent data leaks in uninitialized memory
      "init_on_alloc=1"
      "init_on_free=1"
      # Thwart kernel heap exploits
      "slab_nomerge"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"

      # Strict IOMMU for DMA protection (complements USBGuard)
      "intel_iommu=on"
      "amd_iommu=on"
      "iommu.passthrough=0"
      "iommu.strict=1"

      # Disable vsyscalls as they are fixed-address (ASLR bypass)
      "vsyscall=none"

      # No module.sig_enforce / lockdown: NixOS does not sign modules, and the
      # out-of-tree NVIDIA and OpenRazer modules would be refused.

      # GPU
      "amd_pstate=active"
      "acpi_backlight=native"
      "nvidia_wmi_ec_backlight.force=1"
    ];

    # Kernel Security Hardening
    kernel.sysctl = {
      "kernel.unprivileged_bpf_disabled" = 1; # Blocks BPF JIT spraying
      # 1 restricts ptrace to descendants; 2 would also break debuggers (Zed,
      # gdb attach) and Proton's use of ptrace on its own processes.
      "kernel.yama.ptrace_scope" = 1;
      "kernel.dmesg_restrict" = 1;
      "kernel.kptr_restrict" = 2; # Hides kernel pointers from dmesg
    };
  };
}
