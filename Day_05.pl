#!/usr/bin/perl
use warnings;
use strict;

use List::Util qw(any max sum);
use AdventCommon;

sub parse_input {
    my @ranges = ();
    my $line_idx = 0;
    while ($line_idx < scalar(@_) && length($_[$line_idx]) > 0) {
        $_[$line_idx] =~ /(\d+)-(\d+)/;
        push(@ranges, [$1, $2]);
        ++$line_idx;
    }
    my @ids = @_[$line_idx + 1..$#_];
    return (\@ranges, \@ids);
}

sub is_fresh {
    my ($ranges, $value) = @_;
    any {
        my ($min, $max) = @$_;
        $value >= $min && $value <= $max;
    } @$ranges;
}

sub count_fresh_ids {
    my ($ranges, $ids) = @_;
    my $count = 0;
    for my $value (@$ids) {
        ++$count if is_fresh($ranges, $value);
    }
    return $count;
}

sub merge_overlapping_ranges {
    my @sorted = sort { $a->[0] <=> $b->[0] } @_;
    my @merged = ($sorted[0]);
    for my $i (1..$#sorted) {
        my $range = $sorted[$i];
        my $last = $merged[-1];
        if ($range->[0] <= $last->[1]) {
            $last->[1] = max $range->[1], $last->[1];
        }
        else {
            push(@merged, $range);
        }
    }
    return @merged;
}

sub count_all_fresh_ids {
    my @merged = &merge_overlapping_ranges;
    sum(map { $_->[1] - $_->[0] + 1 } @merged);
}

my @input = parse_input(AdventCommon::read_data('day_05.txt'));
print(count_fresh_ids(@input), "\n");
print(count_all_fresh_ids(@{$input[0]}), "\n");
