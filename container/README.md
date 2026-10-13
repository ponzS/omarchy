# Omarchy desktop image for LightOS

This directory builds an x86_64 OCI image from the Omarchy 4.0.4 source in this fork. It includes Hyprland, Quickshell, SDDM, the base programs LightOS needs to start a systemd container, working package installation tools, and common desktop applications. The upstream kernel, bootloader and disk snapshot dependencies are omitted because the host supplies the kernel and LightOS supplies the container rootfs.

The [workflow](../.github/workflows/lightos-oci.yml) publishes `ghcr.io/ponzs/omarchy:lightos-core-4.0.4-r3` and updates `ghcr.io/ponzs/omarchy:lightos-core-4.0.4`, the stable tag used by LightOS. It packages the checked-out commit and records that revision in the image label. Keep the GHCR package public so LightOS can pull it without registry credentials. Existing instances retain their rootfs and are not automatically upgraded when a tag changes.

In LightOS, choose the **Omarchy 4.0.4** preset and GHCR, or choose **Custom Image** and enter the revision tag above. Create the instance with a non-root username and password. On first boot, LightOS creates the requested user from Omarchy's `/etc/skel` and applies its normal instance setup. When display takeover is enabled, the image starts a password-protected login on the VT allocated by LightOS. Logging in there starts the Omarchy desktop. Remote desktop installation and activation remain manual LightOS actions.

## Included software

The container package's `depends` in [PKGBUILD](PKGBUILD) is the runtime dependency list. Installation tools include `xdg-terminal-exec`, `fzf`, `yay`, `base-devel`, and `plocate`. Both menu installation and terminal installation are available; AUR packages build as the ordinary user before privileged installation.

Preinstalled applications include Google Chrome, Foot, Nautilus, Neovim, imv, mpv, btop, and dua. Clipboard, screenshot, search, archive, and common shell tools are included as well. Chrome is the default browser for new users and opens the supplied web application shortcuts. User finalization preserves an existing browser choice.

Chrome is built as a normal pacman package by an unprivileged build-stage user from a pinned [AUR recipe](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=google-chrome&id=22f911574697bc9a89160773f0f6c7828ab3d06d). `makepkg` verifies the recipe's checksums for the binary downloaded from Google. Change `GOOGLE_CHROME_AUR_COMMIT` in the Dockerfile when reviewing a Chrome update. Chrome's sandbox remains enabled.

The Omarchy package is pinned in pacman to retain the container dependency set; update this directory when publishing a later Omarchy release. The package release is `4.0.4-2`, and the packaged Omarchy version file reports `4.0.4`.

## Build and publish

The same build can be performed locally when a GitHub-hosted runner is unavailable:

```bash
docker build --platform linux/amd64 --provenance=false \
  --label "org.opencontainers.image.revision=$(git rev-parse HEAD)" \
  -f container/Dockerfile -t ghcr.io/ponzs/omarchy:lightos-core-4.0.4-r3 .
docker push ghcr.io/ponzs/omarchy:lightos-core-4.0.4-r3
```

After verifying the image, tag and push the same image as `ghcr.io/ponzs/omarchy:lightos-core-4.0.4`. Synchronize it to LightOS's existing Docker Hub distribution tag `docker.io/ponzs/omarchy:lightos-core-4.0.4` and compare manifest, configuration, and layer digests across the two registries.

## Manual validation

Use the newly built image to create an instance and enable its remote desktop through LightOS. Open Chrome, a supplied web application shortcut, Files, Foot, Neovim, imv, mpv, and btop. Verify that the default browser remains Chrome after first-login setup.

Open **Install > Package**, choose a small package that is not installed, authorize the install, and run the installed program. Repeat from the terminal. Open **Install > AUR**, choose a small available AUR package, and verify real source download, user-owned compilation, installation, and execution. Canceling a picker must leave without reporting a completed installation; an installation error must return failure.

The confirmed requirements and acceptance scenarios are in [spec/desktop/software-installation](../spec/desktop/software-installation/). They remain draft until the new-instance scenarios have been validated. No automated device scenarios are added by this change.

LightOS resets the Arch pacman keyring on first boot. This image enables a service that restores the Omarchy signing key after that setup finishes.

The desktop setup service grants the instance user access to the mapped GPU and starts seatd without switching VTs. It reads the actual VT from LightOS's `/dev/tty0` mapping so other instances' display terminals are left alone.

This image does not include the entire ISO application collection and does not run the ISO's disk installer, bootloader setup, or hardware configuration. Image build checks do not replace verification of physical display and remote desktop behavior on the target LightOS device.
