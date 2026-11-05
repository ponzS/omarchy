# Official Omarchy desktop image for LightOS

This image installs `omarchy` and `omarchy-settings` directly from the official stable repository. The independent `lightos-omarchy-container` package contains only the LightOS update policy. `desktop.packages` lists image defaults without preventing upstream migrations from replacing applications. There is no exact Omarchy version pin and no custom package replacing the official desktop.

## Updating an instance

Use the official **Update > Omarchy** menu or:

```bash
omarchy update
```

Updates keep the existing rootfs and personal files. LightOS owns the kernel, bootloader and rootfs lifecycle; the container must not deploy an EFI bootloader or rebuild the host kernel. `pacman-container.conf` uses pacman's supported `NoExtract` policy to omit the official dependencies' boot entrypoints, boot hooks, snapshot entrypoints and autostart helpers. The genuine dependencies remain installed: no fake `provides`, disabled signature checks, success stubs or rewritten official scripts are used. Omarchy's existing command-presence guards skip the inapplicable boot migrations.

The policy is `/etc/pacman.d/lightos-omarchy.conf`, included from pacman's `[options]`. Other repositories, package ignores, and locale settings are preserved. Kernel/snapshot commands omitted by the policy are intentionally unavailable in a container. Do not run Omarchy's disk installer, factory reset, bootloader setup or whole-machine restore here.

## Migrating an existing 4.0.4 instance

Build the small integration package, enable its extraction policy before upgrading, install its dependencies, and replace the old desktop package through a complete official update. `lightos-omarchy-enable-updates` removes only the old `omarchy`/`omarchy-settings` ignore entries and any package-owned files covered by the policy. It does not delete personal data, rewrite the desktop source, or change LightOS VT services.

Existing installations should complete `omarchy update` so all applicable per-user migrations run. New users receive current migration markers from the official packages, so the image explicitly installs current desktop runtime additions such as OWE, titlebars and input methods.

## Build and publish

```bash
docker build --platform linux/amd64 \
  --label "org.opencontainers.image.revision=$(git rev-parse HEAD)" \
  -f container/Dockerfile -t ghcr.io/ponzs/omarchy:lightos-stable .
```

The workflow publishes `lightos-stable-<commit>` plus the mutable `lightos-stable` tag. Use the immutable tag for LightOS presets to avoid stale image caches. Publishing a tag does not replace existing instances. Synchronize verified releases to the Docker Hub / Aliyun mirrors used by the LightOS preset before changing those references.

## Container desktop integration

The existing keyring restoration, GPU group setup, ordinary-user automatic login, allocated-VT console service and seatd VT guard remain independent files in `/etc/systemd/system/` and `/usr/local/`. Official package upgrades do not replace them. The host VT Manager still owns terminal allocation and switching, and the container receives no new global VT capability.

Chrome is installed as a signed package from the configured official Omarchy repository. Chinese fonts and UTF-8 locales remain available. Physical and remote desktop must be tested separately: a successful package transaction does not prove VT release/acquire or remote streaming works.

## Validation

The confirmed update requirements are in `spec/desktop/system-update/`. A real isolated-root package transaction must show that official packages and scriptlets install cleanly, the EFI deploy/kernel hooks are absent and a genuine boot migration skips without modifying boot content. On the current instance, run the complete official update and check package versions, pending migrations, desktop services and personal-file preservation. For a newly built image, create an instance and run the same official update before publishing it as validated. Build-only or source checks are not new-instance acceptance.
