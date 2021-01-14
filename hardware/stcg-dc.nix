{ lib, pkgs, ... }: {

  imports = [ ./efi.nix ./no-mitigations.nix ./nvidia.nix ];

  boot = rec {
    initrd.availableKernelModules =
      [ "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
    tmpOnTmpfs = true;
  };

  environment.etc."ssh/trusted-user-ca-keys.pem".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIp2RJ3NO56nVsgMmaCTGCLCizqa6d8VrQxTAOYoYBAP Development";
  services.openssh.extraConfig = ''
    TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
  '';

  hardware.enableRedistributableFirmware = true;

  nix = {
    maxJobs = 64;
    systemFeatures = [ "benchmark" "nixos-test" "big-parallel" "kvm" "gccarch-skylake" ];
  };

  nixpkgs.localSystem.system = "x86_64-linux";

  security.pam.loginLimits = [
    { domain = "*"; type = "-"; item = "nofile"; value = "1048576"; }
  ];

  services.fstrim.enable = true;
  services.sshguard.enable = lib.mkForce false;
}
