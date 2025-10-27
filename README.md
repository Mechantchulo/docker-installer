# Docker Engine Installer for Debian-based systems

This repository contains a simple installation script, `install_docker_linux.sh`, that automates installing Docker Engine and related components on Debian-based systems (Ubuntu and Kali Linux).

## Purpose

The script configures Docker's official APT repository, installs Docker Engine, CLI, containerd, buildx and compose plugins, and adds the invoking user to the `docker` group so Docker can be used without `sudo`.

## Supported distributions

- Ubuntu (uses `lsb_release -cs` for the codename)
- Kali Linux (the script maps Kali to Debian and uses `bookworm` as a fallback codename)

If your distro is neither Ubuntu nor Kali, the script will exit.

## Prerequisites

- A Debian-based system (Ubuntu, Kali as noted above)
- A user with sudo privileges
- Internet connection (to download packages and Docker GPG key)

## Quick start

1. Open a terminal in the project folder (where `install_docker_linux.sh` is located).
2. Make the script executable (optional) and run it with sudo (recommended):

```bash
chmod +x install_docker_linux.sh
sudo ./install_docker_linux.sh
```

Or run it with bash:

```bash
sudo bash install_docker_linux.sh
```

Notes:
- The script uses `sudo` internally for package installation and system changes, so you will be prompted for your password.
- The script detects the distribution using `/etc/os-release`. For Kali it maps to Debian/bookworm by design.

## What the script does (high-level)

1. Detects the OS and sets a codename for apt sources.
2. Installs prerequisite packages (`ca-certificates`, `curl`, `gnupg`, `lsb-release`).
3. Adds Docker's official GPG key to `/etc/apt/keyrings/docker.gpg`.
4. Adds the official Docker APT repository to `/etc/apt/sources.list.d/docker.list`.
5. Installs Docker Engine components: `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`.
6. Runs `docker run hello-world` to verify the installation.
7. Adds the invoking user (value of `DOCKER_USER` variable in the script) to the `docker` group.

## Post-install steps

- To apply the new group membership you must either log out and log back in, or run:

```bash
newgrp docker
```

- If `docker run hello-world` succeeded during the script, Docker is working. If it failed due to permissions, ensure you completed the group membership step and re-login.

## Variables / customization

- The script sets `DOCKER_USER=$(whoami)` at the top. If you want to add a different user to the `docker` group, edit the script or export a different value before running (e.g. `DOCKER_USER=alice sudo bash install_docker_linux.sh`).

## Troubleshooting

- GPG key or repository errors:
  - Ensure the machine has network access and can reach `download.docker.com`.
  - Check that `/etc/apt/keyrings/docker.gpg` exists and is readable.

- APT package not found or wrong codename:
  - The script determines the codename automatically. For custom setups you can edit the `VERSION_CODENAME` value in the script.

- Permission denied when running `docker`:
  - Make sure your user is in the `docker` group. Either log out and back in or run `newgrp docker`.

- `docker run hello-world` fails even after group change:
  - Try `sudo docker run hello-world` to verify Docker itself runs with root privileges.
  - Check `sudo systemctl status docker` for service status and logs.

## Safety & notes

- The script uses `sudo` to install system packages and modify system files — run it only on machines you control and trust.
- The script currently only supports Ubuntu and Kali (via Debian mapping). If you need other distros, update the distro detection logic.

## Where to look next

- If you want to run Docker as a system service or enable it at boot: `sudo systemctl enable --now docker`
- For more Docker configuration and usage, see Docker's official docs: https://docs.docker.com/


