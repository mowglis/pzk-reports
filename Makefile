# sync directory
GYBON=proxy.gybon.cz
get:
	@echo "======> Geting data from '$(GYBON)'"
	rsync -Cavuz $(OPTS) --progress -e ssh --exclude 'temp/*' --exclude 'scan/*' $(GYBON):~/pzk/ .
put:
	@echo "======> Puting data to '$(GYBON)'"
	rsync -Cavuz $(OPTS) --progress -e ssh --exclude 'temp/*' --exclude '*.sql.gz' --exclude 'scan/*' .  $(GYBON):~/pzk
sync:	get put
