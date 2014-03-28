#!/bin/bash
old_IFS=$IFS      # save the field separator         
IFS=$'\n'
fsep=:
file=$1
pdf_file=$2
end_page='';
for row in `cat $file` ; do
  if [[ $row != \#* ]]; then
    letter=`echo $row | awk -F $fsep '{print $1}'`
    _page=`echo $row | awk -F $fsep '{print $2}'`
    end_page=`expr $_page - 1`
    if [[ $start_page != '' ]]; then
      echo "$print_letter -> $start_page-$end_page"
      pdftk $pdf_file cat $start_page-$end_page output ${print_letter}_scio.pdf dont_ask
    fi
    print_letter=$letter
    start_page=$_page
  fi
done
#echo "$print_letter -> $start_page-$end_page"
IFS=$old_IFS
