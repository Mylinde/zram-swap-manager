#!/usr/bin/env sh

[ $(id -u) -eq 0 ] || {
  printf "\n(!) must run as root\n\n"
  exit 2
}

exec 2>/dev/null
rm /dev/.vr25/zram-swap-manager/*.lock

case "$*" in
  *--stop*) zram-swap-manager -f ;;
esac

case "$*" in
  *--keep-config*) :;;
  *)
    rm -rf /etc/zram-swap-manager.conf
  ;;
esac

systemctl disable zram-swap-manager
rm /usr/local/bin/zsm \
   /usr/local/bin/zram-swap-manager \
   /usr/local/bin/zram-swap-manager-uninstall \
   /etc/systemd/system/zram-swap-manager.service
