#!/usr/bin/perl
#--------------------------------------------------
#	
#	Vytvori data z tabulky uchazec pro dalsi 
#	zpracovani LaTeXem
#	
#	options:
#
#	-t	template - nazv pouzite TeX sablony - template.templ.tex
#	-w	WHERE klauzule pro SELECT 
#	-f	output format  - (pdf, ps), impl. pdf	
#	-s	typ studia (P,H,S)
# 	-n	filename vystupniho souboru
#	-k	kolo prijimaciho rizeni (impl. 1)
#	-b	ORDER BY
#	-x	sestava 'secure' - bez jmen
#
#--------------------------------------------------	
use lib "/home/rusek/lib/";
use DBI;
use locale;
use Data::Dumper;
use Getopt::Std;

$basedir = "/home/rusek/pzk/templates/";
$tempdir = "/home/rusek/pzk/temp/";
$pdfdir = "/home/rusek/html/pzk/pdf/";
$gvarfile = "vars_global.tex";
# MySQL
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
	sub specialUcebna{
		my($id_ucebna)=@_;
		if($pred_id_ucebna ne $id_ucebna){
			print DATA "\\z{";
	  		defMacro("id","*");
			if($pred_id_ucebna eq "") {
				defMacro("zps","-");
			} else {
				defMacro("zps","+");
			}			
			$q_ucebna->execute($id_ucebna);
			($id_u,$skupina,$ucebna,$popis,$kapacita,$id_studium_1,$id_studium_2,$vyuziti_1,$vyuziti_2) = $q_ucebna->fetchrow_array;
#			@a = $q_ucebna->fetchrow_array;
			defMacro("iducebna",$skupina);
			defMacro("jmeno",$ucebna);
			defMacro("misto",$popis);
			defMacro("celkem",${vyuziti_."$id_termin"});
			defMacro("idstudium",${id_studium_."$id_termin"});
			print DATA "}\n";
			$pred_id_ucebna = $id_ucebna;
		}
	}
	sub specialZS{
		my($id_zs)=@_;
		if($pred_id_zs ne $id_zs){
			print DATA "\\z{";
	  		defMacro("id","*");
			if($pred_id_zs eq "") {
				defMacro("zps","-");
			} else {
				defMacro("zps","+");
			}			
			$q_zs->execute($id_zs);
			($id_,$nazev,$ulice,$psc,$misto,$email) = $q_zs->fetchrow_array;
			defMacro("zsnazev",$nazev);
			defMacro("ulice",$ulice);
			defMacro("misto",$misto);
			defMacro("psc",psc($psc));
			print DATA "}\n";
			$pred_id_zs = $id_zs;
		}
	}
	sub specialSS{
		my($id_ss)=@_;
		if($pred_id_ss ne $id_ss){
			print DATA "\\z{";
	  		defMacro("id","*");
			if($pred_id_ss eq "") {
				defMacro("zps","-");
			} else {
				defMacro("zps","+");
			}			
			$q_ss->execute($id_ss);
			($id_,$alias,$nazev,$ulice,$psc,$misto) = $q_ss->fetchrow_array;
			defMacro("zsnazev",$nazev);
			defMacro("ulice",$ulice);
			defMacro("misto",$misto);
			defMacro("psc",psc($psc));
			print DATA "}\n";
			$pred_id_ss = $id_ss;
		}
	}
	sub czDate {
		my($datum)=@_;
		($rok,$mesic,$den) = split(/-/,$datum);
	return "$den.$mesic.$rok";
	}	
	sub defMacro {
		my($name,$value)=@_;
#		print "name: $name value: $value\n";
		if($value eq "") {$value = "-";}	

	 	print DATA "\\".$name."{$value}\n";
		return;
	}	
	sub def_var_config {
		my($ident,$name)=@_;
		$value = readConfig($ident);
#		print "ident: $ident name: $name value: $value\n";
	 	print GVAR "\\def\\".$name."{$value}\n";
		return;
	}	
   sub writeRec {
	my (
	$id,$jmeno,$prijmeni,$pohlavi,$datnar,$zps,$id_zs,$id_ss,$ulice,$misto,$psc,	$id_studium,$p1,$p2,$p3,$prumer,$body,$vstup,$cj,$m,$osp,$celkem,$poradi_od,$poradi_do,$prijat,$bonifikace,$ucast,$id_ucebna,$poznamka,$odvolani,$zast_jmeno,$zast_prijmeni,$zast_pohlavi,$prevzal,$cj0,$aj,$pz,$oz,$termin,$aid,$listek,$zs_nazev,$prefix)=@_;
#		print Dumper(@_);
		#*********** speciality pro jednotlive sestavy ***************
		if(substr($template,0,6) eq "ucebna") { specialUcebna($id_ucebna); }
		if($template eq "zs"){ specialZS($id_zs); }
		if($template eq "ss"){ specialSS($id_ss); }
		if($template eq "pozv"){ 
			if($ucast==4) { $template = "oznameni"; }
				else { $template = "pozvanka"; };
		}
		if(substr($template,0,4) eq 'pozv' && $id_studium == 5) { $template = 'pozvankaT'; }
		if(substr($template,0,5) eq 'kosil' && $id_studium == 5) { $template = 'kosilkaT'; }
		if(substr($template,0,6) eq 'rozhod' && $id_studium == 5) { $template = 'rozhodnutiT'; }
		if(substr($template,0,11) eq 'vyhodnoceni' && $id_studium == 5) { $template = 'vyhodnoceniT'; }
		print "$id:$prijmeni:$template\n";
		#*************************************************************
		# veta uchazece
		#*************************************************************
		print DATA "\\z{";
		defMacro("id",$id); 
		defMacro("jmeno",$jmeno);
		defMacro("prijmeni",$prijmeni);
		defMacro("pohlavi",$pohlavi);
		defMacro("datnar",czDate($datnar));
		defMacro("zps",$zps); 
		defMacro("idzs",$id_zs);
		defMacro("idss",$id_ss);
		defMacro("ulice",$ulice);
		defMacro("misto",$misto);
		defMacro("psc",psc($psc));
		defMacro("idstudium",$id_studium);
		defMacro("pr",$p1);
		defMacro("pp",$p2);
		defMacro("ppp",$p3);
		defMacro("prumer",$prumer);
		defMacro("body",$body);
		defMacro("vstup",$vstup );
		defMacro("cj",$cj); 
		defMacro("m",$m);	
		defMacro("osp",$osp);
		defMacro("aj",$aj);
		defMacro("pz",$pz);
		defMacro("oz",$oz);
		defMacro("termindatum",readConfig($termin));
		defMacro("aid",$aid);
		defMacro("listek",$listek);
		defMacro("celkem",$celkem); 
		defMacro("poradiod",$poradi_od); 
		defMacro("poradido",$poradi_do); 
		defMacro("prijat",$prijat); 
		defMacro("prevzal",$prevzal);
		defMacro("bonifikace",$bonifikace); 
		defMacro("ucast",$ucast); 
		defMacro("iducebna",$id_ucebna); 
		defMacro("poznamka",$poznamka);
		defMacro("zastjmeno",$zast_jmeno);
		defMacro("zastprijmeni",$zast_prijmeni);
		defMacro("zastpohlavi",$zast_pohlavi);
		### polozky mimo zakladni vetu db
		if ($id_studium == 5) { 
			$id -= 1000; 
			$start_pozv=readConfig("start_pozv_5");
			$start_rozhod=readConfig("start_rozhod_5");
		} else {
			$start_pozv=readConfig("start_pozv");
			$start_rozhod=readConfig("start_rozhod");
		}
		defMacro("cjednaci","$opt_k/$id");
		defMacro("zsnazev",$zs_nazev);
		if($poradi_od eq $poradi_do){
			defMacro("poradi",$poradi_od);
		} else {
			defMacro("poradi","$poradi_od--$poradi_do");
		}
		defMacro("prefix",$prefix);
		$porcis++;
		defMacro("porcis",$porcis);
		$rok=readConfig("rok");
		$cj_pozv=$start_pozv+$id;
		$cj_rozhod=$start_rozhod+$id;
		defMacro("spiszn","S-$cj0/$rok-PZK");
		defMacro("cjpozv","$cj_pozv/$rok");
		defMacro("cjrozhod","$cj_rozhod/$rok");
		defMacro("cjprihl","$cj0/$rok");
		defMacro("rok","$rok");
		print DATA "}\n";
	}
#--------------------------------------------
# 		hlavni program
#--------------------------------------------
	getopts("xt:w:f:s:n:k:b:z:");
	$template = $opt_t;
	$format = $opt_f;
	$id_termin = 1;
	if ($opt_z ne undef) {$id_termin=$opt_z;}
	print "id_termin:$id_termin";
	$ordby = "";
	$db = DBI->connect("$db_host_port;$mysql_sock",$user,$passw) or die "Nelze otevøít databázi: ".DBI->errstr."\n";
	### sestava 'secure' ? (vynechava jmena uchazecu)
	$secure = "\\def\\secure{$opt_x}";
	### nastaveni kola PZK - cteni config ###
	$opt_k = readConfig("kolo");
#	if($opt_k eq undef) {$opt_k = "1";}
	if($opt_k eq "1"){
		$tbl = "uchazec0";
	} else {
		$tbl = "uchazec1";
	}
	$kolo = "\\def\\kolo{$opt_k}";
	### klauzule WHERE
	$whr1 = "$tbl.id_zs=zs.id_zs AND $tbl.id_studium=studium.id_studium AND ";
	$whr2 = "(ucast=1 OR ucast=3 OR ucast=4) AND ";
	# u sestavy vyhodnoceni nevypisovat bez PZK
	if($template eq "vyhodnoceni"){ 
		$whr2 = "(ucast=1 OR ucast=3) AND ";
	}
	# u sestavy oznameni vypisovat pro 'bez PZK'
	if($template eq "oznameni"){ 
		$whr2 = "ucast=4 AND ";
	}
	# u sestavy pozvanka nevypisovat 'bez PZK'
	if($template eq "pozvanka"){ 
		$whr2 = "(ucast=1 OR ucast=3) AND ";
	}
	# u sestavy posta, vcetne 'bez PZK'
	if($template eq "posta"){ 
		$whr2 = "(ucast=1 OR ucast=3 OR ucast=4) AND ";
	}
	# u sestavy kosilka - 'vsichni uchazeci'
	if($template eq "kosilka"){ 
		$whr2 = "";
	}
	$whr = $whr1.$whr2;
	if($opt_w ne undef) {
		$whr .= $opt_w." AND ";
	} 
	if($opt_s ne undef) {$whr .= "$tbl.id_studium=$opt_s AND ";}
	### identifikace typu studia
	if($opt_s ne undef){
		$std = "\\def\\studium{$opt_s}";
	}
	### klauzule ORDER BY
	if($opt_b eq undef){
		$ordby = "id_studium,prijmeni,jmeno";
	} else {
		$ordby = $opt_b;
	}
	### speciality pro jednotlive sestavy
	if($template eq "postakniha"){ 
		$ordby = "id";
		if($opt_s eq undef) {$whr .= "($tbl.id_studium=1 OR $tbl.id_studium=3) AND ";}
	}
	if($template eq "pozvanka"){ 
		$ordby = "prijmeni,jmeno";
#		$ordby = "zast_prijmeni,zast_jmeno";
	}
	if($template eq "vyhodnoceni"){ 
		$ordby = "poradi_od,zps DESC,m+cj DESC,prijmeni,jmeno";
	}
	if(substr($template,0,6) eq "ucebna"){
		$pred_id_ucebna = "";
		$q_ucebna = $db->prepare("SELECT * FROM ucebna WHERE id_ucebna=? AND id_ucebna>0");
		$ordby = "id_ucebna,prijmeni,jmeno";
		$whr .= "termin='datum_pzk_$id_termin' AND id_ucebna>0 AND ";
	}
	if($template eq "zs"){
		$pred_id_zs = "";
		$q_zs = $db->prepare("SELECT * FROM zs WHERE id_zs=?");
		$ordby = "$tbl.id_zs,prijmeni,jmeno";
	}
	if($template eq "ss"){
		$pred_id_ss = "";
		$q_ss = $db->prepare("SELECT * FROM ss WHERE id_ss=?");
		$ordby = "$tbl.id_ss,prijmeni,jmeno";
		$whr .= "prijat=1 AND id_ss!=0 AND ";
	}
	if($template eq "posta"){
		$ordby = "prijmeni,jmeno";
#		$ordby = "zast_prijmeni,zast_jmeno";
		$whr .= "prevzal=0 AND ";
		$whr_x =  "WHERE ".substr($whr,0,-4);
		$q_rec = $db->prepare("SELECT COUNT(*) as pocetposta FROM $tbl,zs,studium $whr_x ORDER BY $ordby");
		$q_rec->execute();
		($pocetposta) = $q_rec->fetchrow_array;
		$pocetposta = "\\def\\pocetposta{$pocetposta}";
	}
	if($template eq "postane"){
		$ordby = "prijmeni,jmeno";
	}
	if($whr ne undef && $whr ne "") {$whr = "WHERE ".substr($whr,0,-4);}
	#****** main *******************************************************
	print "Hello, I'm generating LaTex source!\n";
	print "whr:$whr\n";
	$q_rec = $db->prepare("SELECT $tbl.*,zs.nazev as zs_nazev,studium.prefix as prefix FROM $tbl,zs,studium $whr ORDER BY $ordby");
	$q_rec->execute();
	print "rows: ".$q_rec->rows."\n";;
	if($q_rec->rows > 0){
		$porcis=0;
		### vytvoreni datoveho souboru
#		$fname = int(rand(1)*1e10);
		$fname = $opt_n;
		$datafile = "data$fname".".tex";
		$texfile  = $fname.".tex";
		$varfile =  "vars$fname".".tex";
		$pdffile  = $fname.".pdf";
		open(DATA,">$tempdir$datafile") or die "Nelze zalo¾it soubor: '$datafile'\n";
		while(@pol = $q_rec->fetchrow_array) {
			writeRec(@pol);
		}
		close DATA;
	############################
	# priprava souboru pro TeX #	
	############################
	system("cp $basedir$gvarfile $tempdir$varfile");
	# pridavky do vars_global
	open(GVAR,">>$tempdir$varfile")  or die "Nelze zalo¾it soubor: '$tempdir$varfile'\n";
	system("echo \"$std\" >> $tempdir$varfile");
  	system("echo \"$kolo\" >> $tempdir$varfile");
  	system("echo \"$secure\" >> $tempdir$varfile");
        def_var_config("rozhodnuti_skola","terminRozhodnutiSkola");
        def_var_config("datum_pozv","terminPozvanka");
        def_var_config("datum_rozhod","terminRozhodnuti");
        def_var_config("rok","aktualniRok");
        def_var_config("rok_pristi","skrokPristi");
        def_var_config("bez_pzk_1","bezpzkPH");
        def_var_config("bez_pzk_3","bezpzkS");
        def_var_config("schuzka_1","schuzkaPH");
        def_var_config("schuzka_3","schuzkaS");
        def_var_config("test_1","testPH");
        def_var_config("test_3","testS");
        def_var_config("datum_pzk_$id_termin","termin");
        def_var_config("termin_doklady_I","terminDoklady");
        def_var_config("termin_nahradni_I","terminNahradni");
        def_var_config("termin_doklady_II","terminDokladyII");
        def_var_config("termin_nahradni_II","terminNahradniII");
        def_var_config("termin_posta","terminPosta");
        def_var_config("cas_pzk","casPZK");
		  def_var_config("termin_vysvedceni","predlozitVysvedceni");
		  # pridano 17.5.2010
		  def_var_config("termin_rozhodnuti_prijati_kosilka","datumRozhodnutiPrijati");
		  def_var_config("termin_rozhodnuti_neprijati_kosilka","datumRozhodnutiNePrijati");
		  # pridano 13.3.2012
		  def_var_config("termin_vyjadreni","terminVyjadreni");

	if($template eq "posta") {
		system("echo \"$pocetposta\" >> $tempdir$varfile");
	}
	### uprava template
	system("sed -e \"s/<<vars>>/$varfile/g;s/<<data>>/$datafile/g\" $basedir$template.templ.tex > $tempdir$texfile");
#	system("vlna -r -s $dataname");
	### vytvoreni PDF a umisteni
	system("cd $tempdir; pdfcslatex $texfile");
	system("cp $tempdir$pdffile $pdfdir");
   }      
