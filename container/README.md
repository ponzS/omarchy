# Omarchy core image for LightOS

This directory builds an x86_64 OCI image from the Omarchy 4.0.4 source in this fork. The image includes the Omarchy runtime package, its packaged user defaults, Hyprland, Quickshell, SDDM, and the base programs LightOS needs to start a systemd container. The upstream bootloader and disk snapshot dependencies are omitted because the host supplies the kernel and LightOS supplies the container rootfs.

The image can be published by [the workflow](../.github/workflows/lightos-oci.yml) as `ghcr.io/ponzs/omarchy:lightos-core-4.0.4`. The workflow packages the checked-out commit. The Omarchy package is pinned in pacman to retain the container specific dependency set; update this directory when publishing a later Omarchy release. Make the GHCR package public after its first publication so LightOS can pull it without registry credentials.

In LightOS, choose **Custom Image**, enter `ghcr.io/ponzs/omarchy:lightos-core-4.0.4`, and create the instance with a non-root username and password. The image reference already contains its registry. On first boot, LightOS creates the requested user from Omarchy's `/etc/skel` and applies its normal instance setup. After the instance starts, use its terminal to inspect the Omarchy installation.

LightOS resets the Arch pacman keyring on first boot. This image enables a service that restores the Omarchy signing key after that setup finishes.

This core image does not include the entire ISO application collection. It also does not run the ISO's disk installer, bootloader setup, or hardware configuration. Physical display and browser remote desktop behavior are separate follow-up work; an OCI image alone cannot prove either one works on a particular device.
