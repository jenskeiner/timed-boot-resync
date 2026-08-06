class TimedBootResync < Formula
  desc "Force a clean NTP resync at boot on Apple Silicon Macs that lose RTC time when unplugged"
  homepage "https://github.com/jenskeiner/macos-timed-sync"
  url "https://github.com/jenskeiner/macos-timed-sync/releases/download/v1.0.0/timed-boot-resync-1.0.0.tar.gz"
  version "1.0.0"
  # sha256 is pinned to the canonical reproducible build produced in CI (ubuntu, GNU tar + gzip -n).
  sha256 "8d2b8d298eebf6bd0c3e5628ca47f83ea32b5f875d4d51eea790f46b07b7dff5"
  license "MIT"
  head "https://github.com/jenskeiner/macos-timed-sync.git", branch: "main"

  depends_on :macos

  def install
    sbin.install "timed-boot-resync"
    (sbin/"timed-boot-resync").chmod 0755
    etc.install "timed-boot-resync.conf"   # Homebrew preserves edits on upgrade
    doc.install "README.md", "LICENSE"
  end

  service do
    run [opt_sbin/"timed-boot-resync"]
    require_root true        # installs to /Library/LaunchDaemons, runs as root
    run_type :immediate      # RunAtLoad: fire once at boot
    keep_alive false         # one-shot; do not relaunch after it exits
    log_path "/var/log/timed-boot-resync.out"
    error_log_path "/var/log/timed-boot-resync.err"
  end

  def caveats
    <<~EOS
      This installs a ROOT LaunchDaemon that corrects the clock at every boot.
      Enable it (sudo is required because it runs as root):

        sudo brew services start timed-boot-resync

      Set your NTP server (default time.apple.com) in:

        #{etc}/timed-boot-resync.conf

      Activity log: /var/log/timed-boot-resync.log
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{sbin}/timed-boot-resync --version")
    assert_predicate sbin/"timed-boot-resync", :executable?
  end
end
