#!/bin/bash
# import table from sql file to pgc database
PASS=compaq
USER=root
DB=pzk
echo "Importing data from file '$1'..."
mysql -u $USER --password=$PASS $DB < $1
echo Done. 
