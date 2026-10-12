{ config, ... }:
{
  # RTX 5060 Blackwell CUDA architecture.
  nixpkgs.config.cudaCapabilities = [ "12.0" ];

  hardware.graphics.enable = true;

  # Loads the NVIDIA driver module; does not enable an X11 desktop.
  services.xserver.videoDrivers = [ "nvidia" ];

  # The selected Razer nixos-hardware module owns PRIME and runtime-PM defaults.
  # Recheck GPU suspension after offload, external displays and resume.
  hardware.nvidia = {
    # In this pin, beta is older than the working 615 driver. Review on updates.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    open = true;
    modesetting.enable = true;

    nvidiaSettings = true;

    # Do not deliberately keep an otherwise idle dGPU initialized.
    nvidiaPersistenced = false;
  };
}
