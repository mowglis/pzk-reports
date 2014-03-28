#!/bin/bash
# skript generuje datove soubory pro odvolani na KU
# soubory jsou pouzite v tabulce odvolaniX.xls
#DIR=/home/sterba/pzk
DIR=$1
MYSQL=`which mysql`
CSTOCS=`which cstocs`
PASS=_seleuser_pzk_123
USR=sele
DB=pzk
FILE=odvolani
EXT=csv
FIELDS="jmeno,prijmeni,id,zast_jmeno,zast_prijmeni,ulice,misto,psc"
ICODE=il2
OCODE=cp1250
rm -f $DIR/$FILE*.$EXT
rm -f $DIR/_$FILE*.$EXT
if [ $2 = "2" ]
then
	TBL=uchazec1
else
	TBL=uchazec0
fi
#for ST in 1 3 
#do
###	for TBL in uchazec0 uchazec1
###	do
#		echo "Generating file $FILE$ST_il2.$EXT with params '$TBL, $ST'"
#		$MYSQL -N -u $USR --password=$PASS $DB -e "select $FIELDS from $TBL where odvolani=1 and id_studium=$ST ORDER BY poradi_od, zps DESC, m+cj DESC, prijmeni,jmeno" >> $DIR/_$FILE$ST.$EXT
		#echo "$DIR/$FILE$ST.$EXT"
###	done	
#	echo "Recode file  _$FILE$ST.$EXT  ($ICODE -> $OCODE) -> $FILE$ST.$EXT"
#	$CSTOCS $ICODE $OCODE $DIR/_$FILE$ST.$EXT > $DIR/$FILE$ST.$EXT
#done	
######!  Uz pouze jedna tabulka pro vsechny tytpy studia ###
#	echo "Generating file _$FILE.$EXT'"
	$MYSQL -N -u $USR --password=$PASS $DB -e "select $FIELDS from $TBL where odvolani=1  AND prijat=0 ORDER BY id_studium, poradi_od, zps DESC, m+cj DESC, prijmeni,jmeno" 
#	> $DIR/_$FILE.$EXT
#	echo "Recode file  _$FILE.$EXT  ($ICODE -> $OCODE) -> $FILE.$EXT"
#	$CSTOCS $ICODE $OCODE $DIR/_$FILE.$EXT > $DIR/$FILE.$EXT
#	$CSTOCS $ICODE $OCODE $DIR/_$FILE.$EXT 
	rm $DIR/_$FILE.$EXT
echo Done.

