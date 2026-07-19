class Claudebar < Formula
  desc "macOS menu bar app for monitoring Claude Code usage limits"
  homepage "https://github.com/ericbrophy/claudebar"
  version "0.6.0"
  url "https://github.com/ericbrophy/homebrew-claudebar/releases/download/v#{version}/claudebar-#{version}-universal.tar.gz"
  sha256 "cb53531c50747afa754ca86adf141275e41d4510c513c74127470a3e47d7cb18"
  license "MIT"

  depends_on macos: :ventura

  def install
    libexec.install "ClaudeBar.app"
    # GUI launches go through the stable opt symlink via LaunchServices (`open`)
    # so the app runs as a proper bundle and SMAppService can present it as
    # "ClaudeBar" in Login Items. The `--snapshot` CLI path must stay attached
    # to stdout, so it execs the inner binary directly.
    (bin/"claudebar").write <<~SH
      #!/bin/bash
      app="#{opt_libexec}/ClaudeBar.app"
      if [ "$1" = "--snapshot" ]; then
        exec "$app/Contents/MacOS/ClaudeBar" "$@"
      fi
      exec open "$app"
    SH
    (bin/"claudebar").chmod 0755
  end

  def caveats
    s = <<~EOS
      ClaudeBar runs from your menu bar. Launch it once to finish setup:
        claudebar
      (or: open #{opt_libexec}/ClaudeBar.app)

      On first launch it asks whether to start at login; change this any time
      in ClaudeBar -> Preferences. After a `brew upgrade`, open ClaudeBar once
      so it refreshes its login-item registration.
    EOS
    legacy = "#{Dir.home}/Library/LaunchAgents/homebrew.mxcl.claudebar.plist"
    if File.exist?(legacy)
      s += <<~EOS

        This version no longer uses `brew services`. Remove the old background
        agent (the item that shows your developer name in Login Items):
          brew services stop claudebar 2>/dev/null || true
          launchctl bootout gui/$(id -u)/homebrew.mxcl.claudebar 2>/dev/null || \\
            launchctl unload -w #{legacy} 2>/dev/null || true
          rm -f #{legacy}
      EOS
    end
    s
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
