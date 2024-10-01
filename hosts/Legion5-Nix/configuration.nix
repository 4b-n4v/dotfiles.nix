# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/nixos/main-user.nix
      inputs.home-manager.nixosModules.default
    ];

  main-user = {
    enable = true;
    userName = "n4v";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Legion5-Nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; 

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Matamoros";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  #Enable OpenGL

  hardware.graphics = {
    enable = true;
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  # Enable nvidia proprietary drives.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Special nvidia settings (thanks nvidia)
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Enable if graphical corruption issues or application crashes after waking up from sleep.
    powerManagement.enable = true;

    # Turn of GPU when not in use.
    powerManagement.finegrained = false;

    # Use the nvidia open source kernel module.
    open = false;

    prime = {
      # Enable for offload mode.
      # Puts nvidia GPU to sleep and lets the intel gpu handle all tasks
      # Then you can offload an app to a GPU if it requires it.

      # offload = {
      #   enable = true;
      #   enableOffloadCmd = true;
      # };

      # Enable for sync mode(default)
      # Better performance and greatly reduces screen-tearing.
      # Higher power-consumption since the nvidia gpu will not go
      # to sleep unless called for.

      # DUDE DISABLE THIS IF YOURE GONNA USE OFFLOAD
      sync.enable = true;


      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

    };

  };

  # Specialization for clamshell mode (If PRIME sync is enabled)
  specialisation = {
    on-the-go.configuration = {
      system.nixos.tags = [ "on-the-go" ];
      hardware.nvidia = {
        prime.offload.enable = lib.mkForce true;
        prime.offload.enableOffloadCmd = lib.mkForce true;
        prime.sync.enable = lib.mkForce false;
      };
    };
  };


  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.n4v = {
    isNormalUser = true;
    description = lib.mkForce "Angelo Brian Navilon";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "n4v" = import ./home.nix;
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    zoxide
    neovim
    keyd
    lshw
    kitty
    git
    zsh
    oh-my-zsh
    pika-backup
    borgbackup
    wl-clipboard
    neofetch
    stow
    eza
    zellij
    clang
    cmake
    fzf
    github-cli
    btop
    lazygit
    meson
    ncdu
    nodejs
    obs-studio
    python3
    ripgrep
    unzip
  ];
  # Set neovim as the main editor
  environment.variables.EDITOR = "nvim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Keyd keyboard daemon for linux
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            # Control does not have to be held to be activated
            # control = "oneshot(control)";
            # Right alt does not have to be held to be activated
            # rightalt = "oneshot(altgr)";
            # Capslock is control when held, escape when pressed
             capslock = "overload(control, esc)";
            # Compose is capslock
            compose = "capslock";
            # insert = "s-insert";
          };
        };
      };
    };
  };
  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "zoxide" ];
      theme = "ys";
    };
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
