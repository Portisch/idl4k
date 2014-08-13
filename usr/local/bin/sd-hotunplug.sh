#! /bin/sh

#echo -e "Hotunplug SD $0 \"$MDEV\" \"$SUBSYSTEM\"" > /dev/console

AXE_DEV_REMOVED=10ds4f-ffdfdcfe
AXE_DEV_UNMOUNTED=c1sdf4-bbdfcdef

send_ntfy_to_axe ()
{
 local FS_FIFO_NAME=/tmp/fsmon102342
 if [ -e $FS_FIFO_NAME ];
 then
   echo $1:$MDEV > $FS_FIFO_NAME
 fi
}

BLKID=$(/sbin/blkid /dev/$MDEV)
eval ${BLKID#*:}
if [ -n "$LABEL" ]; then
  MOUNT_POINT=/media/$LABEL
else
  MOUNT_POINT=/media/$MDEV
fi

send_ntfy_to_axe $AXE_DEV_REMOVED

if [ -d "$MOUNT_POINT" ] ; then
    if $(umount -f "$MOUNT_POINT") ; then
	send_ntfy_to_axe $AXE_DEV_UNMOUNTED
	rmdir "$MOUNT_POINT"
    fi
fi

