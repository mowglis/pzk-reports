#!/usr/bin/perl
# prevod dat z databaze Bakalaru (sekundy) do PZK
#
#	options:
#	-p cesta k souboru dbf (ZACI.DBF, ZACISUM.DBF)

use DBI;
use Cz::Cstocs;
use Getopt::Std;

# -- init values --
$id_zs = 77;		# kod Gybonu v tabulce ZS
$id_studium = 5;	# typ studis (PZK) - vnitrni PZK
$skol_r0 = '2005/06';	# skolni rok pro 1. prumer (2. pol. primy)
$skol_r1 = '2006/07';	# aktualni skolni rok - pro 2. prumer (1. pol. sekundy)
$id_prefix = 1000;
$id = 0;
$cjed_prefix = '146-';	# prefix podle knihy

# --- mysql ---
#$sock_mysql = "/var/run/mysqld/mysqld.sock";
$sock_mysql = "/var/lib/mysql/mysql.sock";
$dbname = "pzk";
$db_user = "insdele";
$db_passw = "_wruser_pzk_123";

getopts("p:w");
$dbffile = 'ZACI';
$dbffile2 = 'ZACISUM';
$path = $opt_p;
$cp = '1250';		# predpokladane vstupni kodovani DBF souboru (cp1250)

my $il2 = new Cz::Cstocs "$cp",'il2';	# konverzni fce pro cestinu
my $db_baka = DBI->connect("DBI:XBase:$path")  or die $DBI::errstr;
my $read_dbf = $db_baka->prepare("SELECT * FROM $dbffile  WHERE (TRIDA='S2.A' OR TRIDA='S2.B')") or die $db_baka->errstr();
my $read_dbf_sum = $db_baka->prepare("select * from $dbffile2 where INTERN_KOD=?");
my $db = DBI->connect("DBI:mysql:$dbname:localhost:3306;mysql_socket=$sock_mysql",$db_user,$db_passw) or die "Nelze otevrit databazi: ".DBI->errstr."\n";
my $wr_db = $db->prepare("INSERT INTO uchazec0 (id,jmeno,prijmeni,pohlavi,datnar,id_zs,ulice,misto,psc,id_studium,p1,p2,prumer,body,vstup,celkem,zast_jmeno,zast_prijmeni,zast_pohlavi,ucast,cj0) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
$read_dbf->execute() or die $read_dbf->errstr();
$id = $id_prefix;

while ($data = $read_dbf->fetchrow_hashref()) {
#		print &$il2($data->{"TRIDA"})." ".&$il2($data->{"PRIJMENI"})." ".&$il2($data->{"JMENO"})." ".$data->{"POHLAVI"}."\n";
#		$id = int(rand(1)*1e8);
		$id++;
		$cj0 = $cjed_prefix.($id-$id_prefix);
		$prijmeni = &$il2($data->{"PRIJMENI"}); 
		$jmeno = &$il2($data->{"JMENO"}); 
		if($data->{"POHLAVI"} eq 'M') {
			$pohl=1;} else {$pohl=2;}
		$i_kod = $data->{"INTERN_KOD"};
		($misto,$ulice) = split(',',&$il2($data->{"BYDLISTE"}));
		$ulice =~ s/^ //g;
		($den,$mes,$rok) = split('\.',$data->{"DATUM_NAR"});
		$den =~ s/^ //g; $mes =~ s/^ //g;
		$datnar = "$rok-$mes-$den";
		$psc = $data->{"PSC"};
		$psc =~ s/ //g;
		if($data->{"ZAKON_ZAST"} eq 'O' ) {
			$z_zastupce = &$il2($data->{"OT_PR_JM"});
			$z_pohl = 1;
		} else {
			$z_zastupce = &$il2($data->{"MA_PR_JM"});
			$z_pohl = 2;
		}
		($z_prijmeni, $z_jmeno) = split(' ',$z_zastupce);
		# --- studijni vysledky --- 
		$read_dbf_sum->execute($i_kod) or die $read_dbf_sum->errstr();
		while ($data_2 = $read_dbf_sum->fetchrow_hashref()) {
#			printf("%s:%s:%s:%s:%s:%s\n",
#			$data_2->{"INTERN_KOD"},$data_2->{"TRIDA"},$data_2->{"SKOLNI_ROK"},$data_2->{"OBDOBI"},$data_2->{"ROCNIK"},$data_2->{"PRUMER"});
			if($data_2->{"SKOLNI_ROK"} eq $skol_r0 && $data_2->{"OBDOBI"} eq '2') { $p1 = $data_2->{"PRUMER"}; }
			if($data_2->{"SKOLNI_ROK"} eq $skol_r1 && $data_2->{"OBDOBI"} eq '1') { $p2 = $data_2->{"PRUMER"}; }
		}
		$prumer = ($p1+$p2)/2;
		$body = 0;
		if($prumer <= 1.5) { $body = 1; }
		$vstup = $body;
		# --- kontolni tisk ---
		print "REC::$id ($i_kod):$jmeno:$prijmeni:$pohl:$datnar:$id_zs:$ulice:$misto:$psc:$id_studium:$p1:$p2:$prumer:$body:$vstup:$z_jmeno:$z_prijmeni:$z_pohl:$cj0";
		if($opt_w) {
			# id jmeno prijmeni pohlavi datnar - id_zs - ulice misto psc id_studium p1 p2 - prumer body vstup - - - - - - - - - - - - zast_jmeno zast_prijmeni zast_pohlavi - - - - - 
			$wr_db->execute($id,$jmeno,$prijmeni,$pohl,$datnar,$id_zs,$ulice,$misto,$psc,$id_studium,$p1,$p2,$prumer,$body,$vstup,$vstup,$z_jmeno,$z_prijmeni,$z_pohl,1,$cj0);
			print "...writed\n";
		} else { print "\n"; }
}
