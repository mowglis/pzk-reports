#!/bin/bash
# dump of one table from pgc database
PASS=compaq
USER=root
DB=pzk
echo "Dumping table to file '$1.sql'..."
mysqldump --add-drop-table -u $USER --password=$PASS $DB $1 > $1.sql
echo Done. 
