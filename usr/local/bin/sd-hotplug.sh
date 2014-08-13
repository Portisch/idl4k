#! /bin/sh

#echo -e "Hotplug SD $0 \"$MDEV\" \"$SUBSYSTEM\"" > /dev/console

AXE_DEV_INSERTED=aaccaabb-10ds4f
AXE_DEV_MOUNTED=bbaaccaa-01sdf4
AXE_DEV_MOUNT_FAILED=fbdbcdef-35y74f

send_ntfy_to_axe ()
{  
  local FS_FIFO_NAME=/tmp/fsmon102342

  if [ -e $FS_FIFO_NAME ];
  then
    echo $1:$MDEV > $FS_FIFO_NAME
  fi
}

if [ $# = 0 ]; then
    send_ntfy_to_axe $AXE_DEV_INSERTED
fi

BLKID=$(/sbin/blkid /dev/$MDEV)
eval ${BLKID#*:}
if [ -n "$LABEL" ]; then
  MOUNT_POINT=/media/$LABEL
else
  MOUNT_POINT=/media/$MDEV
fi

mkdir -p "$MOUNT_POINT"
for fs_type in vfat msdos ; do
    #echo "trying $fs_type" > /dev/console
    if $(mount -t $fs_type -o umask=0 /dev/$MDEV "$MOUNT_POINT" 2>/dev/null) ; then
        stat -f "$MOUNT_POINT" >/dev/null 2>&1 &
        #echo "mount $fs_type under "$MOUNT_POINT"" > /dev/console
        send_ntfy_to_axe $AXE_DEV_MOUNTED
        exit 0
    fi
done
for fs_type in ext3 ext2 ; do
    #echo "trying $fs_type" > /dev/console
    if $(mount -t $fs_type /dev/$MDEV "$MOUNT_POINT" 2>/dev/null) ; then
        stat -f "$MOUNT_POINT" >/dev/null 2>&1 &
        #echo "mount $fs_type under "$MOUNT_POINT"" > /dev/console
        if [ "$2" ==  "mkchmod" ]; then
          chmod 777 $MOUNT_POINT
        fi
        send_ntfy_to_axe $AXE_DEV_MOUNTED
        exit 0
    fi
done

#echo "trying ntfs" > /dev/console
if $(ntfs-3g /dev/$MDEV "$MOUNT_POINT" 2>/dev/null) ; then
  stat -f "$MOUNT_POINT" >/dev/null 2>&1 &
  #echo "mount ntfs under "$MOUNT_POINT"" > /dev/console
  send_ntfy_to_axe $AXE_DEV_MOUNTED
  exit 0
fi

send_ntfy_to_axe $AXE_DEV_MOUNT_FAILED

rmdir "$MOUNT_POINT"
