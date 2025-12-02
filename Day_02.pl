#!/usr/bin/perl
use warnings;
use strict;

use List::Util qw(sum0 uniq);
use AdventCommon;

sub parse_ranges {
    my $in = join('', @_);
    map {
        /(\d+)-(\d+)/ =~ $_;
        [$1, $2];
    } split(/,/, $in);
}

sub repeat {
    my ($part, $count) = @_;
    return join('', map { $part } (1..$count));
}

sub get_invalid_ids_for_repeat_count {
    my ($range, $count) = @_;
    my ($start, $end) = @$range;
    my $repeated_part = undef;
    if (length($start) % $count == 0) {
        $repeated_part = substr($start, 0, int(length($start) / $count));
    }
    else {
        my $zeros = int(length($start) / $count);
        $repeated_part = 1 . repeat(0, $zeros);
    }
    while (repeat($repeated_part, $count) < $start) {
        ++$repeated_part;
    }
    my @result = ();
    while (repeat($repeated_part, $count) <= $end) {
        push(@result, repeat($repeated_part, $count));
        ++$repeated_part;
    }
    return @result;
}

sub sum_invalid_ids_for_repeat_count {
    my ($range, $repeats) = @_;
    my @invalid_ids = &get_invalid_ids_for_repeat_count;
    return sum0(@invalid_ids);
}

sub get_max_repeat_count {
    my $range = shift;
    my $end = $range->[1];
    return length($end);
}

sub get_invalid_ids {
    my $range = shift;
    my $upper = get_max_repeat_count($range);
    my @invalid = map { get_invalid_ids_for_repeat_count($range, $_) } 2..$upper;
    return uniq @invalid;
}

sub add_all_invalid_ids_p1 {
    my $result = 0;
    for my $range (@_) {
        $result += sum0(get_invalid_ids_for_repeat_count($range, 2));
    }
    return $result;
}

sub add_all_invalid_ids_p2 {
    my $result = 0;
    for my $range (@_) {
        $result += sum0(get_invalid_ids($range));
    }
    return $result;
}

my @ranges = parse_ranges(AdventCommon::read_data('day_02.txt'));
print(add_all_invalid_ids_p1(@ranges), "\n");
print(add_all_invalid_ids_p2(@ranges), "\n");
