#!/usr/bin/perl
use warnings;
use strict;

use AdventCommon;

sub count_surrounding_rolls {
    my ($grid, $x, $y) = @_;
    my @dirs = (
        [1, 1], [1, 0], [1, -1], [0, -1],
        [-1, -1], [-1, 0], [-1, 1], [0, 1]
    );
    my $result = 0;
    for my $dir (@dirs) {
        my $xx = $x + $dir->[0];
        my $yy = $y + $dir->[1];
        my $val = AdventCommon::char_from_grid($grid, $xx, $yy);
        ++$result if defined($val) && $val eq '@';
    }
    return $result;
}

sub collect_accessible_rolls {
    my $width = &AdventCommon::grid_width;
    my $height = &AdventCommon::grid_height;
    my @result = ();
    for my $x (0..$width - 1) {
        for my $y (0..$height - 1) {
            push(@result, [$x, $y]) if AdventCommon::char_from_grid(\@_, $x, $y) eq '@' &&
                                       count_surrounding_rolls(\@_, $x, $y) < 4;
        }
    }
    return @result;
}

sub count_accessible_rolls {
    return scalar(collect_accessible_rolls(@_));
}

sub count_removable_rolls {
    my $count = 0;
    while (1) {
        my @removable = collect_accessible_rolls(@_);
        return $count if scalar(@removable) == 0;

        $count += scalar(@removable);
        for my $pos (@removable) {
            my ($x, $y) = @$pos;
            substr($_[$y], $x, 1, '.');
        }
    }
}

my @grid = AdventCommon::read_data('day_04.txt');
print(count_accessible_rolls(@grid), "\n");
print(count_removable_rolls(@grid), "\n");
