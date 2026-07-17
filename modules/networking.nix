# Encrypted DNS using dnscrypt-proxy.
# See https://wiki.nixos.org/wiki/Encrypted_DNS

let
  hasIPv6Internet = true;
  stateDirectory = "dnscrypt-proxy";
in
{
  services.dnscrypt-proxy = {
    enable = true;

    # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
    settings = {
      listen_addresses = [ "127.0.0.1:53" ];

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];

        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        cache_file = "/var/lib/${stateDirectory}/public-resolvers.md";
      };

      # IPv4 / IPv6
      ipv4_servers = true;
      ipv6_servers = hasIPv6Internet;
      block_ipv6 = !hasIPv6Internet;

      # Protocols
      dnscrypt_servers = true;
      doh_servers = true;
      odoh_servers = false;

      # Security requirements
      require_dnssec = true;
      require_nolog = false;
      require_nofilter = true;

      # Prevent local hostname leaks
      block_unqualified = true;
      block_undelegated = true;

      # Cache
      cache = true;
      cache_size = 4096;

      cache_min_ttl = 2400;
      cache_max_ttl = 86400;

      cache_neg_min_ttl = 60;
      cache_neg_max_ttl = 600;
    };
  };

  systemd.services.dnscrypt-proxy.serviceConfig.StateDirectory = stateDirectory;
}
