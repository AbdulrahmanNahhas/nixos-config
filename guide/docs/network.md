**DNS** translates names to addresses. **DNSCrypt/DoH** encrypts queries to a resolver. **DNSSEC** provides validation-related assurances about DNS data, not secrecy. **HTTPS** protects an application connection. A **VPN** tunnels routed traffic to another network. A **firewall** allows or rejects traffic according to rules.

Encrypted DNS is not anonymity: the resolver still sees queries, and connection destinations can reveal activity. A VPN moves trust to the VPN operator; it does not make logged-in web accounts anonymous. Temporary IPv6 addresses and randomized Wi-Fi MACs reduce some stable network identifiers but do not replace routing or app privacy.

## Shadow’s ownership

NetworkManager manages connections. `dns = "none"` keeps it from replacing the DNS policy. DNSCrypt provides the system resolver. Browser-internal encrypted DNS can bypass that system path, so inspect browser settings when testing. Split-DNS corporate VPNs need deliberate integration rather than assuming a fixed public resolver fits them.

The revised configuration listens on both 127.0.0.1 and ::1. Cloudflare and Scaleway remain the deliberately selected resolvers: their catalog stamps advertise DNSSEC, no logging, and no filtering. The require\_\* settings apply only if automatic selection replaces server\_names, so they are not presented as enforcement on those named providers. Resolver bootstrap and endpoint resolution still need network access before the tunnel can connect. Captive portals and filtered networks can behave differently, so connection testing matters.

## Firewall direction matters

Closing inbound ports does not block ordinary applications from making outbound connections. A service bound to `127.0.0.1` is local; `0.0.0.0` means all IPv4 interfaces. A broad bind plus a firewall is a different design from a loopback-only service.

Kavita is now configured for loopback only and starts on demand. Its Books mount is read-only, state remains writable, and its old Wi-Fi firewall opening is removed. Open http://127.0.0.1:8083 after starting it with book\_library on. Sharing it later requires a deliberate bind/firewall change. A development server’s convenience flag `--host 0.0.0.0` should be intentional. IPv6 must be considered separately from IPv4.
