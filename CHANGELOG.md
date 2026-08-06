# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-06

### Added
- Root LaunchDaemon (`timed-boot-resync`) that forces a clean NTP resync at boot.
- Default config at `etc/timed-boot-resync.conf` (`SERVER`, `TOL`, `MAX_WAIT`).
- Reproducible build script (`scripts/build-tarball.sh`).
- Homebrew formula distributed as a tap, with the release tarball sha256 pinned.
- CI (lint + reproducible-sha gate), release, and zizmor workflows.
- Gitflow layout (`main` release-only, `develop` for in-progress work).

[Unreleased]: https://github.com/jenskeiner/timed-boot-resync/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/jenskeiner/timed-boot-resync/releases/tag/v1.0.0
