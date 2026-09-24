#!/bin/sh
case $- in
  *i*)
    user_id=$(id -u)
    terminal=$(tty 2>/dev/null)
    if [ "$user_id" -ge 1000 ] && [ "$user_id" -lt 60000 ] &&
       [ -c "$terminal" ] && [ -c /dev/tty0 ] &&
       [ "$(stat -c '%t:%T' "$terminal")" = "$(stat -c '%t:%T' /dev/tty0)" ] &&
       [ -z "${WAYLAND_DISPLAY:-}" ]; then
      exec uwsm start -g -1 -e -D Hyprland hyprland.desktop
    fi
    ;;
esac
