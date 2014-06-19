#!/usr/bin/env perl
use v5.14;
use Redis;

# We should want them to put a pubsub name in $1
my $PUBSUB = $ARGV[1];
my $HOST = $ARGV[0];

sub handle_join {
    my ($line) = @_;
    $line =~ /(\w*) joined the game/;
    return "$1 has joined";
}

sub handle_quit {
    my ($line) = @_;
    $line =~ /(\w*) left the game/;
    return "$1 has quit";
}

sub handle_speech {
    my ($line, $name) = @_;
    return $line;
}

sub is_death_message {
    my ($line) = @_;
    my $ret = "";
    # Do some regex on the line to check if death message or not.
    given ($line) {
	$ret = $line when /^\w* was/;
	$ret = $line when /^\w* got/;
	$ret = $line when /^\w* walked/;
	$ret = $line when /^\w* drowned/;
	$ret = $line when /^\w* hit/;
	$ret = $line when /^\w* fell/;
	$ret = $line when /^\w* went/;
	$ret = $line when /^\w* tried/;
	$ret = $line when /^\w* burned/;
	$ret = $line when /^\w* starved/;
	$ret = $line when /^\w* suffocated/;
	$ret = $line when /^\w* withered/;
	$ret = $line when /^\w* has just earned/;
	default { return 0; }
    }
    return $ret;
}

sub main {
    while( <STDIN> ) {
	my $line=$_;
	chomp($line);
	$line =~ s/^.*\] //;
	$line =~ s/§.//g;
	$line =~ s/Rcon] .*$//;
	my $ret="";
	$_ = $line;
	given ($line) {
	    when (/Rcon\]/) {
		continue;
	    }
	    when (/joined the game/) {
		print "handling join\n";
		$ret = handle_join($line);
	    }
	    when (/(\w*) left the game/) {
		print "handling quit\n";
		$ret = handle_quit($line);
	    }
	    when (/^<([a-zA-Z0-9>].*)>/) {
		print "handling speech\n";
		$ret = handle_speech($line, $1);
	    }
	    when (/[INFO]: /) {
		print "hit info\n";
	    }
	}
	if (is_death_message($line)) {
	    print "APPEARANTLY A DEATH MESSAGE:\n$line\n";
	    $ret = is_death_message($line);
	}

	chomp($ret);

	if($ret) {
	    my $r = Redis->new( server => "$HOST:6379");
	    $r->publish($PUBSUB, $ret);
	    $r->quit;
	}
    }
}

main();
