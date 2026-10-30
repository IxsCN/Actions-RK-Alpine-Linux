# RK3328 large-kernel SD boot fix

Applies to FriendlyElec uboot-rockchip `nanopi-r2-v2017.09`, tested for patch
application against commit `109538776b8d9ba62a965283cc58689fd2045c70`.

The 2026-10-29 NEO3 image contains a 35.20 MiB kernel. `read_rockchip_image()`
reads its first sector separately, then reads the remainder at `0x2801f8`.
This unaligned destination requires a DMA bounce buffer. The default MMC limit
of 65535 sectors requests almost 32 MiB, while the entire U-Boot malloc arena
is only 32 MiB and already has other allocations.

The legacy DesignWare MMC driver ignores `bounce_buffer_start()` failures.
The reported crash at PC `0x2905bc` is a load from NULL in the buffer copy:
`x0=0x2801f8`, `x1=0`, `x2=0x1fffe00` (65535 sectors).

The patch:

- Limits RK3328 MMC requests to 4096 sectors (2 MiB), allowing large kernels
  to be read in smaller chunks without removing BTF.
- Checks bounce-buffer allocation failures in both DesignWare command paths,
  returning the error instead of proceeding with a NULL buffer.

The workflow applies this before U-Boot compilation and fails if the patch no
longer applies. RK3399 is unchanged. A successful build is not a hardware boot
verification; capture a fresh NEO3 serial log with the rebuilt SD image.
