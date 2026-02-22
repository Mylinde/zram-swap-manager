# zRAM Swap Manager (GNU/Linux only)

## Notice
This repository version is intended for GNU/Linux systems only. Android-specific installation or configuration instructions are not included here. See the upstream repository if you need Android support.

## Foreword
This program comes with absolutely no warranty.
Use it at your own risk.
Refer to the official kernel docs, the ArchWiki and other reputable sources for information about virtual memory, zRAM, zswap and swap in general.
Most users should be served by the default configuration.
Advanced users will probably want to tweak a thing or two.

## License
Copyright (C) 2021-2024, VR25

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

## Install / Upgrade (GNU/Linux)
sudo sh /path/to/install.sh [--start]

## Uninstall (GNU/Linux)
sudo zram-swap-manager-uninstall [[--stop] [--keep-config]]

## Config (GNU/Linux)
/etc/zram-swap-manager.conf

## Terminal
Run zsm or zram-swap-manager for help.

## Notes / Tips
- You may set disksize instead of comp_ratio and mem_percent. Suffixes are supported as per kernel docs (e.g. disksize=1M, disksize=2G).
- To disable swap on boot, add `swap_off; exit` to the config file.
- To skip applying settings on boot, add `exit` to the config file.

## Links
- zRAM ArchWiki: https://wiki.archlinux.org/title/Zram
- zRAM Official Kernel Doc: https://docs.kernel.org/admin-guide/blockdev/zram.html
- zRAM Performance Analysis: https://notes.xeome.dev/notes/Zram
- Upstream Repository: https://github.com/vr-25/zram-swap-manager
- Donate - Patreon: https://patreon.com/vr25
- Donate - PayPal: https://paypal.me/vr25xda
