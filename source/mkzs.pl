#!/usr/bin/perl
$i=0;
CTI:while($r = <>) {
	chomp($r);
	next CTI if(substr($r,0,1) eq "#");
	($nazev,$ulice,$psc,$misto,$email) = split(/,/,$r);
	print "insert into zs values($i,'$nazev','$ulice','$psc','$misto','$email');\n";
	$i++;
}

