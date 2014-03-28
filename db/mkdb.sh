#!/bin/bash
USER=admin_pzk
PASS=krtek
echo "Creating new tables:"
#echo "table 'uchazec'"
#mysql -u $USER --password=$PASS pzk < mktbl_uchazec.sql
echo "ciselniky:"
echo "...typ studia"
mysql -u $USER --password=$PASS pzk < cis_studium.sql
echo "...bodovani prumeru"
mysql -u $USER --password=$PASS pzk < cis_prum.sql
echo "...ucebny"
mysql -u $USER --password=$PASS pzk < cis_ucebna.sql
echo "...zakladni skoly"
mysql -u $USER --password=$PASS pzk < cis_zs.sql
echo "...stredni skoly"
mysql -u $USER --password=$PASS pzk < cis_ss.sql
echo "Done."
