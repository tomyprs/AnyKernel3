# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=kang Kernel
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=whyred
device.name2=redmi note 5 pro
device.name3=
device.name4=
device.name5=
supported.versions=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;

ui_print " "
ui_print "Swipe up the screen or press any volume key first"

# Keycheck
INSTALLER=$(pwd)
KEYCHECK=$INSTALLER/tools/keycheck
chmod 755 $KEYCHECK

keytest() {
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

choose() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $KEYCHECK
  $KEYCHECK
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    ui_print "   Vol key not detected!"
    abort "   Use name change method in TWRP"
  fi
}

if [ -z $NEW ]; then
  if keytest; then
    FUNCTION=choose
  else
    FUNCTION=chooseold
    ui_print " "
    ui_print "- Vol Key Programming -"
    ui_print "   Press Volume Up Key: "
    $FUNCTION "UP"
    ui_print "   Press Volume Down Key: "
    $FUNCTION "DOWN"
  fi
  ui_print " "
  ui_print "- Select Option -"
  ui_print "  Choose which option Cam Libs you want: "
  ui_print "  + Volume Up = New Cam "
  ui_print "  - Volume Down = Old Cam "
  if $FUNCTION; then
    NEW=true
  else
    NEW=false
  fi
else
  ui_print "   Will Install Old Cam. If error reflash this kernel, and choose NewCam"
fi

## AnyKernel install
dump_boot;

  # Concatenate all of the dtbs to the kernel
  if $NEW; then
    mv /tmp/anykernel/newcam/Image.gz-dtb /tmp/anykernel/Image.gz-dtb;
  else
    mv /tmp/anykernel/oldcam/Image.gz-dtb /tmp/anykernel/Image.gz-dtb;
  fi

write_boot;
## end install

