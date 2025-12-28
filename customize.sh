SKIPUNZIP=1
ui_print " "
ui_print "*********************"
ui_print "- Установка UKA"
ui_print "*********************"
ui_print " "
ui_print "- Подготовка..."
ABI=$(getprop ro.product.cpu.abi)
if [ "$ABI" = "x86" ]; then ui_print "Wrong arch!"; ui_print " "; abort; fi;
if [ "$ABI" = "x86_64" ]; then ui_print "Wrong arch!"; ui_print " "; abort; fi;
touch /data/a_a;
[ ! -f /data/a_a ] && { ui_print "Aborting!"; ui_print "Failed to read\write '/data' partition!"; abort; }
rm -f /data/a_a
[ ! -d /data/local ] && mkdir -m 755 -p /data/local
[ ! -d /data/local ] && { ui_print "Aborting!"; ui_print "Failed to create kitchen directory!"; abort; }
rm -rf  $MODPATH/*;
mkdir -p $MODPATH/system;
[ ! -d $MODPATH/system ] && { ui_print "Aborting!"; ui_print "Failed to create module directory!"; abort; }
unzip -o "$ZIPFILE" "uninstall.sh" -d $MODPATH >/dev/null
unzip -o "$ZIPFILE" "module.prop" -d $MODPATH >/dev/null
ui_print "- Распаковка bin64.tar.xz"
unzip -p "$ZIPFILE" "bin64.tar.xz" |tar xJ -C $MODPATH/system >/dev/null
ui_print "- Распаковка binary64.tar.xz"
unzip -p "$ZIPFILE" "binary64.tar.xz" |tar xJ -C /data >/dev/null
ui_print "- Распаковка python31_64.tar.xz"
unzip -p "$ZIPFILE" "python31_64.tar.xz" |tar xJ -C /data/local >/dev/null
ui_print "- Распаковка aik64.tar.xz"
unzip -p "$ZIPFILE" "aik64.tar.xz" |tar xJ -C /data/local >/dev/null
ui_print "- Установка разрешений..."
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
set_perm_recursive /data/local/binary 0 0 0755 0755
