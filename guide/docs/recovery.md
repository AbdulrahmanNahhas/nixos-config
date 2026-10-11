A generation references a particular system closure. Booting an older generation can recover from a broken driver/configuration. A Btrfs snapshot captures local filesystem state at a point in time. An external backup protects against loss of that disk. These mechanisms have different failure boundaries.

These stages do not add external backup jobs or snapshots. Your next recovery priority is a tested encrypted off-device backup of documents, projects, password databases, age recovery identity, and selected app state. Recovery keys cannot exist only on the failed laptop.

## Cleanup on Shadow

Friday’s nh cleanup retains recent generations and leaves explicit GC roots intact using `--no-gcroots`. Nix collects unreachable store paths. Store optimization hard-links identical files afterward. Do not manually delete random store directories or the deduplication index.

Monthly Btrfs scrub verifies checksums across the shared filesystem. A single-device scrub can detect damage but usually cannot repair it without another good copy. SMART gives health indicators, not a guarantee against sudden failure. zRAM compresses memory pages; encrypted disk swap is available as overflow.

## If something breaks

1.  Keep the authenticated terminal open and record the symptom.
2.  If an activation change broke a service, restore a known generation or reboot the previous default after a temporary test.
3.  If a boot change failed, select an older generation from the boot menu.
4.  If user data is damaged, use a data backup; switching generations cannot reconstruct it.
5.  If a key is lost, use the independent recovery identity/backup and rewrap secrets.

### Reinstallation is different from rebuilding

Disko destroy/format operations erase storage. Do not run them to validate a module. Reinstallation must verify the target disk, restore age identities before deploying encrypted users, and preserve a usable rescue path. The disk layout’s name is not authorization to format it.
