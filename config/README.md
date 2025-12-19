# Configuration Files

## config.toml
Configuration file for [Atuin](https://github.com/atuinsh/atuin) - shell history sync and search tool.

This file is automatically used by Atuin when placed in `~/.config/atuin/config.toml`.

## gpg-agent.conf (macOS)
GPG agent configuration for macOS with YubiKey support.

**Platform:** macOS only

This file is automatically deployed to `~/.gnupg/gpg-agent.conf` by the ZSHRC installation script.

### Features:
- `pinentry-mac` - macOS-specific pinentry program with GUI
- `enable-ssh-support` - Use GPG agent as SSH agent (for YubiKey SSH keys)
- Cache TTL settings for convenience/security balance

## YubiKey Support (macOS only)

YubiKey configuration is only needed on your macOS machine. The ZSHRC script installs:

### macOS Packages:
- `gnupg` - GPG suite with scdaemon for YubiKey communication
- `pinentry-mac` - GUI pinentry program for PIN entry

### Configuration:
The `gpg-agent.conf` file is automatically deployed to `~/.gnupg/gpg-agent.conf` with:
- `pinentry-mac` - macOS-specific pinentry with GUI
- `enable-ssh-support` - Use GPG agent as SSH agent (for YubiKey SSH keys)
- Cache TTL settings for convenience/security balance

### Linux Remote Servers:
The BASHRC script for Linux does **not** configure GPG/YubiKey because:
- Linux machines are accessed remotely via SSH from macOS
- GPG operations are forwarded from your macOS client through SSH agent forwarding
- No local pinentry or YubiKey access is needed on remote servers

### Testing Your YubiKey (on macOS):
```bash
gpg --card-status
```

### Troubleshooting (on macOS):
If your YubiKey is not detected:
```bash
# Restart the GPG agent
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```
