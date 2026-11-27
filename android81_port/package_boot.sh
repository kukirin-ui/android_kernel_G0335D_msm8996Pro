#!/bin/bash
# Package a boot.img using extracted DTB + optional prebuilt wlan.ko
# Usage: from kernel root
#   bash android81_port/package_boot.sh
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

OUT="${OUT:-out}"
DTB="${DTB:-extracted/stock_7.1.2_msm8996pro-v1.1-pmi8996-mtp.dtb}"
WLAN="${WLAN:-extracted/wlan.ko}"
KERNEL="${KERNEL:-$OUT/arch/arm64/boot/Image.gz}"

echo "=== package_boot ==="
echo "Kernel : $KERNEL"
echo "DTB    : $DTB"
echo "WLAN   : $WLAN"

if [ ! -f "$KERNEL" ]; then
  echo "ERROR: kernel Image.gz not found. Build first with android81_port/build_kernel.sh"
  exit 1
fi
if [ ! -f "$DTB" ]; then
  echo "ERROR: DTB not found at $DTB"
  exit 1
fi

mkdir -p "$OUT/package"
cp -f "$KERNEL" "$OUT/package/Image.gz"
cp -f "$DTB" "$OUT/package/g0335d.dtb"
if [ -f "$WLAN" ]; then
  cp -f "$WLAN" "$OUT/package/wlan.ko"
  echo "Copied wlan.ko (vermagic should match 3.18.71)"
fi

# Append DTB to Image.gz (common for appended-DTB boots)
cat "$OUT/package/Image.gz" "$OUT/package/g0335d.dtb" > "$OUT/package/Image.gz-dtb"
echo "Created $OUT/package/Image.gz-dtb"
ls -lh "$OUT/package/"
echo "Next: use mkbootimg with Image.gz-dtb + ramdisk to produce boot.img"
