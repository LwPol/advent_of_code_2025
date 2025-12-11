#!/usr/bin/perl
use warnings;
use strict;

use AdventCommon;

sub parse_connections {
    my %result = ();
    for my $line (@_) {
        $line =~ /(\w+): (.+)/;
        my @outbounds = split(/\s+/, $2);
        $result{$1} = \@outbounds;
    }
    return %result;
}

sub count_out_paths_p1_impl {
    my ($connections, $current) = @_;
    return 1 if $current eq 'out';
    my $outconns = $connections->{$current};
    my $result = 0;
    for my $out (@$outconns) {
        $result += count_out_paths_p1_impl($connections, $out);
    }
    return $result;
}

sub count_paths_for_p2_cached {
    my ($connections, $cache, $current) = @_;
    if ($current eq 'out') {
        return {
            both => 0,
            dac => 0,
            fft => 0,
            out => 1
        };
    }
    return $cache->{$current} if exists($cache->{$current});
    my $outconns = $connections->{$current};
    my %result = (
        both => 0,
        dac => 0,
        fft => 0,
        out => 0
    );
    for my $out (@$outconns) {
        my $paths_info = count_paths_for_p2_cached($connections, $cache, $out);
        $result{out} += $paths_info->{out};
        if ($current eq 'dac') {
            $result{dac} += $paths_info->{out};
            $result{both} += $paths_info->{fft};
        }
        elsif ($current eq 'fft') {
            $result{fft} += $paths_info->{out};
            $result{both} += $paths_info->{dac};
        }
        else {
            $result{dac} += $paths_info->{dac};
            $result{fft} += $paths_info->{fft};
            $result{both} += $paths_info->{both};
        }
    }
    $cache->{$current} = \%result;
    return \%result;
}

sub count_p1 {
    my $connections = shift;
    count_out_paths_p1_impl($connections, 'you');
}

sub count_p2 {
    my $connections = shift;
    my $result = count_paths_for_p2_cached($connections, {}, 'svr');
    return $result->{both};
}

my %conns = parse_connections(AdventCommon::read_data('day_11.txt'));
print(count_p1(\%conns), "\n");
print(count_p2(\%conns), "\n");
