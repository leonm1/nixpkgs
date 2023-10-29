{ lib
, pkgs
, config
, ...
}:

with lib;

let
  cfg = config.services.matter-server;
in

{
  meta.maintainers = with lib.maintainers; [ hexa ];

  options.services.matter-server = with types; {
    enable = mkEnableOption (lib.mdDoc "Matter-server");

    package = mkOption {
      type = types.package;
      default = pkgs.python-matter-server;
      defaultText = literalExpression "pkgs.python-matter-server";
      description = "Package containing the matter-server executable.";
    };

    port = mkOption {
      type = types.port;
      default = 5580;
      defaultText = "5580";
      description = "Port to expose the matter-server service on.";
    };

    vendorId = mkOption {
      type = types.ints.u16;
      default = 4939; # Home Assistant
      defaultText = "4939 (Home Assistant)";
      description = "CSA Vendor ID to advertise to devices on the network.";
    };

    fabricId = mkOption {
      type = types.int;
      default = 1;
      defaultText = "4939 (Home Assistant)";
      description = "CSA Vendor ID to advertise to devices on the network.";
    };

    storagePath = mkOption {
      type = types.nonEmptyStr;
      default = "matter-server";
      description = mdDoc "Directory name under `/var/lib/` to store persistent data. Specifying `\"matter-server\"` indicates the directory `/var/lib/matter-server`";
    };

    logLevel = mkOption {
      type = types.enum [ "critical" "error" "warning" "info" "debug" ];
      default = "info";
      description = "Verbosity of logs from the matter-server";
    };

    extraArgs = mkOption {
      type = listOf str;
      default = [];
      description = "Extra arguments to pass to the matter-server executable.";
    };
  };

  config = mkIf cfg.enable {
    services.avahi.enable = true;

    systemd.services.matter-server = {
      after = [
        "network-online.target"
        "avahi-daemon.target"
      ];
      wantedBy = [
        "multi-user.target"
        "home-assistant.target"
      ];
      description = "Matter Server";
      environment.HOME = "/var/lib/${cfg.storagePath}";
      serviceConfig = {
        ExecStart = (concatStringsSep " " [
          "${cfg.package}/bin/matter-server"
          "--port" (toString cfg.port)
          "--vendorid" (toString cfg.vendorId)
          "--fabricid" (toString cfg.fabricId)
          "--storage-path" "/var/lib/${cfg.storagePath}"
          "--log-level" "${cfg.logLevel}"
          "${escapeShellArgs cfg.extraArgs}"
        ]);
        TemporaryFileSystem = "/data:rw /var/lib:ro";
        BindPaths = "/var/lib/${cfg.storagePath}:/data";
        StateDirectory = "${cfg.storagePath}";
        ReadOnlyPaths = "/run/dbus";

        # Hardening bits
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges=true;
        PrivateDevices=true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups= true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" "AF_BLUETOOTH" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID= true;
        UMask = "0077";
      };
    };
  };
}

