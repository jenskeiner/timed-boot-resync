class TimedBootResync < Formula
  desc "Force an NTP resync at boot on Apple Silicon Macs with a stale clock"
  homepage "https://github.com/jenskeiner/timed-boot-resync"
  url "https://github.com/jenskeiner/timed-boot-resync/releases/download/v1.0.0/timed-boot-resync-1.0.0.tar.gz"
  # sha256 is pinned to the canonical reproducible build produced in CI (ubuntu, GNU tar + gzip -n).
  sha256 "007a0ae9c2ad47d5b8a5b0e8b0fc43e7503f9e5f05e47f020f906e3a9657cd96"
  license "MIT"
  head "https://github.com/jenskeiner/timed-boot-resync.git", branch: "main"

  depends_on :macos

  def install
    sbin.install "timed-boot-resync"
    (sbin/"timed-boot-resync").chmod 0755
    etc.install "timed-boot-resync.conf" # Homebrew preserves edits on upgrade
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
