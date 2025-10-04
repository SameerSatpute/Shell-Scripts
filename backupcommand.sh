#!/usr/bin/bash
MYDIR=$PWD
for i in $*;do
cd $MYDIR
cd -P $(dirname $i)
if ! cd backup 2>/dev/null;then
mkdir backup
cd backup
fi
cd ..
cp -vp $PWD/$(basename $i) $PWD/backup/$(basename $i).$(date +%F.%H.$$)
done