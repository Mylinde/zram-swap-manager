# zRAM Swap Manager

## Foreword
    This program comes with absolutely no warranty.
    Use it at your own risk.
    Refer to the official kernel docs, ArchWiki and/or other reputable sources for information regarding virtual memory configuration, zRAM, zswap, and swap in general.
    Most users should be served by the default config.
    Advanced users will probably want to tweak a thing or two.

## License
    Copyright (C) 2021-2023, VR25

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

## Generate a Magisk Module Flashable Zip
    sh /path/to/zip.sh

## Install/Upgrade
    Android (Magisk module)
      Flash the zip or run su -c sh /path/to/install.sh [--start]

    GNU/Linux
      sudo sh /path/to/install.sh [--start]

## Uninstall
    Android
      su -c /data/adb/modules/zram-swap-manager/uninstall.sh [[--stop] [--keep-config]]

    GNU/Linux
      sudo zram-swap-manager-uninstall [[--stop] [--keep-config]]

## Config
    Android
      /data/adb/vr25/zram-swap-manager-data/config.txt

    GNU/Linux
      /etc/zram-swap-manager.conf

## Default Config
    config_ver=XXXXXXXXX # used for patching; do not modify!

    comp_algorithm=auto # [auto] -> zstd (288) | lz4 (210) | lzo-rle (212) | lzo (211)
    comp_ratio=288 # [210], irrelevant when comp_algorithm=auto
    mem_percent=33 # [33], memory limit

    dynamic_swappiness=true # [true], swappiness <--> /proc/loadavg
    load_sampling_rate=60 # [60] read /proc/loadavg every x seconds
    high_load_threshold=90 # [90], %
    high_load_swappiness=80 # [80]
    medium_load_threshold=45 # [45], %
    medium_load_swappiness=90 # [90]
    low_load_threshold=0 # [0], %
    low_load_swappiness=100 # [100]

    vm="swappiness=85 page-cluster=0"

    Note: One can set disksize instead of comp_ratio and mem_percent. It supports suffixes, as per the official kernel doc (e.g., disksize=1M, disksize=2G).

## Terminal
    Run zsm or zram-swap-manager for help.

## Benchmarks
|    Compressor	   | Ratio	| Compression | Decompression |
|------------------|--------|-------------|---------------|
|  zstd 1.3.4 -1	 | 2.877	|   470 MB/s	|   1380 MB/s   |
| zlib 1.2.11 -1	 | 2.743  |   110 MB/s  |   400 MB/s    |
| brotli 1.0.2 -0	 | 2.701	|   410 MB/s	|   430 MB/s    |
| quicklz 1.5.0 -1 | 2.238	|   550 MB/s  |   710 MB/s    |
|  lzo1x 2.09 -1	 | 2.108	|   650 MB/s	|   830 MB/s    |
|    lz4 1.8.1	   | 2.101  |   750 MB/s  |   3700 MB/s   |
|   snappy 1.1.4   | 2.091	|   530 MB/s	|   1800 MB/s   |
|    lzf 3.6 -1	   | 2.077	|   400 MB/s	|   860 MB/s    |

## Notes/Tips
    - On some Android systems, one may want to delay initialization to ensure defaults and/or third party tweaks are overridden. This can be done by adding `sleep 90` or a more elaborate logic to config.
    - To disable swap on boot, add "swap_off; exit" to config, without quotes.
    - To skip applying settings on boot add exit to config.

## Links

- [Donate - Airtm, username: ivandro863auzqg](https://app.airtm.com/send-or-request/send)
- [Donate - Liberapay](https://liberapay.com/vr25)
- [Donate - Patreon](https://patreon.com/vr25)
- [Donate - PayPal or Credit/Debit Card](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=iprj25@gmail.com&lc=US&item_name=VR25+is+creating+free+and+open+source+software.+Donate+to+suppport+their+work.&no_note=0&cn=&currency_code=USD&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted)
- [Facebook Page](https://fb.me/vr25xda)
- [Telegram Channel](https://t.me/vr25_xda)
- [Telegram Profile](https://t.me/vr25xda)
- [Upstream Repository](https://github.com/vr-25/zram-swap-manager)
- [XDA Thread](https://forum.xda-developers.com/t/zram-swap-manager-for-android-and-gnu-linux-systems.4352797)
