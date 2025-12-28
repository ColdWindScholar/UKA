#!/system/bin/sh


# AIK-mobile/repackimg: repack ramdisk and build image
# osm0sis @ xda-developers


case $1 in
  --help) echo "usage: repackimg.sh [--original] [--origsize] [--level <0-9>] [--avbkey <name>] [--forceelf]"; return 1;
esac;

case $0 in
  *.sh) aik="$0";;
     *) aik="$(lsof -p $$ 2>/dev/null | $bb grep -o '/.*repackimg.sh$')";;
esac;
aik="$(dirname "$(readlink -f "$aik")")";
bin="$aik/bin";
aik=/data/local/AIK-mobile
cur="$(readlink -f "$PWD")";

abort() 
{ 
cd $aik; 
$bb find "$aik" -maxdepth 1 -name "ramdisk*new*" -type f -exec $bb rm -f {} \;
echo "...Error!";
}

cd $aik;
bb=$bin/busybox;
chmod -R 755 $bin $aik/*.sh;
#chmod 644 $bin/magic $bin/androidbootimg.magic $bin/boot_signer-dexed.jar $bin/module.prop $bin/ramdisk.img $bin/avb/* $bin/chromeos/*;

chmod 644 $bin/magic $bin/androidbootimg.magic $bin/boot_signer-dexed.jar $bin/module.prop $bin/avb/* $bin/chromeos/*;

[ ! -f $bb ] && bb=busybox;

if [ -z "$(ls split_img/* 2>/dev/null)" -o ! -e ramdisk ]; then
  echo "...No files found to be packed/built.";
  abort;
  return 1;
fi;

#$bin/remount.sh --mount-only || return 1;

while [ "$1" ]; do
  case $1 in
    --original) original=1;;
    --origsize) origsize=1;;
    --forceelf) repackelf=1;;
    --level)
      case $2 in
        ''|*[!0-9]*) ;;
        *) level="-$2"; lvltxt=" - Level: $2"; shift;;
      esac;
    ;;
    --avbkey)
      if [ "$2" ]; then
        for keytest in "$2" "$cur/$2" "$aik/$2"; do
          if [ -f "$keytest.pk8" -a -f "$keytest.x509."* ]; then
            avbkey="$keytest"; avbtxt=" - Key: $2"; shift; break;
          fi;
        done;
      fi;
    ;;
  esac;
  shift;
done;

ramdiskcomp=`$bb cat split_img/*-*ramdiskcomp`;
if [ -z "$(ls ramdisk/* 2>/dev/null)" ] && [ ! "$ramdiskcomp" == "empty" -a ! "$original" ]; then
  echo "...No files found to be packed/built.";
  abort;
  return 1;
fi;

case $0 in *.sh) clear;; esac;
echo "\nAndroid Image Kitchen - RepackImg Script";
echo "by osm0sis @ xda-developers\n";

if [ ! -z "$(ls *-new.* 2>/dev/null)" ]; then
  echo "...Warning: Overwriting existing files!\n";
fi;
rm -f *-new.*;

if [ "$original" ]; then
  echo "...Repacking with original ramdisk...";
elif [ "$ramdiskcomp" == "empty" ]; then
  echo "...Warning: Using empty ramdisk for repack!";
  compext=.empty;
  touch ramdisk-new.cpio$compext;
else
  #echo "Packing ramdisk...\n";
  if [ ! "$level" ]; then
    case $ramdiskcomp in
      xz) level=-1;;
      lz4*) level=-9;;
    esac;
  fi;
  if [ "$($bb cat bin/SETPERM.txt)" != "1" ]; then
  echo "...Packing ramdisk...\n";
  echo "...Using compression: $ramdiskcomp$lvltxt";
  fi
  
  if [ "$($bb cat bin/SETPERM.txt)" == "1" ]; then
  echo
$bb find split_img/config -name "perm*.txt" | while read pr; do
#file_config="$pr"
case "$pr" in
split_img/config/perm.txt ) pack_d="ramdisk" ;;
split_img/config/perm00.txt ) pack_d="ramdisk00" ;;
split_img/config/perm01.txt ) pack_d="ramdisk01" ;;
esac
  echo "...Установка разрешений $pack_d..."
  
#perm-fs.android "${pack_d}" "${file_config}" &> /dev/null
$bb cat "$pr" | $bb grep -Ev "^/ " | while read a b c d e; do
$bb chmod "$d" "$a"
$bb chown "$b":"$c" "$a"
done
done
#$bb rm -f split_img/config/*-perm-fs*
echo "...Упаковка ramdisk..."
echo "...Используется сжатие: $ramdiskcomp$lvltxt"
fi
 
   vnd_ver="$($bb awk '/vendor boot image header version:/ { print $6 }' split_img/config/conf.txt)"
  
  #if [ "$($bb awk '/vendor boot image header version:/ { print $6 }' split_img/config/conf.txt)" == "4" ]; then
    #vnd_ver="4"
    #fi
  #if [ ! -z "$($bb find "$aik"/split_img/config -type f | $bb grep "ramdisk01_dec.log")" ]; then
  
   #if [ ! -z "$($bb find "$aik"/split_img/config -type f | $bb grep "ramdisk01_dec.log")" -a ! -z "$($bb ls split_img/config/*ramdisk01 2> /dev/null)" ]; then
   if [ ! -z "$($bb cat "$aik"/split_img/config/conf.txt | $bb grep "_ramdisk01:")" ]; then
   
   frag_real="true"
   else
   frag_real="false"
   fi
   
   if [ ! -z "$($bb cat "$aik"/split_img/config/conf.txt | $bb grep "boot magic: VNDRBOOT")" ]; then
  v_b="1"
  fi
  
  if [ "$frag_real" == "true" ]; then
  if [ -z "$($bb find "$aik"/split_img/config -type f | $bb grep "ramdisk01_dec.log")" -o -z "$($bb ls split_img/config/*ramdisk01 2> /dev/null)" ]; then
  
 frag_real="false"
  delete_ram="1"
  echo
  echo "...Удаляем ramdisk01..."
  fi
  
  if [ ! -z "$($bb ls split_img/config/*ramdisk00 2> /dev/null)" -a ! -z "$($bb ls split_img/config/*ramdisk01 2> /dev/null)" -a "$($bb cat split_img/config/UNITE_ramdisk.txt)" == "1" ] ; then
shared_disk="1"

frag_real="false"
  echo
  echo "...Объединяем ramdisk00 и ramdisk01..."
  
  elif [ ! -z "$($bb ls split_img/config/*ramdisk00 2> /dev/null)" -a ! -z "$($bb ls split_img/config/*ramdisk01 2> /dev/null)" -a "$($bb cat split_img/config/UNITE_ramdisk.txt)" == "0" -a "$($bb cat split_img/config/MAG.txt)" == "1" ] ; then

shared_disk="1"

frag_real="false"
  echo
  echo "...Собираем vendor_boot для патча magisk..."
  if [ -s split_img/config/bootconfig ]; then
  $bb cp -f split_img/config/bootconfig /data/local
  echo
  echo "...Внимание! bootconfig не пустой, сохранено: bootconfig -> data/local/bootconfig"
  else
  echo
  echo "...Внимание! bootconfig пустой, сохранение не требуется"
  fi
fi
cd "$aik"/split_img/config
$bb find -name "*ramdisk[0-9]*_dec.log" -type f  | while read rd; do
 log_comp="$(echo "$rd" | $bb grep -o "[0-9]*")"
#comp="$log_comp"
compcmd="$($bb cat "$rd")"
repackcmd="$bb $compcmd $level";
  compext="$compcmd";
case "$compcmd" in
    gzip) compext=gz;;
    lzop) compext=lzo;;
    xz) repackcmd="$bin/xz $level -Ccrc32";;
    lzma) repackcmd="$bin/xz $level -Flzma";;
    bzip2) compext=bz2;;
    lz4) repackcmd="$bin/lz4 -9";;
    lz4-l) repackcmd="$bin/lz4 "$level" -l --favor-decSpeed"; compext=lz4;;
   cpio) repackcmd="$bb cat"; compext="";;
    *) abort; exit 1;;
  esac;
 if [ "$compext" ]; then
    compext=.$compext;
 fi;
 if [ ! -f ramdisk"$log_comp"-new.cpio$compext ]; then
cd $aik/ramdisk"$log_comp"

 $bb find . | cpio -H newc -o 2>/dev/null | $repackcmd > ../ramdisk"$log_comp"-new.cpio$compext;

cd $aik/split_img/config
echo "$aik/ramdisk"$log_comp"-new.cpio$compext" > outfile"$log_comp".txt
else
$bb cp -f ramdisk"$log_comp"-new.cpio$compext "$aik"
echo "$aik/ramdisk"$log_comp"-new.cpio$compext" > outfile"$log_comp".txt
echo
echo "...Собираем со сторонним ramdisk${log_comp}-new.cpio$compext..."
sleep 2
fi
done
cd $aik
else
cd $aik
 fi
 #else
 
  repackcmd="$bb $ramdiskcomp $level";
  compext=$ramdiskcomp;
  case $ramdiskcomp in
    gzip) compext=gz;;
    lzop) compext=lzo;;
    xz) repackcmd="$bin/xz $level -Ccrc32";;
    lzma) repackcmd="$bin/xz $level -Flzma";;
    bzip2) compext=bz2;;
    lz4) repackcmd="$bin/lz4 $level";;
    lz4-l) repackcmd="$bin/lz4 $level -l --favor-decSpeed"; compext=lz4;;
    cpio) repackcmd="$bb cat"; compext="";;
    *) abort; exit 1;;
  esac;
  if [ "$compext" ]; then
    compext=.$compext;
  fi;
  #cd ramdisk;
  #cd $aik;
  #$bb find . | cpio -H newc -o 2>/dev/null | $repackcmd > ../ramdisk-new.cpio$compext;
  #echo "$aik/ramdisk-new.cpio$compext" > "$aik"/split_img/config/outfile.txt
  #avbroot cpio pack --output ramdisk-new.cpio -q --input-tree ramdisk
  #$bin/lz4 $level -l -q --favor-decSpeed ramdisk-new.cpio ramdisk-new.cpio.lz4
  

  if [ -f "$aik/split_img/config/ramdisk-new.cpio$compext" ]; then
$bb cp -f "$aik/split_img/config/ramdisk-new.cpio$compext" "$aik"
echo
echo "...Собираем со сторонним ramdisk-new.cpio$compext..."
sleep 2
elif [ -f "$aik/split_img/config/ramdisk01-new.cpio$compext" -a "$frag_real" == "false" -a "$vnd_ver" == "4" ]; then
  add_ram="1"
cd ramdisk;
 echo
 echo "...Добавляем сторонний ramdisk01-new.cpio$compext..."
 
  $bb find . | cpio -H newc -o 2>/dev/null | $repackcmd > ../ramdisk-new.cpio$compext;
  #echo "$aik/ramdisk-new.cpio$compext" > "$aik"/split_img/config/outfile.txt
$bb cp -f "$aik/split_img/config/ramdisk01-new.cpio$compext" "$aik"
  echo "$aik/ramdisk01-new.cpio$compext" > "$aik"/split_img/config/outfile01.txt

else
if [ "$delete_ram" == "1" ]; then
 cd ramdisk00;
  $bb find . | cpio -H newc -o 2>/dev/null | $repackcmd > ../ramdisk-new.cpio$compext;
  elif [ "$shared_disk" == "1" ]; then
  cd ramdisk;
  $bb find . | cpio -H newc -o 2>/dev/null | $repackcmd > ../ramdisk-new.cpio$compext;
  else
  
 cd ramdisk;
  $bb find . | cpio -H newc -o 2>/dev/null | $repackcmd > ../ramdisk-new.cpio$compext;
  #echo "$aik/ramdisk-new.cpio$compext" > "$aik"/split_img/config/outfile.txt
  fi
fi
 fi
 
  if [ $? != 0 ]; then
    abort;
    return 1;
  fi;
  cd ..;

 [ "$v_b" != "1" ] && echo "\n...Getting build information...";
cd "$aik"/split_img;
#cd split_img
imgtype=`$bb cat *-imgtype`;
case $imgtype in
  KRNL) ;;
  AOSP_VDNR) vendor=vendor_;;
  *)
    if [ -f *-kernel ]; then
      kernel=`ls *-kernel`;               echo "kernel = $kernel";
      kernel="split_img/$kernel";
    fi;
  ;;
esac;
if [ "$original" ]; then
  ramdisk=`ls *-*ramdisk.cpio*`;          echo "${vendor}ramdisk = $ramdisk";
  ramdisk="split_img/$ramdisk";
else
  ramdisk="ramdisk-new.cpio$compext";
fi;
case $imgtype in
  KRNL) rsz=$($bb wc -c < ../"$ramdisk"); echo "ramdisk_size = $rsz";;
  OSIP)                                   echo "cmdline = $($bb cat *-*cmdline)";;
  U-Boot)
    name=`$bb cat *-name`;                    echo "name = $name";
    arch=`$bb cat *-arch`;
    os=`$bb cat *-os`;
    type=`$bb cat *-type`;
    comp=`$bb cat *-comp`;                    echo "type = $arch $os $type ($comp)";
    [ "$comp" == "uncompressed" ] && comp=none;
    addr=`$bb cat *-addr`;                    echo "load_addr = $addr";
    ep=`$bb cat *-ep`;                        echo "entry_point = $ep";
  ;;
  *)
  
    if [ -f *-second ]; then
      second=`ls *-second`;               echo "second = $second";
      second=(--second "split_img/$second");
    fi;
    if [ -f *-dtb ]; then
      dtb=`ls *-dtb`;
     [ "$v_b" != "1" ] && echo "dtb = $dtb";
      dtb=(--dtb "split_img/$dtb");
    fi;
    if [ -f *-recovery_dtbo ]; then
      recoverydtbo=`ls *-recovery_dtbo`;  echo "recovery_dtbo = $recoverydtbo";
      recoverydtbo=(--recovery_dtbo "split_img/$recoverydtbo");
    fi;
    if [ -f *-cmdline -o -f *_cmdline ]; then
      cmdname=`ls *-*cmdline`;
      cmdline=`$bb cat *-*cmdline`;           [ "$v_b" != "1" ] && echo "${vendor}cmdline = $cmdline";
   cmd=("split_img/$cmdname"@cmdline);
    fi;
    if [ -f *-board ]; then
      board=`$bb cat *-board`;                [ "$v_b" != "1" ] && echo "board = $board";
    fi;
    if [ -f *-base ]; then
     base=`$bb cat *-base` 
     [ "$v_b" != "1" ] && echo "base = $base";
    fi;
    if [ -f *-pagesize ]; then
      pagesize=`$bb cat *-pagesize`;          [ "$v_b" != "1" ] && echo "pagesize = $pagesize";
    fi;
    if [ -f *-kernel_offset ]; then
      kerneloff=`$bb cat *-kernel_offset`;    [ "$v_b" != "1" ] && echo "kernel_offset = $kerneloff";
    fi;
    if [ -f *-ramdisk_offset ]; then
      ramdiskoff=`$bb cat *-ramdisk_offset`;  [ "$v_b" != "1" ] && echo "ramdisk_offset = $ramdiskoff";
    fi;
    if [ -f *-second_offset ]; then
      secondoff=`$bb cat *-second_offset`;    echo "second_offset = $secondoff";
    fi;
    if [ -f *-tags_offset ]; then
      tagsoff=`$bb cat *-tags_offset`;        [ "$v_b" != "1" ] && echo "tags_offset = $tagsoff";
    fi;
    if [ -f *-dtb_offset ]; then
      dtboff=`$bb cat *-dtb_offset`;          [ "$v_b" != "1" ] && echo "dtb_offset = $dtboff";
    fi;
    if [ -f *-os_version ]; then
      osver=`$bb cat *-os_version`;           echo "os_version = $osver";
    fi;
    if [ -f *-os_patch_level ]; then
      oslvl=`$bb cat *-os_patch_level`;       echo "os_patch_level = $oslvl";
    fi;
    if [ -f *-header_version ]; then
      hdrver=`$bb cat *-header_version`;      [ "$v_b" != "1" ] && echo "header_version = $hdrver";
    fi;
    if [ -f *-hashtype ]; then
      hashtype=`$bb cat *-hashtype`;          echo "hashtype = $hashtype";
      hashtype="--hashtype $hashtype";
    fi;
    if [ -f *-dt ]; then
      dttype=`$bb cat *-dttype`;
      dt=`ls *-dt`;                       echo "dt = $dt";
      rpm=("split_img/$dt",rpm);
      dt=(--dt "split_img/$dt");
    fi;
    if [ -f *-unknown ]; then
      unknown=`$bb cat *-unknown`;            echo "unknown = $unknown";
    fi;
    if [ -f *-header ]; then
      header=`ls *-header`;
      header="split_img/$header";
    fi;
    if [ -f bootconfig ]; then
     conf_boot="--vendor_bootconfig split_img/bootconfig"
    fi;
  ;;
esac;
cd ..;

if [ -f split_img/*-mtktype ]; then
  mtktype=`$bb cat split_img/*-mtktype`;
  echo "\n...Generating MTK headers...\n";
  echo "...Using ramdisk type: $mtktype";
  $bin/mkmtkhdr --kernel "$kernel" --$mtktype "$ramdisk" >/dev/null;
  if [ $? != 0 ]; then
    abort;
    return 1;
  fi;
  $bb mv -f "$($bb basename "$kernel")-mtk" kernel-new.mtk;
  $bb mv -f "$($bb basename "$ramdisk")-mtk" $mtktype-new.mtk;
  kernel=kernel-new.mtk;
  ramdisk=$mtktype-new.mtk;
fi;

if [ -f split_img/*-sigtype ]; then
  outname=unsigned-new.img;
else
  outname=image-new.img;
fi;

[ "$dttype" == "ELF" ] && repackelf=1;
if [ "$imgtype" == "ELF" ] && [ ! "$header" -o ! "$repackelf" ]; then
  imgtype=AOSP;
  echo "\n...Warning: ELF format without RPM detected; will be repacked using AOSP format!";
fi;

 echo "\n...Building image...\n";
 echo "...Using format: $imgtype\n";
 case $imgtype in
  AOSP_VNDR)
  
 cmdline=$($bb cat split_img/config/conf.txt | $bb grep "^\--vendor_cmdline" | $bb sed 's!^--vendor_cmdline !!')
 echo "cmdline = $cmdline"
 
 board=$($bb cat split_img/config/conf.txt | $bb awk '/^\--board/ { print $2 }')
 echo  "board = $board"
 
 base=$($bb cat split_img/config/conf.txt | $bb grep "^\--base")
 echo "$base" | $bb sed 's!^--!!' | $bb awk '{ print $1" ""="" "$2}'
 
 pagesize=$($bb cat split_img/config/conf.txt | $bb grep "^\--pagesize")
 echo "$pagesize" | $bb sed 's!^--!!' | $bb awk '{ print $1" ""="" "$2}'
 
 kerneloff=$($bb cat split_img/config/conf.txt | $bb grep "^\--kernel_offset")
 echo "$kerneloff" | $bb sed 's!^--!!' | $bb awk '{ print $1" ""="" "$2}'
 
 ramdiskoff=$($bb cat split_img/config/conf.txt | $bb grep "^\--ramdisk_offset")
 echo "$ramdiskoff" | $bb sed 's!^--!!' | $bb awk '{ print $1" ""="" "$2}'
 
 tagsoff=$($bb cat split_img/config/conf.txt | $bb grep "^\--tags_offset")
 echo "$tagsoff" | $bb sed 's!^--!!' | $bb awk '{ print $1" ""="" "$2}'
 
 dtboff=$($bb cat split_img/config/conf.txt | $bb grep "^\--dtb_offset")
 echo "$dtboff" | $bb sed 's!^--!!' | $bb awk '{ print $1" ""="" "$2}'
 
 if [ -f split_img/config/bootconfig ]; then
  conf_boot="--vendor_bootconfig split_img/config/bootconfig"
 #echo "$conf_boot" | $bb sed 's!^--!!' | $bb awk '{ print $1" ""="" "$2}'
 fi
 
 hdrver="--header_version $vnd_ver"
 echo "$hdrver" | $bb sed 's!^--!!' | $bb awk '{ print $1" ""="" "$2}'
 echo

if [ "$vnd_ver" == "4" -a "$frag_real" == "true" ]; then

ramdisk00="--vendor_ramdisk_fragment $($bb cat split_img/config/outfile00.txt)"
ramdisk_type00="--ramdisk_type $(conf_parser split_img/config/conf.txt | $bb awk '/ramdisk_type00/ { print $3 }')"
arg_ramdisk_name00="--ramdisk_name"
ramdisk_name00=$(conf_parser split_img/config/conf.txt | $bb awk -F"=" '/ramdisk_name00/ { print $2 }' | $bb sed 's!^ !!')
ramdisk_board00=$(conf_parser split_img/config/conf.txt | $bb awk -F"=" '/ramdisk_board00/ { print $2 }')
 
if [ -s split_img/config/outfile01.txt ]; then
 
ramdisk01="--vendor_ramdisk_fragment $($bb cat split_img/config/outfile01.txt)"
ramdisk_type01="--ramdisk_type $(conf_parser split_img/config/conf.txt | $bb awk '/ramdisk_type01/ { print $3 }')"
arg_ramdisk_name01="--ramdisk_name"
ramdisk_name01=$(conf_parser split_img/config/conf.txt | $bb awk -F"=" '/ramdisk_name01/ { print $2 }' | $bb sed 's!^ !!')
ramdisk_board01=$(conf_parser split_img/config/conf.txt | $bb awk -F"=" '/ramdisk_board01/ { print $2 }')
fi
 
if [ -s split_img/config/outfile02.txt ]; then
 
ramdisk02="--vendor_ramdisk_fragment $($bb cat split_img/config/outfile02.txt)"
ramdisk_type02="--ramdisk_type $(conf_parser split_img/config/conf.txt | $bb awk '/ramdisk_type02/ { print $3 }')"
arg_ramdisk_name02="--ramdisk_name"
ramdisk_name02=$(conf_parser split_img/config/conf.txt | $bb awk -F"=" '/ramdisk_name02/ { print $2 }' | $bb sed 's!^ !!')
ramdisk_board02=$(conf_parser split_img/config/conf.txt | $bb awk -F"=" '/ramdisk_board02/ { print $2 }')
fi
 
 
 mkboot $ramdisk_type00 $arg_ramdisk_name00 "$ramdisk_name00" $ramdisk_board00 $ramdisk00 $ramdisk_type01 $arg_ramdisk_name01 $ramdisk_name01 $ramdisk_board01 $ramdisk01 $ramdisk_type02 $arg_ramdisk_name02 $ramdisk_name02 $ramdisk_board02 $ramdisk02 $conf_boot "${dtb[@]}" --vendor_cmdline "$cmdline" --board "$board" $base $pagesize $kerneloff $ramdiskoff $tagsoff $dtboff --os_version "$osver" --os_patch_level "$oslvl" $hdrver --vendor_boot $outname
 
#mkboot $hdrver $pagesize $base $kerneloff $ramdiskoff $tagsoff $dtboff --vendor_cmdline "$cmdline" --board "$board" "${dtb[@]}" $conf_boot  $ramdisk_type00 $arg_ramdisk_name00 "$ramdisk_name00" $ramdisk_board00 $ramdisk00 $ramdisk_type01 $arg_ramdisk_name01 $ramdisk_name01 $ramdisk_board01 $ramdisk01 $ramdisk_type02 $arg_ramdisk_name02 $ramdisk_name02 $ramdisk_board02 $ramdisk02 --vendor_boot $outname
 
 elif [ "$vnd_ver" == "4" -a "$frag_real" == "false" -a "$($bb awk '/vendor ramdisk table size:/ { print $5 }' split_img/config/conf.txt)" != "0" -a "$add_ram" == "1" ]; then
 
ramdisk_type=$(conf_parser split_img/config/conf.txt | $bb awk '/ramdisk_type00/ { print $3 }')
ramdisk_name=$(conf_parser split_img/config/conf.txt | $bb awk -F"=" '/ramdisk_name00/ { print $2 }' | $bb sed 's!^ !!')
ramdisk_board=$(conf_parser split_img/config/conf.txt | $bb awk -F"=" '/ramdisk_board00/ { print $2 }')

ramdisk01=$($bb cat split_img/config/outfile01.txt)
ramdisk_type01="0x2"
ramdisk_name01="recovery"
 
  mkboot --ramdisk_type $ramdisk_type --ramdisk_name "$ramdisk_name" $ramdisk_board --vendor_ramdisk_fragment "$ramdisk" --ramdisk_type $ramdisk_type01 --ramdisk_name $ramdisk_name01 --vendor_ramdisk_fragment "$ramdisk01" $conf_boot "${dtb[@]}" --vendor_cmdline "$cmdline" --board "$board" $base $pagesize $kerneloff $ramdiskoff $tagsoff $dtboff --os_version "$osver" --os_patch_level "$oslvl" $hdrver --vendor_boot $outname
  
  elif [ "$vnd_ver" == "4" -a "$frag_real" == "false" -a "$($bb cat split_img/config/MAG.txt 2> /dev/nul)" == "1" ]; then
   
   "$bin"/mkbootimg --vendor_ramdisk "$ramdisk" "${dtb[@]}" --vendor_cmdline "$cmdline" --board "$board" $base $pagesize $kerneloff $ramdiskoff $tagsoff $dtboff --os_version "$osver" --os_patch_level "$oslvl" $hdrver --vendor_boot $outname
  
  elif [ "$vnd_ver" == "4" -a "$frag_real" == "false" -a "$($bb awk '/vendor ramdisk table size:/ { print $5 }' split_img/config/conf.txt)" != "0" ]; then
  
ramdisk_type=$(conf_parser split_img/config/conf.txt | $bb awk '/ramdisk_type00/ { print $3 }')
ramdisk_name=$(conf_parser split_img/config/conf.txt | $bb awk -F"=" '/ramdisk_name00/ { print $2 }' | $bb sed 's!^ !!')
ramdisk_board=$(conf_parser split_img/config/conf.txt | $bb awk -F"=" '/ramdisk_board00/ { print $2 }')

   mkboot --ramdisk_type $ramdisk_type --ramdisk_name "$ramdisk_name" $ramdisk_board --vendor_ramdisk_fragment $ramdisk $conf_boot "${dtb[@]}" --vendor_cmdline "$cmdline" --board "$board" $base $pagesize $kerneloff $ramdiskoff $tagsoff $dtboff --os_version "$osver" --os_patch_level "$oslvl" $hdrver --vendor_boot $outname
   
   #elif [ "$vnd_ver" == "4" -a "$frag_real" == "false" -a "$($bb awk '/vendor ramdisk table size:/ { print $5 }' split_img/config/conf.txt)" == "0" ]; then
   
   #mkboot --vendor_ramdisk "$ramdisk" $conf_boot "${dtb[@]}" --vendor_cmdline "$cmdline" --board "$board" $base $pagesize $kerneloff $ramdiskoff $tagsoff $dtboff --os_version "$osver" --os_patch_level "$oslvl" $hdrver --vendor_boot $outname

  else
  
    mkboot --vendor_ramdisk "$ramdisk" $conf_boot "${dtb[@]}" --vendor_cmdline "$cmdline" --board "$board" $base $pagesize $kerneloff $ramdiskoff $tagsoff $dtboff --os_version "$osver" --os_patch_level "$oslvl" $hdrver --vendor_boot $outname
    
    #"$bin"/mkbootimg --vendor_ramdisk "$ramdisk" "${dtb[@]}" --vendor_cmdline "$cmdline" --board "$board" $base $pagesize $kerneloff $ramdiskoff $tagsoff $dtboff --os_version "$osver" --os_patch_level "$oslvl" $hdrver --vendor_boot $outname
  fi;;
  AOSP) "$bin"/mkbootimg --kernel "$kernel" --ramdisk "$ramdisk" "${second[@]}" "${dtb[@]}" "${recoverydtbo[@]}" --cmdline "$cmdline" --board "$board" --base $base --pagesize $pagesize --kernel_offset $kerneloff --ramdisk_offset $ramdiskoff --second_offset "$secondoff" --tags_offset "$tagsoff" --dtb_offset "$dtboff" --os_version "$osver" --os_patch_level "$oslvl" --header_version "$hdrver" $hashtype "${dt[@]}" -o $outname;;
  AOSP-PXA) $bin/pxa-mkbootimg --kernel "$kernel" --ramdisk "$ramdisk" "${second[@]}" --cmdline "$cmdline" --board "$board" --base $base --pagesize $pagesize --kernel_offset $kerneloff --ramdisk_offset $ramdiskoff --second_offset "$secondoff" --tags_offset "$tagsoff" --unknown $unknown "${dt[@]}" -o $outname;;
  ELF) $bin/elftool pack -o $outname header="$header" "$kernel" "$ramdisk",ramdisk "${rpm[@]}" "${cmd[@]}" >/dev/null;;
  KRNL) $bin/rkcrc -k "$ramdisk" $outname;;
  OSIP)
    mkdir split_img/.temp 2>/dev/null;
    for i in bootstub cmdline.txt hdr kernel parameter sig; do
      $bb cp -f split_img/*-*$($bb basename $i .txt | $bb sed -e 's/hdr/header/') split_img/.temp/$i 2>/dev/null;
    done;
    $bb cp -f "$ramdisk" split_img/.temp/ramdisk.cpio.gz;
    $bin/mboot -d split_img/.temp -f $outname;
  ;;
  U-Boot)
    part0="$kernel";
    case $type in
      Multi) part1=(:"$ramdisk");;
      RAMDisk) part0="$ramdisk";;
    esac;
    $bin/mkimage -A $arch -O $os -T $type -C $comp -a $addr -e $ep -n "$name" -d "$part0""${part1[@]}" $outname >/dev/null;
  ;;
  *) echo "\n...Unsupported format."; abort; return 1;;
esac;
if [ $? != 0 ]; then
  abort;
  return 1;
fi;

$bb rm -rf split_img/.temp;

if [ -f split_img/*-sigtype ]; then
  sigtype=`$bb cat split_img/*-sigtype`;
  if [ -f split_img/*-avbtype ]; then
    avbtype=`$bb cat split_img/*-avbtype`;
  fi;
  if [ -f split_img/*-blobtype ]; then
    blobtype=`$bb cat split_img/*-blobtype`;
  fi;
  echo "...Signing new image...\n";
  echo "...Using signature: $sigtype $avbtype$avbtxt$blobtype\n";
  [ ! "$avbkey" ] && avbkey="$bin/avb/verity";
  case $sigtype in
    AVBv1)
      dalvikvm -Xnodex2oat -Xnoimage-dex2oat -cp $bin/boot_signer-dexed.jar com.android.verity.BootSignature /$avbtype unsigned-new.img "$avbkey.pk8" "$avbkey.x509."* image-new.img 2>/dev/null \
        || dalvikvm -Xnoimage-dex2oat -cp $bin/boot_signer-dexed.jar com.android.verity.BootSignature /$avbtype unsigned-new.img "$avbkey.pk8" "$avbkey.x509."* image-new.img 2>/dev/null;
    ;;
    BLOB)
      $bb printf '-SIGNED-BY-SIGNBLOB-\00\00\00\00\00\00\00\00' > image-new.img;
      $bin/blobpack blob.tmp $blobtype unsigned-new.img >/dev/null;
      $bb cat blob.tmp >> image-new.img;
     $bb rm -f blob.tmp;
    ;;
    CHROMEOS) $bin/futility vbutil_kernel --pack image-new.img --keyblock $bin/chromeos/kernel.keyblock --signprivate $bin/chromeos/kernel_data_key.vbprivk --version 1 --vmlinuz unsigned-new.img --bootloader $bin/chromeos/empty --config $bin/chromeos/empty --arch arm --flags 0x1;;
    DHTB)
      $bin/dhtbsign -i unsigned-new.img -o image-new.img >/dev/null;
     $bb rm -f split_img/*-tailtype 2>/dev/null;
    ;;
    NOOK*) $bb cat split_img/*-master_boot.key unsigned-new.img > image-new.img;;
  esac;
  if [ $? != 0 ]; then
    abort;
    return 1;
  fi;
fi;

if [ -f split_img/*-lokitype ]; then
  lokitype=`$bb cat split_img/*-lokitype`;
  echo "...Loki patching new image...\n";
  echo "...Using type: $lokitype\n";
  $bb mv -f image-new.img unlokied-new.img;
  if [ -f aboot.img ]; then
    $bin/loki_tool patch $lokitype aboot.img unlokied-new.img image-new.img >/dev/null;
    if [ $? != 0 ]; then
      echo "...Patching failed.";
      abort;
      return 1;
    fi;
  else
    echo "...Device aboot.img required in script directory to find Loki patch offset.";
    abort;
    return 1;
  fi;
elif [ -f split_img/*-microloader.bin ]; then
  echo "...Amonet patching new image...\n";
  $bb cp -f image-new.img unamonet-new.img;
  $bb cp -f split_img/*-microloader.bin microloader.tmp;
  $bb dd bs=1024 count=1 conv=notrunc if=unamonet-new.img of=head.tmp 2>/dev/null;
  $bb dd bs=1024 seek=1 conv=notrunc if=head.tmp of=image-new.img 2>/dev/null;
  $bb dd conv=notrunc if=microloader.tmp of=image-new.img 2>/dev/null;
 $bb rm -f head.tmp microloader.tmp;
fi;

if [ -f split_img/*-tailtype ]; then
  tailtype=`$bb cat split_img/*-tailtype`;
  echo "...Appending footer...\n";
  echo "...Using type: $tailtype\n";
  case $tailtype in
    Bump) $bb printf '\x41\xA9\xE4\x67\x74\x4D\x1D\x1B\xA4\x29\xF2\xEC\xEA\x65\x52\x79' >> image-new.img;;
    SEAndroid) $bb printf 'SEANDROIDENFORCE' >> image-new.img;;
  esac;
fi;

if [ "$origsize" -a -f split_img/*-origsize ]; then
  filesize=`$bb cat split_img/*-origsize`;
  echo "...Padding to original size...\n";
  $bb cp -f image-new.img unpadded-new.img;
  $bb truncate -s $filesize image-new.img;
fi;

echo "...Done!";

$bb find "$aik" -maxdepth 1 -name "ramdisk*new*" -type f -exec $bb rm -f {} \;
return 0;

