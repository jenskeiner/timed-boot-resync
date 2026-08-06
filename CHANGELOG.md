# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-06

First release. Initial commit, packaging, CI/release pipeline, and security
hardening for the `timed-boot-resync` Homebrew tap.

### Added
- Root LaunchDaemon (`timed-boot-resync`) that forces a clean NTP resync at boot
  on Apple Silicon Macs that boot with a stale clock after being unplugged from
  mains; leaves correct boots and `timed`'s drift calibration untouched.
- Default, Homebrew-preserved config at `etc/timed-boot-resync.conf`
  (`SERVER`, `TOL`, `MAX_WAIT`).
- Reproducible distribution build (`scripts/build-tarball.sh`): GNU tar with
  sorted entries, epoch mtime, uid/gid 0, plus `gzip -n`. The resulting sha256
  is pinned in the formula and asserted by CI on every push and release.
- Homebrew formula distributed as a tap, with a `--version` self-test.
- CI (shellcheck + reproducible-sha gate), tag-triggered release, and zizmor
  (pedantic) workflows; all third-party actions pinned by commit SHA.
- Gitflow layout (`main` release-only, `develop` for in-progress work), signed
  commits and tags, immutable releases, and immutable `v*` tags.

[Unreleased]: https://github.com/jenskeiner/timed-boot-resync/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/jenskeiner/timed-boot-resync/releases/tag/v1.0.0
