#!/bin/bash
set -euo pipefail

user=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 { print $1; exit }')
[[ -n $user ]]
terminal=$(tty)
[[ -c $terminal && -c /dev/tty0 && -c /dev/tty7 ]]
[[ $(stat -c '%t:%T' "$terminal") == $(stat -c '%t:%T' /dev/tty0) ]]
[[ $(stat -c '%t:%T' /dev/tty7) == $(stat -c '%t:%T' /dev/tty0) ]]
[[ $(stat -c '%t' /dev/tty0) == "4" ]]
vt=$((16#$(stat -c '%T' /dev/tty0)))
(( vt >= 7 && vt <= 63 ))

# Starting the instance must not take the display away from its current owner.
# VT Manager activates our mapped terminal; only then start the physical seat.
while [[ $(cat /sys/class/tty/tty0/active) != "tty$vt" ]]; do
  sleep 0.2
done

# Keep seatd in this controlling-terminal session. LightOS deliberately removes
# CAP_SYS_TTY_CONFIG, so a detached system daemon cannot register VT signals.
SEATD_VTBOUND=1 LD_PRELOAD=/usr/local/lib/lightos-seatd-vt-guard.so \
  /usr/bin/seatd -g seat &
seatd_pid=$!
trap 'kill "$seatd_pid" 2>/dev/null || true; wait "$seatd_pid" 2>/dev/null || true' EXIT
for (( attempt = 0; attempt < 100; attempt++ )); do
  [[ -S /run/seatd.sock ]] && break
  kill -0 "$seatd_pid"
  sleep 0.05
done
[[ -S /run/seatd.sock ]]

# Automatic login is limited to the allocated physical terminal. Retain the
# controlling session for seatd while PAM sets up the ordinary instance user.
su --login --shell /bin/bash --session-command 'exec /bin/bash -il' "$user"
