################################################################
# skript pro pripravu PZK 
#
# provede:
#	1. zaloha db
#	2. vymazani uchazec0 a uchazec1
#	3. vynulovani 'counter'
#	4. ---- rucne upravit ~/pzk/templates/vars_global.tex
#
################################################################

HTMLDIR=/home/rusek/html/pzk
DATADIR=/home/rusek/pzk
BINDIR=/home/rusek/bin
DB_USER=admin_pzk
DB_PASSW=krtek

echo "P��prava PZK na nov� obdob�:"
echo "provede se:"
echo "	1. z�loha db"
echo "	2. vymaz�n� 'uchazec0' a 'uchazec1'"
echo "	3. vynulov�n� po�itadla 'counter'"
echo "	4. zak�z�n� p��stupu na 'public' str�nky\n"
echo "	99. ---- ru�n� upravit ~/pzk/templates/vars_global.tex"
echo ""
echo "Prov�st operace (ano,ne)?"
read answ

if [ $answ = "ano" ]; then
  echo -n "Z�lohuji datab�zi..."
  $BINDIR/dump_db > /dev/null
  echo "done."

  echo -n "Inicializuji tabulky 'uchazecX'..."
  mysql -u $DB_USER --password=$DB_PASSW pzk -e "delete from uchazec0"
  mysql -u $DB_USER --password=$DB_PASSW pzk -e "delete from uchazec1"
  echo "done."

  echo -n "Inicializuji pole 'counter'..."
  mysql -u $DB_USER --password=$DB_PASSW pzk -e "update config set value='0' where ident='counter'"
  echo "done."

	echo -n "Zakazuji p��stup na 'public' str�nky..."
	mysql -u $DB_USER --password=$DB_PASSW pzk -e "update config set value='0' where ident='public'"
	echo "done."

  echo "!! Nezapome� upravit soubor '$DATADIR/templates/vars_global'"
  echo "Bye."
else
  echo "N�kdy p��t�!!! Bye."
fi

exit 0
