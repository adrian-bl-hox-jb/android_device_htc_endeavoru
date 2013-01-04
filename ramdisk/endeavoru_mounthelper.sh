#!/system/bin/sh

PART_DATA="/dev/block/mmcblk0p15"
DEST_DATA="/data"

PART_SDCARD="/dev/block/mmcblk0p14"
DEST_SDCARD="/data/media"

# same as /data - only used if sdcard is /data
PART_DALVIK="/dev/block/mmcblk0p15"
DEST_DALVIK="/data/dalvik-cache"

## mounts $PART_SDCARD to $DEST_SDCARD
## assumes a vfat formatted sdcard
function mount_vfat_sdcard() {
	# create mountpoint
	mkdir                    ${DEST_SDCARD}
	chown media_rw:media_rw  ${DEST_SDCARD}
	chmod 0770               ${DEST_SDCARD}
	echo 2 > /data/.layout_version
	#...and mount the volume with the correct permissions
	grep -q ${PART_SDCARD} /proc/mounts || fsck_msdos -p ${PART_SDCARD}
	mount -t vfat -o uid=1023,gid=1023,umask=0007 ${PART_SDCARD} ${DEST_SDCARD}
}

## mount $PART_DATA as /data
function mount_ext4_data() {
	e2fsck -y ${PART_DATA}
	mount -t ext4 -o noatime,nosuid,nodev,noauto_da_alloc,discard ${PART_DATA} ${DEST_DATA}
}

## mount dalvik cache
function mount_ext4_dalvik() {
	mkdir               ${DEST_DALVIK}
	chown system:system ${DEST_DALVIK}
	chmod 0771          ${DEST_DALVIK}
	
	e2fsck -y ${PART_DALVIK}
	mount -t ext4 -o noatime,nosuid,nodev,noauto_da_alloc,discard ${PART_DALVIK} ${DEST_DALVIK}
}

## migrates an 'old' storage layout to the 4.2 version
## only needed for vfat sdcards
function migrate_vfat_sdcard() {
	if [ -d ${DEST_SDCARD}/0 ]; then
		echo "Already using the 4.2 layout, no need to migrate"
		return
	fi
	
	if ! grep -q ${DEST_SDCARD} /proc/mounts; then
		echo "Sdcard not mounted, skipping migration"
		return
	fi
	
	echo "Migrating existing sdcard to 4.2 layout"
	# migrate existing sdcard data to 0/
	mkdir ${DEST_SDCARD}/0 || return  # should not happen!
	for x in ${DEST_SDCARD}/{*,.*} ; do
		mv $x ${DEST_SDCARD}/0
	done
}


## main ##

if blkid ${PART_SDCARD} | grep -q 'TYPE="ext4"' ; then
	# sdcard is ext4, so we are going to use this as data!
	PART_DATA=$PART_SDCARD
	mount_ext4_data
	mount_ext4_dalvik
else
	mount_ext4_data
	mount_vfat_sdcard
	migrate_vfat_sdcard
fi

# tell init to continue
touch /dev/.endeavoru_mounthelper_done


