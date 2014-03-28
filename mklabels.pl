#!/usr/bin/perl
#--------------------------------------------------
#	Vytvori data z tabulky uchazec pro dalsi 
#	zpracovani LaTeXem
#	
#	options:
#	-w	WHERE klauzule pro SELECT 
#	-s	typ studia (P,H,S)
#	-k	kolo prijimaciho rizeni (impl. 1)
#	-b	ORDER BY
#--------------------------------------------------	
use lib "/home/rusek/lib/";
use DBI;
use locale;
use Data::Dumper;
use Getopt::Std;

$basedir = "/home/rusek/pzk/templates/";
$tempdir = "/home/rusek/pzk/temp/";
$pdfdir = "/home/rusek/html/pzk/pdf/";
$fname = 'labels';
#$fname = 'lab';
#--- MySQL ---
$user = "sele";
$passw = "_seleuser_pzk_123";
$mysql_socket = "mysql_socket=/var/lib/mysql/mysql.sock";
$db_host_port = "DBI:mysql:pzk:localhost:3306";
$tbl = "uchazec0";
	
	sub readConfig {
		my($ident) = @_;
		$config = $db->prepare("SELECT value from config where ident=?");
		$config->execute($ident);
		if($config->rows > 0) {
			($value) = $config->fetchrow_array;
			return $value;
		} else {
			return 0;
		}
	}
	
	sub psc{
		my($psc) = @_;
		return substr($psc,0,3)."\\,".substr($psc,3,2);
	}

   sub writeRec {
		my ($zast_prijmeni,$zast_jmeno,$ulice,$misto,$psc)=@_;
#		print Dumper(@_);
		printf DATA "\\\mlabel{}{%s %s\\\\%s\\\\%s\\\\%s}\n", $zast_prijmeni,$zast_jmeno,$ulice,$misto,psc($psc);
	}

	sub writeHead {
		print DATA 
"\\documentclass[12pt]{letter}
\\usepackage[noprintbarcodes,nocapaddress]{envlab}
\\usepackage{czech}
\\makelabels
\\pdfoutput=1
\\begin{document}
%\\SetLabel{70mm}{30.7mm}{2mm}{0mm}{0mm}{3}{9}
%\\SetLabel{68mm}{30mm}{5mm}{3mm}{0mm}{3}{9} % 70x30
%\\SetLabel{48mm}{25.4mm}{19mm}{7mm}{0mm}{4}{10} % 48x25
\\SetLabel{48mm}{25.4mm}{10mm}{7mm}{0mm}{4}{10} % 48x25
%\\SetLabel{68mm}{36mm}{0mm}{3mm}{0mm}{3}{8} % 70x36
\\startlabels\n";
	}

	sub writeFoot {
		print DATA "\\end{document}\n";
	}
#--------------------------------------------
# 		hlavni program
#--------------------------------------------
	getopts("w:s:k:b:");
	$db = DBI->connect("$db_host_port;$mysql_sock",$user,$passw) or die "Nelze otevøít databázi: ".DBI->errstr."\n";
	#  nastaveni kola PZK
	$opt_k = readConfig("kolo");
	if($opt_k eq "1"){
		$tbl = "uchazec0";
	} else {
		$tbl = "uchazec1";
	}
	$kolo = "\\def\\kolo{$opt_k}";
	# klauzule WHERE
	$whr = "(ucast=1 OR ucast=3 OR ucast=4) AND prevzal=0 AND "; # co rozhodnuti neprevzali
#	$whr = "(ucast=1 OR ucast=3 OR ucast=4) AND listek=1 AND "; # ti co podali zapisovy listek
	if($opt_w ne undef) {
		$whr .= $opt_w." AND ";
	} 
	if($opt_s ne undef) {$whr .= "id_studium=$opt_s AND ";}

	# identifikace typu studia
	if($opt_s ne undef){
		$std = "\\def\\studium{$opt_s}";
	}
	# klauzule ORDER BY
	if($opt_b eq undef){
		$ordby = "prijmeni,jmeno";
	} else {
		$ordby = $opt_b;
	}
	if($whr ne undef && $whr ne "") {$whr = "WHERE ".substr($whr,0,-4);}
	#---- main ---
	print "Hello, I'm generating LaTex source!\n";
	$q_rec = $db->prepare("SELECT zast_prijmeni, zast_jmeno, ulice, misto, psc FROM $tbl $whr ORDER BY $ordby");
	$q_rec->execute();
	if($q_rec->rows>0){
		$porcis=0;
		$texfile  = $fname.".tex";
		$pdffile  = $fname.".pdf";
		open(DATA,">$tempdir$texfile") or die "Nelze zalo¾it soubor: '$texfile'\n";
		writeHead();
		while(@pol = $q_rec->fetchrow_array) {writeRec(@pol);}
		writeFoot();
		close DATA;
		# priprava souboru pro TeX #	
		system("cd $tempdir; pdfcslatex $texfile");
		system("cp $tempdir$pdffile $pdfdir");
   	}      
	print "whr:$whr\n";
	print "rows: ".$q_rec->rows."\n";
