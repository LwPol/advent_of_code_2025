#!/usr/bin/perl
use warnings;
use strict;

use List::Util qw(sum max first);
use AdventCommon;

sub get_max_joltage {
    my $bank = shift;
    my $len = length($bank);
    my $max = -1;
    for my $i (0..$len - 2) {
        my $battery1 = substr($bank, $i, 1);
        for my $j ($i + 1..$len - 1) {
            my $battery2 = substr($bank, $j, 1);
            my $joltage = "$battery1$battery2";
            $max = $joltage if $joltage > $max;
        }
    }
    return $max;
}

sub calculate_total_output_voltage_p1 {
    sum(map { get_max_joltage($_) } @_);
}

sub find_largest_voltage {
    my $bank = shift;
    my $num = '';
    while (length($num) < 12) {
        my $last_idx = length($bank) - (12 - length($num));
        my $max_digit = max(map { substr($bank, $_, 1) } 0..$last_idx);
        my $idx = first { substr($bank, $_, 1) == $max_digit } 0..$last_idx;
        $num .= substr($bank, $idx, 1);
        $bank = substr($bank, $idx + 1);
    }
    return $num;
}

sub calculate_total_output_voltage_p2 {
    sum(map { find_largest_voltage($_) } @_);
}

my @banks = AdventCommon::read_data('day_03.txt');
print(calculate_total_output_voltage_p1(@banks), "\n");
print(calculate_total_output_voltage_p2(@banks), "\n");
