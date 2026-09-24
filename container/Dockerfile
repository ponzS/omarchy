FROM docker.io/library/archlinux:base AS package

RUN pacman -Syu --noconfirm --needed base-devel git \
  && useradd -m builder \
  && mkdir -p /work/source /work/pkg
COPY bin/ /work/source/bin/
COPY default/libalpm/hooks/ /work/source/default/libalpm/hooks/
COPY install/ /work/source/install/
COPY migrations/ /work/source/migrations/
COPY shell/ /work/source/shell/
COPY themes/ /work/source/themes/
COPY version /work/source/version
COPY container/PKGBUILD /work/pkg/PKGBUILD
RUN chown -R builder:builder /work \
  && su builder -s /bin/bash -c 'cd /work/pkg && OMARCHY_SRC=/work/source makepkg --nodeps --noconfirm --clean'

FROM docker.io/library/archlinux:base

LABEL org.opencontainers.image.source="https://github.com/ponzS/omarchy" \
  org.opencontainers.image.title="Omarchy for LightOS" \
  org.opencontainers.image.version="4.0.4" \
  org.opencontainers.image.description="Omarchy core desktop in an Arch Linux container rootfs"

COPY --from=package /work/pkg/omarchy-4.0.4-1-x86_64.pkg.tar.zst /tmp/omarchy.pkg.tar.zst
COPY container/lightos-omarchy-keyring.service /etc/systemd/system/lightos-omarchy-keyring.service

RUN set -eu; \
  printf '%s\n' 'Server = https://stable-mirror.omarchy.org/$repo/os/$arch' > /etc/pacman.d/mirrorlist; \
  pacman-key --init; \
  pacman-key --populate archlinux; \
  pacman -Syyuu --noconfirm --needed archlinux-keyring ca-certificates curl gnupg; \
  curl -fsSL 'https://keys.openpgp.org/vks/v1/by-fingerprint/40DFB630FF42BCFFB047046CF0134EE680CAC571' -o /tmp/omarchy-signing-key.asc; \
  test "$(gpg --show-keys --with-colons /tmp/omarchy-signing-key.asc | awk -F: '$1 == "fpr" { print $10; exit }')" = '40DFB630FF42BCFFB047046CF0134EE680CAC571'; \
  pacman-key --add /tmp/omarchy-signing-key.asc; \
  pacman-key --lsign-key 40DFB630FF42BCFFB047046CF0134EE680CAC571; \
  printf '\n%s\n%s\n' '[omarchy]' 'Server = https://pkgs.omarchy.org/stable/$arch' >> /etc/pacman.conf; \
  pacman -Syyuu --noconfirm --needed \
    omarchy-keyring omarchy-settings \
    systemd systemd-sysvcompat dbus sudo shadow openssh \
    hyprland quickshell uwsm sddm xdg-desktop-portal-hyprland \
    wireplumber pipewire gnome-keyring gum jq git perl fakeroot pacman-contrib \
    ttf-jetbrains-mono-nerd-basic foot fastfetch \
    pipewire-pulse xdg-desktop-portal-gtk; \
  pacman -U --noconfirm /tmp/omarchy.pkg.tar.zst; \
  sed -i '/^\[options\]/a IgnorePkg = omarchy' /etc/pacman.conf; \
  systemctl enable systemd-resolved.service; \
  systemctl enable lightos-omarchy-keyring.service; \
  rm -f /tmp/omarchy.pkg.tar.zst /tmp/omarchy-signing-key.asc; \
  pacman -Scc --noconfirm

CMD ["/sbin/init"]
