# GREE G0335D Kernel (Android 8.1 / LOS 15.1)

Linux 3.18.71 kernel source for GREE G0335D / G3S (Snapdragon 820/821 msm8996),
the Android 8.1 (LineageOS 15.1) porting mainline.

Fork with fixes: `kukirin-ui/android_kernel_G0335D_msm8996Pro`

---

## Confidence / what to expect

**Not 100% guaranteed.** Read this before flashing.

### Relatively safe
- `android81_port/build_kernel.sh` — portable, no hardcoded `/root` or WSL paths. A fresh clone should get past the old path/config ordering problems.
- Extracted kernel + DTB + `wlan.ko` taken from a **working** `boot.img`.  
  `android81_port/mkboot_extracted.sh` has a reasonable chance of producing a bootable image **if** the DTB candidate is correct and you supply the original ramdisk.

### Not guaranteed
- **NT36xxx driver** (`drivers/input/touchscreen/nt36xxx/`) is a basic skeleton. Packet layout, registers and GPIOs are not confirmed against the real G0335D panel. Touch may stay dead or misbehave.
- **DTB** is a candidate (`extracted/g0335d_candidate.dtb`). The original boot.img contained 31 DTBs. If this is not the exact match, display / touch / charging can be wrong.
- **wlan.ko** will load only if its vermagic matches the running kernel  
  (`3.18.71-perf-g4a0c249ca2c8-01402-g2933054d2488-dirty SMP preempt mod_unload modversions aarch64`).  
  Otherwise rebuild `drivers/staging/qcacld-2.0` or use a matching module.

### Practical recommendation
1. First test the **extracted** path (no rebuild) with `mkboot_extracted.sh`.
2. Only after that boots, try a full source build that includes the new NT36xxx driver.

---

## Status

### Done
- Portable `android81_port/build_kernel.sh`
- `extracted/` from a working boot.img:
  - `g0335d_candidate.dtb`
  - `wlan.ko` (vermagic above)
  - `kernel_from_boot.img.gz`
  - `LOAD_WLAN.txt`
- Packaging scripts:
  - `android81_port/package_boot.sh`
  - `android81_port/make_boot_from_extracted.sh`
  - `android81_port/mkboot_extracted.sh` (original cmdline)
- Basic NT36xxx driver + Kconfig/Makefile + config re-enabled
- `FIXES.md`

### Drivers already in the tree
- Synaptics DSX / DSX v21
- Atmel maxtouch
- TFA audio codecs
- TUSB320
- qcacld-2.0 WLAN source

### Still open
- NT36xxx protocol/GPIO tuning for this panel
- Confirm exact DTB among the 31 candidates
- Defconfig is still a large full dump (can be cleaned with `savedefconfig` later)
- MANIFEST.md5 is stale

---

## Quick test (recommended first — no rebuild)

```bash
# optional: place original ramdisk.cpio at out/boot_from_extracted/ramdisk.cpio
bash android81_port/mkboot_extracted.sh
```

Produces:
- `out/boot_from_extracted/Image-dtb`
- `out/boot_from_extracted/boot.img` (if `mkbootimg` and ramdisk are available)

Original cmdline used:
```
console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 cma=32M@0-0xffffffff androidboot.selinux=permissive
```

---

## Source build

```bash
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-android-

bash android81_port/build_kernel.sh
# or:
make O=out g0335d_defconfig
make O=out -j$(nproc) Image.gz

bash android81_port/package_boot.sh
```

---

## Layout

- `android81_port/` — Android 8.1 patches, build and packaging scripts
- `extracted/` — DTB, wlan.ko, kernel from a working boot.img
- `arch/arm64/configs/g0335d_defconfig` — device defconfig
- `drivers/input/touchscreen/nt36xxx/` — added basic NT36xxx driver
- `FIXES.md` — short checklist

---

## Credits

Fixes, packaging scripts and NT36xxx driver skeleton by Grok (xAI).  
Base tree from the G0335D Android 8.1 porting effort.

---

## Vendor blobs (full fix package)

Stock 64-bit libs from the G0335D unbrick ROM are in `vendor_blobs/`.

```
vendor_blobs/proprietary/vendor/lib64/
  libmdmdetect.so
  libcne.so
  libcneapiclient.so
  libcneqmiutils.so
  libdiag.so
  libdsutils.so
  libidl.so
  libmmcamera2_*.so   (mct, stats, sensor, iface, imglib, pproc, cpp)
  libmmcamera_imglib.so
```

Copy into the LOS vendor tree:
```bash
cp -a vendor_blobs/proprietary/vendor/lib64 \
      vendor/gree/g0335d/proprietary/vendor/
```

### What this fixes
- `mm-qcamera-daemon`: missing `libmdmdetect.so`
- Supplies the CNE libs and the core mmcamera2 stack

### What can still fail
- **Protobuf**: `libcne*.so` may still miss symbols on LOS 15.1.  
  Keep `vendor_stubs/protobuf_stub` and `LD_SHIM_LIBS` from  
  `vendor_stubs/g0335d_shims.rc` as fallback.
- **Camera**: needs the correct G0335D sensor lib + chromatix (not fully covered).
- **32-bit**: this package is 64-bit only.

Shims (source) remain in `vendor_stubs/` if the stock blobs are not enough.

---

## Full status (what is written)

### Kernel fork (`kukirin-ui/android_kernel_G0335D_msm8996Pro`)
- Portable `android81_port/build_kernel.sh` (no hardcoded paths)
- Extracted pieces from a working boot.img:
  - `extracted/g0335d_candidate.dtb`
  - `extracted/wlan.ko`
  - `extracted/kernel_from_boot.img.gz`
- Packaging scripts:
  - `android81_port/package_boot.sh`
  - `android81_port/make_boot_from_extracted.sh`
  - `android81_port/mkboot_extracted.sh`
- Basic NT36xxx touchscreen driver (skeleton)
- Vendor stubs source in `vendor_stubs/` (libmdmdetect + protobuf shim)
- Stock vendor blobs in `vendor_blobs/proprietary/vendor/lib64/`:
  - libmdmdetect.so
  - libcne.so / libcneapiclient.so / libcneqmiutils.so
  - libdiag.so, libdsutils.so, libidl.so
  - mmcamera2 stack
- This README and `FIXES.md`

### Vendor fork (`kukirin-ui/android_vendor_G0335D_msm8996Pro`)
- Same stock 64-bit libs under `proprietary/vendor/lib64/`

### Not done
- PRs are not merged on the upstream MizhiDR repos
- No device test (boot / camera / modem / wifi)
- Protobuf mismatch on CNE may still appear — shim is the fallback
- Camera still needs the correct G0335D sensor lib + chromatix
- NT36xxx is a skeleton (protocol/GPIO not confirmed)
- DTB is a candidate, not confirmed exact

Nothing has been verified on hardware. Treat everything as untested.

## Brightness
FT8716 panel: bl_ctrl_dcs + TLMM GPIO93 enable (qcom,platform-bklight-en-gpio). Recovery dmesg showed GPIO93 as bklt_en. Overlay: arch/arm64/boot/dts/qcom/g0335d-backlight.dtsi included from the sharp panel dtsi.
