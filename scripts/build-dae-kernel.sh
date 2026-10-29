#!/usr/bin/env bash
# Run from project/sd-fuse, after the normal U-Boot build.
set -euo pipefail

cpu=${1:?Usage: build-dae-kernel.sh CPU OS_DIR}
os_dir=${2:?Usage: build-dae-kernel.sh CPU OS_DIR}
repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

case "$cpu" in
  rk3328) defconfig=nanopi-r2_linux_defconfig ;;
  rk3399) defconfig=nanopi4_linux_defconfig ;;
  *) echo "Unsupported dae kernel CPU: $cpu" >&2; exit 1 ;;
esac

# Both sd-fuse platforms currently use this same source branch.
# Do not reuse an arbitrary local kernel tree from a different branch.
if [ -e kernel ]; then
  echo "kernel already exists; use a fresh sd-fuse workspace" >&2
  exit 1
fi
git clone --depth 1 -b nanopi-r2-v6.6.y \
  https://github.com/friendlyarm/kernel-rockchip.git kernel
cp "$repo_dir/configs/dae.config" kernel/arch/arm64/configs/dae.config

# build-kernel.sh runs distclean and then make ${KCFG}; a fragment survives
# that reset, unlike hand-editing kernel/.config before invoking the script.
DISABLE_MKIMG=1 KERNEL_SRC=kernel KCFG="$defconfig dae.config" \
  ./build-kernel.sh "$os_dir"

# Kconfig may silently discard options with unmet dependencies. Check the
# resolved configuration before allowing the image packaging to continue.
while IFS= read -r setting; do
  case "$setting" in
    CONFIG_*=y|'# CONFIG_'*' is not set')
      if ! grep -Fxq "$setting" kernel/.config; then
        echo "Required dae kernel setting missing: $setting" >&2
        exit 1
      fi
      ;;
  esac
done < "$repo_dir/configs/dae.config"
grep -qx 'CONFIG_DEBUG_INFO=y' kernel/.config
# Check that BTF was actually emitted, not only requested in the config.
aarch64-linux-gnu-readelf -S kernel/vmlinux | grep '\.BTF ' > /dev/null
echo "dae kernel configuration and vmlinux BTF verified ($cpu)"
