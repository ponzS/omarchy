FROM docker.io/library/archlinux:base AS build

RUN printf '%s\n' 'Server = https://stable-mirror.omarchy.org/$repo/os/$arch' > /etc/pacman.d/mirrorlist \
  && pacman -Syyuu --noconfirm --needed base-devel git \
  && useradd -m builder \
  && mkdir -p /work/pkg

FROM build AS package

COPY container/PKGBUILD container/pacman-container.conf container/lightos-omarchy-enable-updates container/lightos-omarchy-container.install /work/pkg/
RUN chown -R builder:builder /work \
  && su builder -s /bin/bash -c 'cd /work/pkg && makepkg --nodeps --noconfirm --clean'

FROM build AS seatd-guard

COPY container/lightos-seatd-vt-guard.c /work/lightos-seatd-vt-guard.c
RUN cc -shared -fPIC -O2 -Wall -Wextra -Werror \
  -Wl,-z,relro,-z,now -o /work/lightos-seatd-vt-guard.so /work/lightos-seatd-vt-guard.c

FROM docker.io/library/archlinux:base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

LABEL org.opencontainers.image.source="https://github.com/ponzS/omarchy" \
  org.opencontainers.image.title="Omarchy for LightOS" \
  org.opencontainers.image.description="Official stable Omarchy with independent LightOS container integration"

COPY --from=package /work/pkg/lightos-omarchy-container-*.pkg.tar.zst /tmp/
COPY container/pacman-container.conf /etc/pacman.d/lightos-omarchy.conf
COPY container/lightos-omarchy-enable-updates /tmp/lightos-omarchy-enable-updates
COPY container/desktop.packages /tmp/desktop.packages

RUN set -eu; \
  printf '%s\n' 'Server = https://stable-mirror.omarchy.org/$repo/os/$arch' > /etc/pacman.d/mirrorlist; \
  pacman -Syyuu --noconfirm --needed python; \
  bash /tmp/lightos-omarchy-enable-updates; \
  sed -i -e 's@usr/share/locale/\*@usr/share/locale/* !usr/share/locale/zh*/*@' \
    -e 's@usr/share/X11/locale/\*@usr/share/X11/locale/* !usr/share/X11/locale/zh*/*@' \
    -e 's@usr/share/i18n/\*@usr/share/i18n/* !usr/share/i18n/locales/zh_*@' /etc/pacman.conf; \
  printf '%s\n' 'Server = https://stable-mirror.omarchy.org/$repo/os/$arch' > /etc/pacman.d/mirrorlist; \
  pacman-key --init; \
  pacman-key --populate archlinux; \
  pacman -Syyuu --noconfirm --needed archlinux-keyring ca-certificates curl gnupg; \
  curl -fsSL 'https://keys.openpgp.org/vks/v1/by-fingerprint/40DFB630FF42BCFFB047046CF0134EE680CAC571' -o /tmp/omarchy-signing-key.asc; \
  test "$(gpg --show-keys --with-colons /tmp/omarchy-signing-key.asc | awk -F: '$1 == "fpr" { print $10; exit }')" = '40DFB630FF42BCFFB047046CF0134EE680CAC571'; \
  pacman-key --add /tmp/omarchy-signing-key.asc; \
  pacman-key --lsign-key 40DFB630FF42BCFFB047046CF0134EE680CAC571; \
  printf '\n%s\n%s\n' '[omarchy]' 'Server = https://pkgs.omarchy.org/stable/$arch' >> /etc/pacman.conf; \
  pacman -Syyuu --noconfirm --needed omarchy-keyring python; \
  mapfile -t dependencies < <(grep -Ev '^[[:space:]]*(#|$)' /tmp/desktop.packages); \
  env OMARCHY_UPDATE_PACMAN=1 pacman -S --noconfirm --needed "${dependencies[@]}"; \
  pacman -U --noconfirm /tmp/lightos-omarchy-container-*.pkg.tar.zst; \
  env OMARCHY_UPDATE_PACMAN=1 pacman -S --noconfirm glibc; \
  sed -i -e '/^#en_US\.UTF-8[[:space:]]/s/^#//' \
    -e '/^#zh_CN\.UTF-8[[:space:]]/s/^#//' /etc/locale.gen; \
  locale-gen; \
  locale -a | grep -Fxq zh_CN.utf8; \
  fc-cache -f; \
  systemctl enable systemd-resolved.service; \
  install -Dm644 /usr/share/omarchy/config/chromium-flags.conf /etc/skel/.config/chrome-flags.conf; \
  rm -f /tmp/*.pkg.tar.zst /tmp/omarchy-signing-key.asc /tmp/lightos-omarchy-enable-updates /tmp/desktop.packages; \
  pacman -Scc --noconfirm

COPY --from=seatd-guard /work/lightos-seatd-vt-guard.so /usr/local/lib/lightos-seatd-vt-guard.so
COPY container/lightos-omarchy-keyring.service /etc/systemd/system/lightos-omarchy-keyring.service
COPY container/lightos-omarchy-device-setup.service /etc/systemd/system/lightos-omarchy-device-setup.service
COPY container/lightos-omarchy-device-setup.sh /usr/local/bin/lightos-omarchy-device-setup
COPY container/lightos-omarchy-console.sh /usr/local/bin/lightos-omarchy-console
COPY container/lightos-omarchy-console.service /etc/systemd/system/lightos-omarchy-console.service
COPY container/lightos-omarchy-profile.sh /etc/profile.d/lightos-omarchy.sh
COPY container/lightos-omarchy-seatd.conf /etc/systemd/system/seatd.service.d/10-lightos-vt.conf
RUN chmod 0755 /usr/local/bin/lightos-omarchy-device-setup /usr/local/bin/lightos-omarchy-console \
  && systemctl disable seatd.service \
  && systemctl enable lightos-omarchy-keyring.service lightos-omarchy-device-setup.service lightos-omarchy-console.service

COPY container/mimeapps.list /etc/skel/.config/mimeapps.list

# The settings scriptlet needs a private /run/lock even in an unbooted OCI
# build. Certify its grant cleanup after all packages landed; do not publish
# an image with the settings transition blocker left behind.
RUN install -d -m 0755 /run/lock \
  && env OMARCHY_UPDATE_PACMAN=1 pacman -S --noconfirm omarchy-settings \
  && test ! -e /run/omarchy-sudo-passwordless-package-removing \
  && pacman -Scc --noconfirm

CMD ["/sbin/init"]
