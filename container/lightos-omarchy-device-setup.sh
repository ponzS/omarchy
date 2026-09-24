#!/bin/sh
set -eu

user_entry=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 { print; exit }')
[ -n "$user_entry" ] || exit 0
user=$(printf '%s\n' "$user_entry" | cut -d: -f1)
uid=$(printf '%s\n' "$user_entry" | cut -d: -f3)

add_device_group() {
  device=$1
  [ -c "$device" ] || return 0
  gid=$(stat -c '%g' "$device")
  group=$(getent group "$gid" | cut -d: -f1)
  if [ -z "$group" ]; then
    group="lightos-device-$gid"
    groupadd -g "$gid" "$group"
  fi
  usermod -aG "$group" "$user"
}

add_device_group /dev/dri/card0
for device in /dev/dri/renderD*; do
  add_device_group "$device"
done
if getent group seat >/dev/null; then
  usermod -aG seat "$user"
fi

# LightOS enables lingering at first boot, so the user manager may already
# have started with its old supplementary groups.
if systemctl is-active --quiet "user@$uid.service"; then
  systemctl restart --no-block "user@$uid.service"
fi

# LightOS maps /dev/tty0 to this instance's allocated host VT.
if [ -c /dev/tty0 ] && [ "$(stat -c '%t' /dev/tty0)" = 4 ]; then
  tty_number=$(printf '%d' "0x$(stat -c '%T' /dev/tty0)")
  if [ "$tty_number" -ge 7 ] && [ "$tty_number" -le 63 ]; then
    systemctl start "getty@tty$tty_number.service"
  fi
fi
