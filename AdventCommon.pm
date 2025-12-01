package AdventCommon;

use strict;
use warnings;

sub read_data {
    my $filename = shift;
    open(DATA_FILE, '<', $filename);
    my @result = qw//;
    while (<DATA_FILE>) {
        chop($_);
        push(@result, $_);
    }
    close(DATA_FILE);
    return @result;
}

sub grid_width {
    return length($_[0]);
}

sub grid_height {
    return scalar(@_);
}

sub is_in_grid {
    my ($grid, $x, $y) = @_;
    my $width = grid_width @$grid;
    my $height = grid_height @$grid;
    return $x >= 0 && $x < $width && $y >= 0 && $y < $height;
}

sub char_from_grid {
    my ($grid, $x, $y) = @_;
    if ($y < 0 || $y >= scalar(@$grid)) {
        return undef;
    }
    my $row = $grid->[$y];
    if ($x < 0 || $x >= length($row)) {
        return undef;
    }
    return substr($row, $x, 1);
}

1;
