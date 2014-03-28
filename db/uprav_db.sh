#!/bin/bash
# uprava db - 28.02.2004
USER=insdele
PASS=_wruser_pzk_123
mysql -u $USER --password=$PASS pzk -e "update studium set id_studium=2 where id_studium=3"
mysql -u $USER --password=$PASS pzk -e "update ucebna set id_studium=2 where id_studium=3"
echo "Upravy byly dokonceny."
