# Container update validation — 2026-11-06

## Existing instance

- Started with container-fork `omarchy 4.0.4-3` and `omarchy-settings 4.0.4-1`.
- Installed the independent integration policy and replaced the desktop with genuine official stable packages through `omarchy update -y`.
- Final update exit: **0**; installed `omarchy 4.5.0-3`, `omarchy-settings 4.5.0-3`.
- All 112 initially pending migrations completed; a later pending check returned none.
- `pacman -Dk`: no database errors. Official `omarchy`: 0 altered files.
- Official Shell IPC ping: `ok`. Existing physical-console, remote-desktop server and remote-desktop session services stayed active.
- Personal directories (Documents, Pictures, Videos, Music, Downloads, Projects, Desktop, .ssh) remained present with no reduction in their top-level entry counts. This is not a byte-for-byte whole-home backup or integrity claim.
- No host reboot, rootfs replacement, formatting, whole-machine snapshot or personal-file cleanup was performed.

The first attempt needed an official Shell restart before continuing because the old running Shell could not answer new IPC calls. An initial integration dependency on all default apps was removed after it correctly blocked an upstream replacement of dua-cli with Disktree. The final integration has no hard application-version dependencies.

## New image / booted container

- Built the actual Dockerfile with Buildah against the official Arch/Omarchy stable repositories.
- Ran `verify-container-root.sh` against the built root: official packages and locale present, genuine boot migration safely skipped, no EFI deploy or kernel hook exposed, LightOS integration files present.
- Booted a separate systemd-nspawn instance from the built image, created a fresh ordinary user from `/etc/skel`, started its user manager and ran the genuine `omarchy update -y`.
- Fresh-instance update exit: **0**. No pending migrations and no package database errors. A personal sentinel file retained its exact contents.
- This nested test has no graphical compositor; the official updater warned that the Shell could not start, then completed normally as designed for non-graphical sessions. It does not establish physical VT handoff or remote streaming acceptance for the new image.
- Final image additionally reinstalls official settings with a valid `/run/lock` and verifies that the temporary sudo-grant transition blocker is absent. The final image passed the root validation again.

## Evidence boundary

Raw logs for this run are in `/tmp/omarchy-upgrade-review.oGCPH3/`. The specification remains draft because no Project AC Executor or complete new-device graphical regression was introduced for this maintenance task. Syntax/static checks are auxiliary evidence only.
