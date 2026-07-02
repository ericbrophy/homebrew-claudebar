class Claudebar < Formula
  desc "macOS menu bar app for monitoring Claude Code usage limits"
  homepage "https://github.com/ericbrophy/claudebar"
  version "0.3.0"
  url "https://github.com/ericbrophy/homebrew-claudebar/releases/download/v#{version}/claudebar-#{version}-universal.tar.gz"
  sha256 "451a65d0bf1daef0b9ec368f25b6aa45973c9d8701db0aac04c5657934ba9ff4"
  license "MIT"

  depends_on :macos
  depends_on macos: :ventura

  def install
    libexec.install "ClaudeBar.app"
    (bin/"claudebar").write <<~SH
      #!/bin/bash
      exec "#{libexec}/ClaudeBar.app/Contents/MacOS/ClaudeBar" "$@"
    SH
    (bin/"claudebar").chmod 0755
  end

  service do
    # Run the bundle's binary directly so macOS associates the running
    # process with the .app — surfaces the app icon and display name in
    # Activity Monitor, Force Quit, and Spotlight.
    run [opt_libexec/"ClaudeBar.app/Contents/MacOS/ClaudeBar"]
    keep_alive true
    log_path var/"log/claudebar.log"
    error_log_path var/"log/claudebar.log"
  end

  test do
    assert_predicate libexec/"ClaudeBar.app/Contents/MacOS/ClaudeBar", :exist?
    assert_predicate libexec/"ClaudeBar.app/Contents/MacOS/ClaudeBar", :executable?
    assert_predicate bin/"claudebar", :executable?
    assert_match "ClaudeBar",
                 shell_output("/usr/bin/plutil -extract CFBundleName raw " \
                              "#{libexec}/ClaudeBar.app/Contents/Info.plist").strip
  end
end
