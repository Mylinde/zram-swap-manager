#!/usr/bin/env sh

version="v2026.02.22 (20260222)"
info="zRAM Swap Manager $version
Upstream repo: github.com/vr-25/zram-swap-manager
Copyright (C) 2021-2024, VR25
License: GPLv3+"

IFS="$(printf ' \t\n')"
temp_dir=/dev/.vr25/zram-swap-manager
sd_lock=$temp_dir/sd_$(date +%s).lock
vmd_lock=$temp_dir/vmd_$(date +%s).lock

calc() {
  # wrapper around bc -l for floating-point calculations
  printf "%s\n" "$*" | bc
}

edit_config() {
  config=/etc/zram-swap-manager.conf
  if [ -n "$1" ]; then
    # allow invocation with arguments but avoid blind eval
    case "$1" in
      *' '*) sh -c "$* $config" ;;
      *) "$1" "$config" ;;
    esac
  else
    for i in $EDITOR nano vim vi; do
      cmd=${i%% *}
      command -v "$cmd" >/dev/null 2>&1 && {
        # if $i contains arguments, run via sh -c; otherwise execute directly
        case "$i" in
          *' '*) sh -c "$i $config" ;;
          *) "$i" "$config" ;;
        esac
        break
      }
    done
  fi
  unset config i cmd
}

hot_add() {
  cat /sys/class/zram-control/hot_add 2>/dev/null || echo 0
}

hot_remove() {
  write /sys/class/zram-control/hot_remove $1
}

mem_estimates() {
  zramctl ${swap_device}* 2>/dev/null || {
    case $disksize in
      *[kK]) disksize=$(calc "${disksize%?} * 1024");;
      *[mM]) disksize=$(calc "${disksize%?} * 1024 * 1024");;
      *[gG]) disksize=$(calc "${disksize%?} * 1024 * 1024 * 1024");;
      *[tT]) disksize=$(calc "${disksize%?} * 1024 * 1024 * 1024 * 1024");;
    esac
    total_mem_before=$(calc "$mem_total / 1024")
    net_gain=$(calc "(($disksize - $mem_limit) / 1024) / 1024")
    total_mem_now=$(calc "$total_mem_before + $net_gain")
    net_gain_percent=$(calc "$net_gain * 100 / $total_mem_before")
    printf "Memory Estimates\nWithout zRAM:\t%s MB\nWith zRAM:\t%s MB\nNet Gain:\t%s MB (%s%%)\n" \
      "$total_mem_before" "$total_mem_now" "$net_gain" "$net_gain_percent"
    unset total_mem_before total_mem_now net_gain net_gain_percent
  }
}

stop_swappinessd() {
  rm "$temp_dir"/sd_*.lock 2>/dev/null
}

swap_off() {
  stop_swappinessd
  rm "$temp_dir"/vmd_*.lock 2>/dev/null
  for i in ${swap_device}*; do
    [ -b "$i" ] || continue
    swapoff "$i"
    write "/sys/block/zram${i#$swap_device}/reset" 1
    hot_remove "${i#$swap_device}"
  done
  for i in $(awk '/^\//{print $1}' /proc/swaps); do
    swapoff "$i"
  done
  unset i
  write /sys/module/zswap/parameters/enabled 1
}

swap_on() {
  i=$(hot_add)
  write /sys/module/zswap/parameters/enabled 0
  modprobe zram num_devices=1 2>/dev/null
  if [ -f /sys/block/zram$i/comp_algorithm ] \
    && ! grep -q "$comp_algorithm" /sys/block/zram$i/comp_algorithm 2>/dev/null
  then
    case "$(cat /sys/block/zram$i/comp_algorithm)" in
      *zstd*) comp_algorithm=zstd; comp_ratio=337;;
      *lz4*) comp_algorithm=lz4; comp_ratio=263;;
      *lzo-rle*) comp_algorithm=lzo-rle; comp_ratio=274;;
      *lzo*) comp_algorithm=lzo; comp_ratio=277;;
    esac
  fi
  for j in max_comp_streams comp_algorithm disksize _mem_limit; do
    # eval required, but use safe quoting
    eval write "/sys/block/zram$i/$j" "\$$j"
  done
  mkswap -L "${swap_label}${i}" "$swap_device$i"
  swapon "$swap_device$i"
  touch "$vmd_lock"
  (set +x
  exec </dev/null >/dev/null 2>&1
  while [ -f "$vmd_lock" ]; do
    for vm_kv in $vm; do
      key=${vm_kv%=*}
      val=${vm_kv#*=}
      [ -f /proc/sys/vm/"$key" ] && [ -n "$val" ] && write "/proc/sys/vm/$key" "$val"
    done
    sleep 10
  done) &
  unset i j vm_kv key val
  ! $dynamic_swappiness || swappinessd
}

swappinessd() {
  stop_swappinessd
  touch "$sd_lock"
  (set +x
  exec </dev/null >/dev/null 2>&1
  while [ -f "$sd_lock" ]; do
    # compute load as integer (0-100); no float comparisons needed
    load_avg1=$(awk -v m="$max_comp_streams" '{printf "%d", ($1 * 100 / m)}' /proc/loadavg)
    if [ "$load_avg1" -ge "$high_load_threshold" ]; then
      write /proc/sys/vm/swappiness "$high_load_swappiness"
    elif [ "$load_avg1" -ge "$medium_load_threshold" ]; then
      write /proc/sys/vm/swappiness "$medium_load_swappiness"
    elif [ "$load_avg1" -ge "$low_load_threshold" ]; then
      write /proc/sys/vm/swappiness "$low_load_swappiness"
    fi
    sleep "$load_sampling_rate"
  done) &
}

write() {
  [ -f "$1" ] && printf "%s" "$2" > "$1" 2>/dev/null
}

echo
trap 'e=$?; echo; exit $e' EXIT

case $1 in
  -d*)
    [ -n "$LINENO" ] && export PS4='$LINENO: '
    set -x
  ;;
esac

[ $(id -u) -eq 0 ] || {
  echo "(!) must run as root"
  exit 2
}

mkdir -p "$temp_dir"

for i in "${0}.conf" /etc/zram-swap-manager.conf; do
  [ -f "$i" ] && {
    . "$i"
    break
  }
done
unset i

: ${comp_algorithm:=auto}
: ${comp_ratio:=277}
[ $comp_algorithm = auto ] && comp_algorithm=277
: ${mem_percent:=33}
: ${mem_total:=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)}
: ${mem_limit:=$(calc "$mem_total * $mem_percent / 100 * 1024")}
: ${disksize:=$(calc "$mem_limit * $comp_ratio / 100")}
: ${max_comp_streams:=$(( $(cut -d- -f2 /sys/devices/system/cpu/present) + 1 ))}
: ${swap_device:=/dev/zram}
: ${dynamic_swappiness:=false}
: ${load_sampling_rate:=60}
: ${high_load_threshold:=90}
: ${high_load_swappiness:=80}
: ${medium_load_threshold:=45}
: ${medium_load_swappiness:=90}
: ${low_load_threshold:=0}
: ${low_load_swappiness:=100}
: ${vm:=page-cluster=0 swappiness=85 watermark_boost_factor=0 watermark_scale_factor=125}

case $1 in
  -*c) shift; edit_config "$@";;
  -*e) mem_estimates;;
  -*n) swap_on;;
  -*f) swap_off;;
  -*v) echo $version;;
  -*r) swap_off 2>/dev/null; swap_on;;
  -*s) swappinessd;;
  -*t) stop_swappinessd; write /proc/sys/vm/swappiness $swappiness;;
  -*u) shift; zram-swap-manager-uninstall "$@";;
  *) echo "$info

Options:

-d[opt]  verbose (set -x)

-c       edit config w/ \"\$@\" | \$EDITOR | nano | vim | vi
-e       memory estimates
-n       swap_on
-f       swap_off
-v       version
-r       swap_off; swap_on
-s       [re]start swappinessd
-t       stop swappinessd
-u       uninstall";;
esac
