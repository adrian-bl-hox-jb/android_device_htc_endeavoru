#!/system/bin/sh

MOUNT_TARGET="/data/media"
MOUNT_SOURCE="/dev/block/mmcblk0p14"


# create mountpoint
/system/bin/mkdir                    ${MOUNT_TARGET}
/system/bin/chown media_rw:media_rw  ${MOUNT_TARGET}
/system/bin/chmod 0770               ${MOUNT_TARGET}
echo 2 > /data/.layout_version

#...and mount the volume with the correct permissions
/system/bin/grep -q ${MOUNT_SOURCE} /proc/mounts || /system/bin/fsck_msdos -p ${MOUNT_SOURCE}
/system/bin/mount -t vfat -o uid=1023,gid=1023,umask=0007 ${MOUNT_SOURCE} ${MOUNT_TARGET} || exit





if [ -d ${MOUNT_TARGET}/0 ]; then
	echo "Already using the 4.2 layout, no need to migrate"
	exit
fi

echo "Migrating existing sdcard to 4.2 layout"

# migrate existing sdcard data to 0/
/system/bin/mkdir ${MOUNT_TARGET}/0 || exit  # should not happen!

for x in ${MOUNT_TARGET}/{*,.*} ; do
	/system/bin/mv $x ${MOUNT_TARGET}/0
done

