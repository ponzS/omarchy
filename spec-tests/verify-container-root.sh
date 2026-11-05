#!/bin/bash
# Run inside the actual image rootfs after its real package transaction.
set -euo pipefail

pacman -Dk
pacman -Q omarchy omarchy-settings lightos-omarchy-container
[[ -z $(pacman-conf IgnorePkg | grep -E '(^|[[:space:]])omarchy(-settings)?($|[[:space:]])' || true) ]]
for command in limine-install limine-mkinitcpio mkinitcpio snapper; do
  if command -v "$command" >/dev/null; then
    echo "Container boot command unexpectedly available: $command" >&2
    exit 1
  fi
done
for hook in \
  /usr/share/libalpm/hooks/80-limine-efi-deploy.hook \
  /etc/pacman.d/hooks/90-mkinitcpio-install.hook; do
  [[ ! -e $hook ]]
done
export OMARCHY_PATH=/usr/share/omarchy
bash -euo pipefail "$OMARCHY_PATH/migrations/1791581004.sh"
[[ ! -f /boot/limine.conf ]]
[[ -x /usr/local/bin/lightos-omarchy-console ]]
[[ -x /usr/local/bin/lightos-omarchy-device-setup ]]
[[ -f /usr/local/lib/lightos-seatd-vt-guard.so ]]
locale -a | grep -Fxq zh_CN.utf8
printf 'PASS: real container root has official packages, update policy, locale and LightOS integration.\n'
