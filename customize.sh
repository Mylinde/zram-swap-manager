#!/sbin/sh

[ $(id -u) -eq 0 ] || {
  printf "\n(!) must run as root\n\n"
  exit 2
}

# set source code directory
src="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"

# for magisk
SKIPUNZIP=1

patch_cfg() {
  if [ -f $cfg ] && [ "$1" != r ]; then
    if grep -Eq '^# :|mem_total' $cfg; then
      patch_cfg r
    else
      config_ver=0$(sed -n '/^config_ver=/s/.*=//p' $cfg)
      if [ $config_ver -lt 0202110290 ]; then
        sed -i -e '1iconfig_ver=202110290\n' -e '/^comp_a/s/=.*/=auto/' -e '/^vm=/s/e=200\"/e=200 page-cluster=0\"/' $cfg
      fi
      [ $config_ver -lt 0202112020 ] && sed -i -e '/^config_ver=/s/=.*/=202112020/' -e 's/ vfs_cache_pressure=200//' $cfg
    fi
  else
    install -m 644 $src/zram-swap-manager.conf $cfg
  fi
}

if [ -d /data/adb ]; then

  # android

  # extract flashable zip if source code is unavailable
  [ -f $src/TODO ] || {
    src=/dev/.vr25-zsm-install
    on_exit() { rm -rf ${src:-//} 2>/dev/null; }
    on_exit
    trap on_exit EXIT
    mkdir $src
    unzip "${3:-${ZIPFILE}}" -d $src/ >&2
  }

  . $src/busybox.sh

  if ${KSU:-false} || [ -f /data/adb/ksu/bin/busybox ]; then
    install_dir=/data/adb/modules_update/zram-swap-manager
    install_dir0=/data/adb/modules/zram-swap-manager
    mkdir -p $install_dir0
    cp $src/module.prop $install_dir0/
    touch $install_dir0/update
    SKIPMOUNT=false
  else
    install_dir=/data/adb/modules/zram-swap-manager
  fi

  data_dir=/data/adb/vr25/zram-swap-manager-data
  cfg=/data/adb/vr25/zram-swap-manager-data/config.txt

  rm -rf $install_dir 2>/dev/null
  mkdir -p $install_dir/system/bin $data_dir

  for i in $install_dir/system/bin/zram-swap-manager $install_dir/system/bin/zsm /sbin/zram-swap-manager /sbin/zsm; do
    cp -f $src/zram-swap-manager.sh $i 2>/dev/null
  done

  [ -f $data_dir/config.txt ] || cp $src/zram-swap-manager.conf $data_dir/config.txt

  for i in $install_dir/system/bin/zram-swap-manager-uninstall /sbin/zram-swap-manager-uninstall; do
    cp -f $src/uninstall.sh $i 2>/dev/null
  done

  for i in $install_dir/*.sh $install_dir/system/bin/* /sbin/zram-swap-manager /sbin/zsm; do
    sed -i 's|^#!/.*|#!/system/bin/sh|' $i
  done

  i="$PWD"
  cd $src/
  cp busybox.sh module.prop service.sh $install_dir/
  cd "$i"
  unset i

  patch_cfg

  chmod 0755 -R $install_dir/*.sh $install_dir/system /sbin/zram-* /sbin/zsm 2>/dev/null
  [ ".$1" != .--start ] || $install_dir/service.sh

else

  # gnu/linux

  cfg=/etc/zram-swap-manager.conf
  [ -f $cfg ] && upgrade=true

  sh $src/uninstall.sh --keep-config >/dev/null 2>&1
  mkdir -p /usr/local/bin/

  install -m 644 $src/zram-swap-manager.service /etc/systemd/system/zram-swap-manager.service

  install -m 755 $src/zram-swap-manager.sh /usr/local/bin/zram-swap-manager
  ln -s /usr/local/bin/zram-swap-manager /usr/local/bin/zsm

  ${upgrade:-false} || patch_cfg r
  install -m 755 $src/uninstall.sh /usr/local/bin/zram-swap-manager-uninstall

  patch_cfg

  systemctl enable zram-swap-manager
  [ ".$1" != .--start ] || zram-swap-manager -r

fi

echo "Done!"
