# Extracted from Android8.1-vendor+boot.zip / boot.img

- `g0335d_candidate.dtb` — one of the DTBs containing G0335D / gree_g0335d strings (offset 12425436 in boot.img)
- `wlan.ko` — Qualcomm Atheros WLAN module
  - vermagic: `3.18.71-perf-g4a0c249ca2c8-01402-g2933054d2488-dirty SMP preempt mod_unload modversions aarch64`
  - Matches the 3.18.71 kernel in this tree
- `kernel_from_boot.img.gz` — kernel binary extracted from boot.img (gzipped)

Other G0335D-matching DTBs were also present in the boot.img (dtb_07, 14, 15, 20-23, 25, 26).

## stock_7.1.2_msm8996pro-v1.1-pmi8996-mtp.dtb (use this one)
Taken from the stock GREE Android 7.1.2 boot.img (appended DTB #23,
model "MSM 8996pro v1.1 + PMI8996 MTP", qcom,msm-id <305 0x10001>,
board-id <8 0>). This is the DTB the device actually matches, and it
contains the real panel node `qcom,mdss_dsi_ft8716_8080p_video`
(1080x2160, single DSI ctrl0, DCS backlight).

`g0335d_candidate.dtb` is NOT the right one: it is the MSM 8996 v2
(msm-id 246) DTB. And the DTBs compiled from this tree's generic
msm8996pro-v1.1-pmi8996-mtp.dts have no ft8716 node, so the kernel falls
back to the dual Sharp panel -> garbled / black screen and DSI BTA errors.
