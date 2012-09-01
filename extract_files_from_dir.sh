#!/bin/sh

BASE=../../../vendor/htc/endeavoru/proprietary
rm -rf $BASE/*

for FILE in `egrep -v '(^#|^$)' proprietary-files.txt`; do
  DIR=`dirname $FILE`
  if [ ! -d $BASE/$DIR ]; then
    mkdir -p $BASE/$DIR
  fi
  cp $1/$FILE $BASE/$FILE
done

./setup-makefiles.sh
