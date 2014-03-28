#!/usr/bin/perl
###############################################################
# davkovy update dat z CSV souboru - Gybon, PZK
#
#	options:
#	-w zapis do db - pouze pri tomto param se provede ZAPIS do db
#	-h help
#	-k kolo (impl.1)
#	-d delimiter (impl. ',')
#################################################################
	use DBI;
	use Cz::Cstocs;
	use Getopt::Std;
	#********  MySQL ****************
	$user_wr = "insdele";
	$passw_wr = "_wruser_pzk_123";
	$mysql_socket = "mysql_socket=/var/lib/mysql/mysql.sock";
	$db_host_port = "DBI:mysql:pzk:localhost:3306";
	$delim = ',';

	sub updateRecord{
		my($cols,$vals) = @_;
		my($set,$whr);
		$whr = 'id='.shift(@$vals);
		foreach $column (@$cols) {
			$set .= $column."=".shift(@$vals).",";
		}
		$set = substr($set,0,-1);
		$sql = "UPDATE $tbl SET $set WHERE $whr";
		#print "SQL:$sql\n";
		if($opt_w){
			$db->do($sql);
			print "  .....updated";
		}
		print "\n";
	}
#---------------------------------------------
# hlavni program
#---------------------------------------------
 	getopts("whk:");
	if($opt_h) {
		# write help
	   print "Import (update) zaznamu uchazecu pro PZK\n";
	   print "use: imp_pzk.pl [-w -h -k] < data.csv\n
		volby:
		-k kolo prijimacihi rizeni (impl. 1)
		-w mód zápisu do databáze (bez této volby se provádí pouze test)
		-h tento help
   	
	   vstupní soubor (kodovani iso-8895-2):
	   #komentáø
	   \"column\",\"column\"\n
	   \"data\",\"data\"\n\n";
		exit;
	}
	if($opt_k eq "2") {
		$tbl = "uchazec1";
	} else {
		$tbl = "uchazec0";
	}
	if($opt_d ne undef) {$delim = $opt_d;}
	$db = DBI->connect("$db_host_port;$mysql_socket",$user_wr,$passw_wr) or die "Nelze otevøít databázi: ".DBI->errstr."\n";
	$rows = 0;
CTI:while($row = <>) {
		chomp($row);
		next CTI if(substr($row,0,1) eq "#");
		if($rows == 0) {
			### prvi radek - definice sloupcu
			@cols = split(/$delim/,$row);
			foreach $colname (@cols) {$colname =~ s/"//g;}
			shift(@cols);
			print "\n";
		} else {
			### bezna veta
			@vals = split(/$delim/,$row);
			foreach $value (@vals) {$value =~ s/"/'/g;}
			foreach $value (@vals){
				print $value.":";
			}
			&updateRecord(\@cols,\@vals);
		}
		$rows++;
	}
	unless ($opt_w) {
		print "\nTest ONLY mode! - use option -w for writting data to db!\n\n";
	}
