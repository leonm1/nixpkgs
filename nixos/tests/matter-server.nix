import ./make-test-python.nix ({ pkgs, lib, ...} :

let
  chipVersion = pkgs.python311Packages.home-assistant-chip-core.version;
in

{
  name = "matter-server";
  meta.maintainers = with lib.maintainers; [ hexa ];

  nodes = {
    machine = { config, ... }: {
      services.matter-server = {
        enable = true;
        fabricId = 7654;
        port = 1234;
        storagePath = "test-matter-server";
      };
    };
  };

  testScript = /* python */ ''
    start_all()

    machine.wait_for_unit("matter-server.service")
    machine.wait_for_open_port(1234)


    with subtest("Check websocket server initialized"):
        output = machine.succeed("echo \"\" | ${pkgs.websocat}/bin/websocat ws://localhost:1234/ws")
        machine.log(output)

        with subtest("Check CHIP version \"${chipVersion}\" present in websocket message"):
            assert '"sdk_version": "${chipVersion}"' in output

        with subtest("Check fabric ID propagates to server"):
            assert '"fabric_id": 7654' in output

    with subtest("Check storage directory is created"):
        machine.succeed("ls /var/lib/test-matter-server/chip.json")

    with subtest("Check systemd hardening"):
        _, output = machine.execute("systemd-analyze security matter-server.service | grep -v '✓'")
        machine.log(output)
  '';
})
