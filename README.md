# timed-boot-resync

> A Homebrew tap for Apple Silicon Macs that boot with a wrong clock after being unplugged from mains.

Apple Silicon desktops have no RTC coin-cell backup. When unplugged from mains
while powered off, the clock loses its reference and boots into the past, and
macOS's `timed` then reloads a stale model and rejects the correct NTP time for
roughly an hour before self-correcting.

**timed-boot-resync** installs a root LaunchDaemon that, at every boot, waits
for the network, measures the NTP offset **once**, and — *only if* the clock
booted more than a couple of seconds off — clears `timed`'s stale saved state,
restarts `timed`, and hard-sets the clock from NTP. Correct boots are left
untouched, so `timed`'s normal drift calibration is preserved.

## Install

This package is distributed as a Homebrew **tap** (modern Homebrew no longer
allows installing a formula directly from an HTTPS URL):

```bash
brew tap jenskeiner/timed-boot-resync https://github.com/jenskeiner/timed-boot-resync
brew install jenskeiner/timed-boot-resync/timed-boot-resync
```

The formula pins a `sha256` that is verified against the GitHub Release tarball.

## Enable the service

```bash
sudo brew services start timed-boot-resync
```

`sudo` is required because the LaunchDaemon runs as **root** (it must write to
`/var/db/timed` and hard-set the system clock).

## Configure

Set your NTP server (default `time.apple.com`) in:

```
$(brew --prefix)/etc/timed-boot-resync.conf
```

A LAN NTP server (e.g. your router) is often reachable earliest at boot, before
DNS/WAN.

## Logs

```
/var/log/timed-boot-resync.log      # daemon activity
/var/log/timed-boot-resync.out      # LaunchDaemon stdout
/var/log/timed-boot-resync.err      # LaunchDaemon stderr
```

## How it works

1. Waits up to `MAX_WAIT` (~2 s) loops for a default route **and** a reachable NTP server.
2. Measures the offset once via `sntp`.
3. If within `TOL` seconds: exits, leaving `timed` untouched.
4. If beyond `TOL` seconds: removes `timed`'s stale state
   (`/var/db/timed/com.apple.timed.plist` and `/var/db/timed/Library`),
   `launchctl kickstart -k system/com.apple.timed`, then `sntp -sS` to hard-set.

## Security notes

- Runs as **root** from `/Library/LaunchDaemons`. Review the script before
  enabling: [`src/timed-boot-resync`](src/timed-boot-resync).
- The only network operation is an NTP query to the configured `SERVER`.
- No telemetry; no outbound connections beyond NTP.

## Releases

Releases are reproducible: the distribution tarball is built in CI with GNU tar
(sorted entries, epoch mtime, uid/gid 0) + `gzip -n`, so its `sha256` is stable
and pinned in the formula. CI asserts the rebuilt sha matches on every push and
on release. See [`.github/workflows/ci.yml`](.github/workflows/ci.yml) and
[`.github/workflows/release.yml`](.github/workflows/release.yml).

## License

MIT © Jens Keiner. See [LICENSE](LICENSE).
