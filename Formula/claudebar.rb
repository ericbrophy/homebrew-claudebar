class Claudebar < Formula
  desc "macOS menu bar app for monitoring Claude Code usage limits"
  homepage "https://github.com/ericbrophy/claudebar"
  version "0.2.0"
  url "https://github.com/ericbrophy/homebrew-claudebar/releases/download/v#{version}/claudebar-#{version}-universal.tar.gz"
  sha256 "83db25988d6a8b72f6ba66a0069d74e3ad162413aeeb73768c3f9bee9dbbb5c7"
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
