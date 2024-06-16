#!/usr/bin/perl
# Enumereitor v 0.1 --> Enumera hosts validos, atraves de brute force, em dominios que 
#                       bloqueiam a trasferencia de zona no servidor de DNS               
# MOTD Labs ----------> http://www.motdlabs.org
# coded by inferninh0 (inferninho@motdlabs.org)
####

use Socket;
use strict;
use Getopt::Std;
&banner;
getopt ("d: w: r:");
use vars qw( $opt_d $opt_r $opt_w);
if ((! $opt_d ) || (! $opt_r) || (! $opt_w))  {
print "USO : $0 -d dominio -w wordlist -r resultado\n\n ";
exit 1; 
};
my $dominio = $opt_d;
my $wordlist = $opt_w;
my $resultado = $opt_r;
my $pergunta;
my $resposta;
open (FILE, "$wordlist") or die "\nO arquivo $wordlist nao existe\n $!";
open (RESULTADO,">$resultado") or die "\nO arquivo $resultado nao pode ser aberto\n $!";
print RESULTADO "Lista gerada por Enumereitor v0.1";
print RESULTADO "\nHosts resolvidos em $dominio :\n";
foreach $pergunta (<FILE>) {
chomp $pergunta;
undef($resposta);
$resposta = inet_aton("$pergunta.$dominio");
if( $resposta ) {
$resposta= inet_ntoa ("$resposta");
}else{ $resposta = "NDA"} ;
if ($resposta !~/NDA/) { print RESULTADO "\n$pergunta.$dominio  ->  $resposta";};
print "\n$pergunta.$dominio  ->  $resposta";
};
close FILE;
close RESULTADO;
sub banner {
system("clear");
	print "\t\t\tEnumereitor v0.1\n";
	print "\t\t\t~~~~~~~~~~~~~~~~\n\n";
} print;
print "\n\ndns- es un protocolo maricone?...:P\n\n";
exit;

