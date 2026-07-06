# Homebrew tap for claudebar

```sh
brew install ericbrophy/claudebar/claudebar
claudebar   # launch once; it offers to start at login
```

ClaudeBar registers its own macOS login item (no `brew services` needed). After
`brew upgrade`, open ClaudeBar once so it refreshes that registration. Upgrading
from a `brew services` install? See the `brew info claudebar` caveats for the
one-time cleanup of the old background agent.

This tap hosts publicly-installable macOS binaries for
[claudebar](https://github.com/ericbrophy/claudebar). The claudebar
source repository is private; release artifacts are mirrored here for
Homebrew users.
