# Actions-RK-Alpine-Linux

Custom Alpine Linux images for **NanoPi R4S and NEO3**, independently maintained by IxsCN and based on [FriendlyElec Actions-Alpine-Linux](https://github.com/friendlyarm/Actions-Alpine-Linux).

GitHub Actions builds ARM64 images with **eBPF, BTF and TC** support added to FriendlyElec's Linux 6.6 configuration, targeting lightweight routing and networking experiments.

[简体中文](README.md) · [Actions](https://github.com/IxsCN/Actions-RK-Alpine-Linux/actions) · [Downloads](https://github.com/IxsCN/Actions-RK-Alpine-Linux/releases) · [Kernel customization (Chinese)](docs/dae-kernel.md)

## Current build targets

| Board | Platform | OS | Kernel series |
| --- | --- | --- | --- |
| NanoPi R4S | rk3399 | Alpine Linux 3.23 / ARM64 | Linux 6.6 |
| NanoPi NEO3 | rk3328 | Alpine Linux 3.23 / ARM64 | Linux 6.6 |

- **Kernel support for dae:** eBPF, BTF and TC options, with checks of the resolved configuration and kernel BTF during builds.
- **Preinstalled utilities:** `htop`, `tio`, `kitty-terminfo` and `tailscale`.
- **Image formats:** SD boot images and eMMC flasher images. eMMC output is only usable on devices with compatible eMMC hardware; its presence does not imply every target board supports it.
- **Independent platform jobs:** one platform's failure does not automatically cancel the other.

> dae itself is not preinstalled. Tailscale is installed but not automatically enabled or enrolled in a tailnet. Build-time checks do not replace board boot tests or actual dae traffic tests. Check the relevant Actions run and validate on hardware.

## Default system settings

| Setting | Default |
| --- | --- |
| Username | `root` |
| Password | `fa` |
| Network | DHCP on the first Ethernet interface |
| Login | SSH and serial console |

**Change the default password immediately after first boot. Do not expose SSH to the Internet before securing the system.**

## Build images

1. Open this repository's **Actions** page and enable workflows if necessary.
2. Select `.github/workflows/build.yml`.
3. Click **Run workflow**, choose `master` and start the build.
4. Wait for the platform's build and uploads to succeed, then download images from **Releases**.

Only the repository owner can trigger the jobs. Starring your own repository remains supported as an alternative trigger. The workflow declares the `contents: write` permission needed for publishing.

> A Release is created before compilation starts. Its existence does not mean images have been built successfully.

## Boot from a microSD card

Download the matching `*-sd-alpine-linux-arm64-*.img.gz`:

- R4S: `rk3399-sd-alpine-linux-arm64-*.img.gz`
- NEO3: `rk3328-sd-alpine-linux-arm64-*.img.gz`

Decompress and flash the `.img` with an image-writing tool, or use a tool supporting `.gz` directly. Insert the card into the matching board and boot. Test with a spare card and retain your previous installation for recovery.

## Flash eMMC

Images containing `-eflasher-` automatically flash eMMC from a microSD card; they are **not normal SD boot images**.

Use them only after confirming compatible eMMC hardware, selecting the correct image and backing up your data. Booting the flashed card automatically overwrites the target eMMC. Once flashing finishes, remove the card and restart according to your device's instructions.

## Customization

- [`configs/dae.config`](configs/dae.config): kernel configuration fragment for dae.
- [`scripts/build-dae-kernel.sh`](scripts/build-dae-kernel.sh): board configuration, kernel build and validation.
- [`scripts/setup-alpine.sh`](scripts/setup-alpine.sh): packages and rootfs initialization.
- [`.github/workflows/build.yml`](.github/workflows/build.yml): build, packaging and Release uploads.
- [`docs/dae-kernel.md`](docs/dae-kernel.md): build details and post-boot checks (Chinese).

## Credits and references

Thanks to FriendlyElec for board support, kernels and image-building tools. This repository maintains its own configuration and release workflow on that foundation; it is not an official FriendlyElec release.

- [Upstream project](https://github.com/friendlyarm/Actions-Alpine-Linux)
- [FriendlyElec Alpine Linux documentation](https://wiki.friendlyelec.com/wiki/index.php/Getting_Started_with_Alpine-Linux)
- [dae](https://github.com/daeuniverse/dae)
