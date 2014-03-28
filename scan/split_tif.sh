#!/bin/bash
# split multipage tiff to separate files
# params -	$1 - predmet [cj,m]
#				$2 - typ [4,6]
work_dir=/home/rusek/pzk/scan
count=0
for file in `ls -1 $work_dir/$1_$2`; do
	count=$(( $count +1 ))
  /usr/bin/tiffsplit $work_dir/$1_$2/$file $work_dir/in/$1_$2/${1}${2}_${count}-
done  
