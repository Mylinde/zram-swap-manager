**v2026.03.27 (20260327)**
- Add zRAM utilization monitoring and optimized cache dropping

**v2026.02.22 (20260222)**
- Android depended Code removed
- Add human-readable swap labels via mkswap -L ("${swap_label}N").
- Improve robustness and safety: safer quoting, secure edit_config invocation, guarded writes to sysfs/proc, and cleanup of temp locks.
- Minor performance/daemon fixes: integer load calculation for swappinessd and small cleanup in swap on/off paths

**v2024.12.15.1 (202412151)**
- Fix typos
- Print changelog after installation & don't overwrite config
- Set default dynamic_swappiness=false

**v2024.12.15 (202412150)**
- [Android]: Wait for boot_completed
- Add vm daemon to enforce vm tweaks
- Fix infinite recursion
- mem_estimates(): Add support for disksize suffixes
- Optimize default config
- Optimize installer
- Prioritize nano over vim, vi.
- Update busybox config
- Update compression ratios
- Update doc & funding info
- Upgrade flashable zip generator
- Use zramctl when available

**v2023.7.17 (202307170)**
- KernelSu support
- Updated documentation
- Various fixes & optimizations
