#!/usr/bin/perl
use lib "/home/rusek/lib/";
use DBI;
use locale;
use Data::Dumper;
use Getopt::Std;
use POSIX;

# MySQL
$user = "sele";
$passw = "_seleuser_pzk_123";
$mysql_socket = "mysql_socket=/var/lib/mysql/mysql.sock";
$db_host_port = "DBI:mysql:pzk:localhost:3306";
$tbl = "uchazec0";

   sub prum {
      my ($p1,$p2,$presnost) = @_;
      $precis = 100;
      $pr = ($p1*1+$p2*1)/2.;
      print $pr;
      $prf = $pr;
      $rozdil = int($pr*1000)-int($pr*100)*10;
      print "<<$rozdil>>";
      if(int($pr*1000)-int($pr*100)*10 > 4) {
         $pr = (int($pr*100)+1)/100;
      } else {
         $pr = int($pr*100)/100;
      }
      return $prf,$pr;
   }
#--------------------------------------------
# 			hlavni program
#--------------------------------------------
	getopt("w");
	$db = DBI->connect("$db_host_port;$mysql_sock",$user,$passw) or die "Nelze otevøít databázi: ".DBI->errstr."\n";
	
	$q_rec = $db->prepare("SELECT * FROM $tbl ORDER BY prijmeni,jmeno");
	$q_rec->execute();
	print "rows: ".$q_rec->rows."\n";;
	if($q_rec->rows>0){
		while(@pol = $q_rec->fetchrow_array) {
         ($prf,$newpr) = prum($pol[12],$pol[13],2);
         if($newpr != $pol[15]) {
            $inf = "*** ERROR";
         } else {
            $inf = "";
         }
		   printf ("%s %s %s %s %s %s -> %s (%s) %s\n",
         $pol[0],$pol[2],$pol[1],$pol[12],$pol[13],$pol[15],$newpr,$prf,$inf);
      }
   }
