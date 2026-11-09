{ config, ... }:
{
  # RTX 5060 Blackwell CUDA architecture.
  nixpkgs.config.cudaCapabilities = [ "12.0" ];

  hardware.graphics.enable = true;

  # Loads the NVIDIA driver module; does not enable an X11 desktop.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Use Razer PRIME/runtime-PM defaults; retest after offload and resume.
  hardware.nvidia = {
    # Match this kernel's driver; validate runtime D3 after driver updates.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    open = true;
    modesetting.enable = true;

    nvidiaSettings = true;

    # Do not deliberately keep an otherwise idle dGPU initialized.
    nvidiaPersistenced = false;
  };
}
