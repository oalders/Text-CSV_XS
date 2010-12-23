#!/usr/bin/perl

use strict;
$^W = 1;

use Test::More tests => 27;

BEGIN {
    require_ok "Text::CSV_XS";
    plan skip_all => "Cannot load Text::CSV_XS" if $@;
    require "t/util.pl";
    }

$| = 1;

my @list = (
    [ 1, "a", "\x01", "A" ],
    [ 2, "b", "\x02", "B" ],
    [ 3, "c", "\x03", "C" ],
    [ 4, "d", "\x04", "D" ],
    );

{   ok (my $csv = Text::CSV_XS->new ({ binary => 1, eol => "\n" }), "csv out");
    open  FH, ">_77test.csv" or die "_77test.csv: $!";
    ok ($csv->print (*FH, $_), "write $_->[0]") for @list;
    close FH;
    }

{   ok (my $csv = Text::CSV_XS->new ({ binary => 1 }), "csv in");

    my $try = sub {
	my ($expect, @args) = @_;
	open  FH, "<_77test.csv" or die "_77test.csv: $!";
	my $s_args = join ", " => @args;
	is_deeply ($csv->getline_all (*FH, @args), $expect, "getline_all ($s_args)");
	close FH;
	};

    $try->(\@list);
    $try->(\@list,         0);
    $try->([@list[2,3]],   2);
    $try->([],             0,  0);
    $try->(\@list,         0, 10);
    $try->([@list[0,1]],   0,  2);
    $try->([@list[1,2]],   1,  2);
    $try->([@list[1..3]], -3);
    $try->([@list[1,2]],  -3,  2);
    }

{   ok (my $csv = Text::CSV_XS->new ({ binary => 1 }), "csv in");
    ok ($csv->column_names (my @cn = qw( foo bar bin baz )));
    @list = map { my %h; @h{@cn} = @$_; \%h } @list;

    my $try = sub {
	my ($expect, @args) = @_;
	open  FH, "<_77test.csv" or die "_77test.csv: $!";
	my $s_args = join ", " => @args;
	is_deeply ($csv->getline_hr_all (*FH, @args), $expect, "getline_hr_all ($s_args)");
	close FH;
	};

    $try->(\@list);
    $try->(\@list,         0);
    $try->([@list[2,3]],   2);
    $try->([],             0,  0);
    $try->(\@list,         0, 10);
    $try->([@list[0,1]],   0,  2);
    $try->([@list[1,2]],   1,  2);
    $try->([@list[1..3]], -3);
    $try->([@list[1,2]],  -3,  2);
    }

unlink "_77test.csv";