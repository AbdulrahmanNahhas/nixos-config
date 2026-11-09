# TODO: NEED REVIEW AND UNDERSTAND
{
  config,
  pkgs,
  username,
  ...
}:

let
  bookUser = config.users.users.${username};
  bookGroup = bookUser.group;

  bookUid = bookUser.uid;
  bookGid = config.users.groups.${bookGroup}.gid;

  appUrl = "https://books.example.com"; # Change to your actual URL.

  dbPassword = config.sops.secrets.bookorbit_postgres_password.path;
  jwtSecret = config.sops.secrets.bookorbit_jwt_secret.path;
  setupToken = config.sops.secrets.bookorbit_setup_token.path;
in
{
  # ---------------------------------------------------------------------------
  # Secrets
  # ---------------------------------------------------------------------------

  sops.secrets = {
    bookorbit_postgres_password = {
      owner = username;
      group = bookGroup;
      mode = "0400";
    };

    bookorbit_jwt_secret = {
      owner = username;
      group = bookGroup;
      mode = "0400";
    };

    bookorbit_setup_token = {
      owner = username;
      group = bookGroup;
      mode = "0400";
    };
  };

  assertions = [
    {
      assertion = bookUid != null && bookGid != null;
      message = "BookOrbit requires a statically configured UID and GID for ${username}.";
    }
  ];

  # ---------------------------------------------------------------------------
  # Persistent storage
  # ---------------------------------------------------------------------------

  systemd.tmpfiles.rules = [
    "d /var/lib/bookorbit 0750 root root -"
    "d /var/lib/bookorbit/app 0750 ${username} ${bookGroup} -"
    "d /var/lib/bookorbit/postgres 0750 root root -"
  ];

  # ---------------------------------------------------------------------------
  # Containers
  # ---------------------------------------------------------------------------

  virtualisation.oci-containers = {
    backend = "podman";

    containers = {
      # PostgreSQL 18 + pgvector
      bookorbit-db = {
        image = "pgvector/pgvector:pg18";
        autoStart = false;
        pull = "newer";

        environment = {
          POSTGRES_USER = "bookorbit";
          POSTGRES_DB = "bookorbit";
          POSTGRES_PASSWORD_FILE = "/run/secrets/postgres_password";

          PGDATA = "/var/lib/postgresql/data/pgdata";
        };

        volumes = [
          "/var/lib/bookorbit/postgres:/var/lib/postgresql/data"
          "${dbPassword}:/run/secrets/postgres_password:ro"
        ];

        networks = [ "bookorbit" ];

        extraOptions = [
          "--health-cmd=pg_isready -U bookorbit -d bookorbit"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--health-start-period=20s"
          "--security-opt=no-new-privileges:true"
        ];

        # Wait until PostgreSQL actually passes its health check.
        podman.sdnotify = "healthy";
      };

      # BookOrbit
      bookorbit-app = {
        image = "ghcr.io/bookorbit/bookorbit:latest";
        autoStart = false;
        pull = "newer";

        dependsOn = [ "bookorbit-db" ];

        ports = [
          "127.0.0.1:3000:3000"
        ];

        environment = {
          NODE_ENV = "production";

          HOST = "0.0.0.0";
          PORT = "3000";

          APP_URL = appUrl;

          # Database
          DATABASE_URL = "";

          POSTGRES_HOST = "bookorbit-db";
          POSTGRES_PORT = "5432";
          POSTGRES_USER = "bookorbit";
          POSTGRES_PASSWORD = "";
          POSTGRES_PASSWORD_FILE = "/run/secrets/postgres_password";
          POSTGRES_DB = "bookorbit";

          # Application secrets
          JWT_SECRET = "";
          JWT_SECRET_FILE = "/run/secrets/jwt_secret";

          SETUP_BOOTSTRAP_TOKEN = "";
          SETUP_BOOTSTRAP_TOKEN_FILE = "/run/secrets/setup_token";

          # File permissions
          PUID = toString bookUid;
          PGID = toString bookGid;

          # Library configuration
          LIBRARY_BROWSE_ROOT = "/books";
          BOOK_DOCK_PATH = "/data/book-dock";

          # Runtime
          NODE_MAX_OLD_SPACE_SIZE = "2048";
          TZ = "UTC";
        };

        volumes = [
          # Existing library: read-only for safety.
          "/home/${username}/Books:/books:ro"

          # Application data, covers, cache, Book Dock, etc.
          "/var/lib/bookorbit/app:/data"

          # Secrets
          "${dbPassword}:/run/secrets/postgres_password:ro"
          "${jwtSecret}:/run/secrets/jwt_secret:ro"
          "${setupToken}:/run/secrets/setup_token:ro"
        ];

        networks = [ "bookorbit" ];

        # Match upstream Compose security settings.
        capabilities = {
          ALL = false;

          CHOWN = true;
          DAC_OVERRIDE = true;
          FOWNER = true;
          SETGID = true;
          SETUID = true;
        };

        extraOptions = [
          "--init"
          "--read-only"
          "--tmpfs=/tmp:rw,nosuid,size=256m"
          "--security-opt=no-new-privileges:true"
        ];

        # BookOrbit has no upstream container health check.
        podman.sdnotify = "conmon";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Podman network (created only when BookOrbit starts)
  # ---------------------------------------------------------------------------

  systemd.services.bookorbit-network = {
    description = "BookOrbit Podman network";

    before = [
      "podman-bookorbit-db.service"
    ];

    partOf = [ "bookorbit.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      if ! ${pkgs.podman}/bin/podman network exists bookorbit; then
        ${pkgs.podman}/bin/podman network create bookorbit
      fi
    '';
  };

  # ---------------------------------------------------------------------------
  # systemd lifecycle
  # ---------------------------------------------------------------------------

  systemd = {
    # One target controls the complete application stack.
    targets.bookorbit = {
      description = "BookOrbit reading service";

      requires = [
        "podman-bookorbit-app.service"
      ];

      after = [
        "podman-bookorbit-app.service"
      ];
    };

    services = {
      # Database needs the private network.
      "podman-bookorbit-db" = {
        requires = [
          "bookorbit-network.service"
        ];

        after = [
          "bookorbit-network.service"
        ];

        partOf = [ "bookorbit.target" ];
      };

      # Application is stopped/restarted with the target.
      "podman-bookorbit-app".partOf = [
        "bookorbit.target"
      ];
    };
  };
}
