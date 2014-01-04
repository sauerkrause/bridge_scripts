#!/usr/bin/env perl

use Redis;

sub main {
    my ($redis_host, $host, $port, $passwd) = @_;
    sub redis_sub_cb {
	my $message = shift;
	my $topic = shift; 
	my $subscribed_topic = shift;
	my $line = $message;
	chomp($line);
	$line =~ s/"$//;
	$line =~ s/"/\"/g;
	my $cmd = "mcrcon -c -H $host -P $port -p $passwd \"say $line\"";
	print "$cmd\n";
	system($cmd);
    }
    my $keep_waiting = 1;
    $r = Redis->new( server => $redis_host );
    $r->subscribe( ("irc"),
		   \&redis_sub_cb);
    $r->wait_for_messages(5) while $keep_waiting;
    # while( <STDIN> ) {
    # 	my $line = $_;
    # 	chomp($line);
    # 	if ($line =~ /^3\) /) {
    # 	    $line =~ s/^3\) "//;
    # 	    $line =~ s/"$//;
    # 	    $line =~ s/"/\"/g;
    # 	    my $cmd = "mcrcon -c -H $host -P $port -p $passwd \"say $line\"";
    # 	    print "$cmd\n";
    # 	    system($cmd);
    # 	}
    # }
}

main @ARGV;
