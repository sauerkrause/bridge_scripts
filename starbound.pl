#!/usr/bin/env perl
sub match_connection {
    my ($line) = @_;
    if($line =~ / \'(.*)\'/) {
	my $name = $1;
	if($line =~ /isconnect/) {
	    return "$name disconnected";
	} else {
	    return "$name connected";
	}
    } else {
	return "";
    }
}

while( <STDIN> ) {
    my $line=$_;
    chomp($line);
    $ret="";
    if($line =~ /Info: Client|Info:  </) {
	if($out = match_connection($line)) {
	    $ret=$out;
	} else {
	    $line =~ s/Info:  //;
	    $ret="$line";
	}
    }
    chomp($ret);
    if($ret) {
	system("redis-cli -h sauerkrause.us publish starbound \"$ret\"");
    }
}

