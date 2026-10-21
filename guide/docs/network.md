{
"title": "DNS, VPN & the firewall",
"group": "NETWORK & PROTECTION",
"weight": 12,
"sources": [
[
"DNSCrypt configuration reference",
"https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml"
],
[
"NetworkManager reference",
"https://www.networkmanager.dev/docs/api/latest/NetworkManager.conf.html"
],
[
"WireGuard overview",
"https://www.wireguard.com/"
]
],
"build": {
"render": "link",
"list": "always"
}
}

**DNS** translates names to addresses. **DNSCrypt/DoH** encrypts queries to a resolver. **DNSSEC** provides validation-related assurances about DNS data, not secrecy. **HTTPS** protects an application connection. A **VPN** tunnels routed traffic to another network. A **firewall** allows or rejects traffic according to rules.

Encrypted DNS is not anonymity: the resolver still sees queries, and connection destinations can reveal activity. A VPN moves trust to the VPN operator; it does not make logged-in web accounts anonymous. Temporary IPv6 addresses and randomized Wi-Fi MACs reduce some stable network identifiers but do not replace routing or app privacy.

## Shadow’s ownership

NetworkManager manages connections. `dns = "none"` keeps it from replacing the DNS policy. DNSCrypt provides the system resolver. Browser-internal encrypted DNS can bypass that system path, so inspect browser settings when testing. Split-DNS corporate VPNs need deliberate integration rather than assuming a fixed public resolver fits them.

NetworkManager's connection defaults disable sending the laptop hostname to DHCP servers for IPv4 and IPv6. This reduces routine name disclosure alongside MAC randomization. Existing profiles with an explicit hostname-sending choice can override the defaults; this is not packet-level enforcement. Networks using DHCP hostname registration may no longer publish the laptop's name. After activation, reconnect and check the effective profile and lease behavior on the real network. The [NetworkManager connection-default reference](https://www.networkmanager.dev/docs/api/latest/NetworkManager.conf.html) documents this precedence. No stored profiles are rewritten by this change.

The revised configuration listens on both 127.0.0.1 and ::1. Cloudflare and Scaleway remain the deliberately selected resolvers: their catalog stamps advertise DNSSEC, no logging, and no filtering. The require\_\* settings apply only if automatic selection replaces server\_names, so they are not presented as enforcement on those named providers. Resolver bootstrap and endpoint resolution still need network access before the tunnel can connect. Captive portals and filtered networks can behave differently, so connection testing matters.

The resolver catalog and associated signature survive in DNSCrypt's private systemd state directory. This avoids discarding the catalog every reboot but does not create internet access, guarantee an expired catalog is accepted, or preserve the in-memory DNS-answer cache. NetworkManager's internal identity/state is retained alongside its separately preserved connection profiles; Wi-Fi MAC randomization remains enabled. Migrate existing state before first activation and verify DNS/connection behavior afterward.

The hardware module selects iwd as NetworkManager's Wi-Fi backend. iwd keeps saved network credentials in `/var/lib/iwd`, independently of `/etc/NetworkManager/system-connections`; both must survive the tmpfs root reset. Preservation retains iwd's directory with root ownership and mode `0700`. Live inspection found iwd active and its state on tmpfs when Wi-Fi passwords were reported lost after reboot. This closes the missing storage declaration; it still needs migration, activation and a reboot check. Before first activation, copy the current iwd state into `/saved/var/lib/iwd` as root with ownership and permissions preserved. After activation, confirm the mount and reconnect without entering the password, then repeat after reboot. Do not print `.psk` or `.8021x` file contents during diagnosis.

## Firewall direction matters

Closing inbound ports does not block ordinary applications from making outbound connections. A service bound to `127.0.0.1` is local; `0.0.0.0` means all IPv4 interfaces. A broad bind plus a firewall is a different design from a loopback-only service.

Kavita is now configured for loopback only and starts on demand. Its Books mount is read-only, state remains writable, and its old Wi-Fi firewall opening is removed. Open http://127.0.0.1:8083 after starting it with book\_library on. Sharing it later requires a deliberate bind/firewall change. A development server’s convenience flag `--host 0.0.0.0` should be intentional. IPv6 must be considered separately from IPv4.
