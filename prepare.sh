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

echo "Pøíprava PZK na nové období:"
echo "provede se:"
echo "	1. záloha db"
echo "	2. vymazání 'uchazec0' a 'uchazec1'"
echo "	3. vynulování poèitadla 'counter'"
echo "	4. zakázání pøístupu na 'public' stránky\n"
echo "	99. ---- ruènì upravit ~/pzk/templates/vars_global.tex"
echo ""
echo "Provést operace (ano,ne)?"
read answ

if [ $answ = "ano" ]; then
  echo -n "Zálohuji databázi..."
  $BINDIR/dump_db > /dev/null
  echo "done."

  echo -n "Inicializuji tabulky 'uchazecX'..."
  mysql -u $DB_USER --password=$DB_PASSW pzk -e "delete from uchazec0"
  mysql -u $DB_USER --password=$DB_PASSW pzk -e "delete from uchazec1"
  echo "done."

  echo -n "Inicializuji pole 'counter'..."
  mysql -u $DB_USER --password=$DB_PASSW pzk -e "update config set value='0' where ident='counter'"
  echo "done."

	echo -n "Zakazuji pøístup na 'public' stránky..."
	mysql -u $DB_USER --password=$DB_PASSW pzk -e "update config set value='0' where ident='public'"
	echo "done."

  echo "!! Nezapomeò upravit soubor '$DATADIR/templates/vars_global'"
  echo "Bye."
else
  echo "Nìkdy pøí¹tì!!! Bye."
fi

exit 0
