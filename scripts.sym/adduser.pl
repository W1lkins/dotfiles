#!/usr/bin/perl

use warnings;

my $id = `id -u`;
$id == 0 or die("script must be run as root\n");

print "Enter username: ";
my $name = <STDIN>;
chomp $name;

print "Enter password: ";
my $pass = <STDIN>;
chomp $pass;

open(FILE, "/etc/passwd") || die("can't open /etc/passwd\n");
while(<FILE>) {
  $_ =~ /$name/ and die("user already exists\n");
}
close(FILE);

my $crypt = crypt($pass, "password");
system("useradd -m -p $crypt $name") == 0 or die("failed to add user\n");
