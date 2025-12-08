#!/usr/bin/perl
use warnings;
use strict;

use List::Util qw(first uniq sum);
use AdventCommon;
use Data::Dumper;

sub find_starting_position {
    my $top = $_[0];
    first { substr($top, $_, 1) eq 'S' } 0..length($top) - 1;
}

sub move_beans {
    my ($grid, $beams, $row_idx) = @_;
    my $next_row = $row_idx + 1;
    my @new_positions = ();
    my $splits = 0;
    for my $beam (@$beams) {
        my $elem = AdventCommon::char_from_grid($grid, $beam, $next_row);
        if ($elem eq '.') {
            push(@new_positions, $beam);
        }
        else {
            push(@new_positions, $beam - 1);
            push(@new_positions, $beam + 1);
            ++$splits;
        }
    }
    my @moved = uniq(@new_positions);
    return (\@moved, $splits);
}

sub count_total_splits {
    my $start = &find_starting_position;
    my $beams = [$start];
    my $count = 0;
    for my $i (0..AdventCommon::grid_height(@_) - 2) {
        my ($new_beams, $splits) = move_beans(\@_, $beams, $i);
        $beams = $new_beams;
        $count += $splits;
    }
    return $count;
}

sub increase_for_key {
    my ($dict, $key, $inc) = @_;
    if (exists($dict->{$key})) {
        $dict->{$key} += $inc;
    }
    else {
        $dict->{$key} = $inc;
    }
}

sub move_timelines {
    my ($grid, $beams, $row_idx) = @_;
    my $next_row = $row_idx + 1;
    my %new_positions = ();
    for my $beam (keys(%$beams)) {
        my $timelines = $beams->{$beam};
        my $elem = AdventCommon::char_from_grid($grid, $beam, $next_row);
        if ($elem eq '.') {
            increase_for_key(\%new_positions, $beam, $timelines);
        }
        else {
            increase_for_key(\%new_positions, $beam - 1, $timelines);
            increase_for_key(\%new_positions, $beam + 1, $timelines);
        }
    }
    return %new_positions;
}

sub count_total_timelines {
    my $start = &find_starting_position;
    my %beams = ( $start => 1 );
    my $count = 0;
    for my $i (0..AdventCommon::grid_height(@_) - 2) {
        %beams = move_timelines(\@_, \%beams, $i);
    }
    sum(map { $beams{$_} } keys(%beams));
}

my @lines = AdventCommon::read_data('day_07.txt');
print(count_total_splits(@lines), "\n");
print(count_total_timelines(@lines), "\n");
