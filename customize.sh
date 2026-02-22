#!/usr/bin/env sh

[ $(id -u) -eq 0 ] || {
  printf "\n(!) must run as root\n\n"
  exit 2
}

src="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"

prep_cfg() {
  [ -f $cfg ] || install -m 644 $src/zram-swap-manager.conf $cfg
}

# GNU/Linux only

cfg=/etc/zram-swap-manager.conf

sh $src/uninstall.sh --keep-config >/dev/null 2>&1
mkdir -p /usr/local/bin/

install -m 644 $src/zram-swap-manager.service /etc/systemd/system/zram-swap-manager.service

install -m 755 $src/zram-swap-manager.sh /usr/local/bin/zram-swap-manager
ln -s /usr/local/bin/zram-swap-manager /usr/local/bin/zsm

install -m 755 $src/uninstall.sh /usr/local/bin/zram-swap-manager-uninstall

prep_cfg

systemctl enable zram-swap-manager
[ ".$1" != .--start ] || zram-swap-manager -r

printf "\n\nCHANGELOG\n\n"
cat $src/changelog.md
printf "\n\n\n"