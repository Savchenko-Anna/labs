#!/bin/bash

archive=$1

if [[ ! -e $archive ]]
then
echo "there is no such file"
exit 1
fi

if [[ $archive = "" ]]
then
echo "Choose the archive first"
exit 2
fi

LIMIT=19999

for ((i=10000; i<=LIMIT ; i++))
do
psdw=${i:1:4}
  7z e -p$psdw -o.uncrypt $archive >/dev/null
  if [[ $? = 0 ]]
  then
echo correct password = $psdw
  LIMIT=$i
  fi
rm -r .uncrypt
done

exit 0
