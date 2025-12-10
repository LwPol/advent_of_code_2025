#!/usr/bin/perl
use warnings;
use strict;

use List::Util qw(max min sum any);
use AdventCommon;

sub parse_points {
    map {
        $_ =~ /(\d+),(\d+)/;
        [$1, $2];
    } @_;
}

sub find_largest_area {
    my $result = 0;
    for my $i (0..$#_ - 1) {
        my $p1 = $_[$i];
        for my $j ($i + 1..$#_) {
            my $p2 = $_[$j];
            my $area = (abs($p1->[0] - $p2->[0]) + 1) * (abs($p1->[1] - $p2->[1]) + 1);
            $result = $area if $area > $result;
        }
    }
    return $result;
}

sub edges {
    my @result = ();
    for my $i (0..$#_ - 1) {
        push(@result, [$_[$i], $_[$i + 1]]);
    }
    push(@result, [$_[-1], $_[0]]);
    return @result;
}

sub sort_points_by_x_axis {
    sort { $a->[0] <=> $b->[0] } @_;
}

sub lower_bound {
    my ($points, $x, $start, $end) = @_;
    if ($start == $end) {
        my $ref = $points->[$start];
        return $ref->[0] >= $x ? $start : -1;
    }
    
    my $mid = int(($start + $end) / 2);
    my $mid_val = $points->[$mid];
    if ($mid_val->[0] < $x) {
        return lower_bound($points, $x, $mid + 1, $end);
    }
    return lower_bound($points, $x, $start, $mid);
}

sub upper_bound {
    my ($points, $x, $start, $end) = @_;
    if ($start == $end) {
        my $ref = $points->[$start];
        return $ref->[0] > $x ? $start : -1;
    }
    
    my $mid = int(($start + $end) / 2);
    my $mid_val = $points->[$mid];
    if ($mid_val->[0] <= $x) {
        return upper_bound($points, $x, $mid + 1, $end);
    }
    return upper_bound($points, $x, $start, $mid);
}

sub has_vertex_inside_rectangle {
    my ($points, $x_sorted, $i, $j) = @_;
    my $p1 = $points->[$i];
    my $p2 = $points->[$j];
    my $xmin = min($p1->[0], $p2->[0]);
    my $xmax = max($p1->[0], $p2->[0]);
    my $ymin = min($p1->[1], $p2->[1]);
    my $ymax = max($p1->[1], $p2->[1]);

    my $max_idx = scalar(@$x_sorted) - 1;
    my $lower = lower_bound($x_sorted, $xmin, 0, $max_idx);
    die "Lower should not be -1" if $lower == -1;
    my $upper = upper_bound($x_sorted, $xmax, 0, $max_idx);
    $upper = scalar(@$x_sorted) if $upper == -1;
    return any {
        my $p = $x_sorted->[$_];
        $p->[0] > $xmin && $p->[0] < $xmax && $p->[1] > $ymin && $p->[1] < $ymax;
    } $lower..$upper - 1;
}

sub is_inside_figure {
    my ($edges, $x, $y) = @_;
    my @filtered = grep {
        my $p1 = $_->[0];
        my $p2 = $_->[1];
        ($p1->[1] == $p2->[1] && $p1->[1] == $y) ||
        ($p1->[0] == $p2->[0] && $y >= min($p1->[1], $p2->[1]) && $y <= max($p1->[1], $p2->[1]));
    } @$edges;
    my $intersections = 0;
    for (@filtered) {
        my $p1 = $_->[0];
        my $p2 = $_->[1];
        if ($p1->[1] == $p2->[1]) {
            return 1 if $x >= min($p1->[0], $p2->[0]) && $x <= max($p1->[0], $p2->[0]);
        }
        else {
            return 1 if $p1->[0] == $x;
            ++$intersections if $p1->[0] > $x;
        }
    }
    return $intersections % 2 == 1;
}

sub is_point_on_vertical_segment {
    my ($begin, $end, $p) = @_;
    my $ymax = max($begin->[1], $end->[1]);
    my $ymin = min($begin->[1], $end->[1]);
    return $p->[0] == $begin->[0] && $p->[1] >= $ymin && $p->[1] <= $ymax;
}

sub is_point_on_horizontal_segment {
    my ($begin, $end, $p) = @_;
    my $xmax = max($begin->[0], $end->[0]);
    my $xmin = min($begin->[0], $end->[0]);
    return $p->[1] == $begin->[1] && $p->[0] >= $xmin && $p->[0] <= $xmax;
}

sub is_dissected_by_an_edge {
    my ($edges, $p1, $p2) = @_;
    my $xmin = min($p1->[0], $p2->[0]);
    my $xmax = max($p1->[0], $p2->[0]);
    my $ymin = min($p1->[1], $p2->[1]);
    my $ymax = max($p1->[1], $p2->[1]);
    any {
        my ($pp1, $pp2) = @$_;
        if ($pp1->[0] == $pp2->[0]) {
            my $ppymin = min($pp1->[1], $pp2->[1]);
            my $ppymax = max($pp1->[1], $pp2->[1]);
            $ppymin <= $ymin && $ppymax >= $ymax && $pp1->[0] > $xmin && $pp1->[0] < $xmax;
        }
        else {
            my $ppxmin = min($pp1->[0], $pp2->[0]);
            my $ppxmax = max($pp1->[0], $pp2->[0]);
            $ppxmin <= $xmin && $ppxmax >= $xmax && $pp1->[1] > $ymin && $pp1->[1] < $ymax;
        }
    } @$edges;
}

sub find_largest_inside_area {
    my @x_sorted = &sort_points_by_x_axis;
    my @edges = &edges;
    my $result = 0;
    for my $i (0..$#_ - 1) {
        my $p1 = $_[$i];
        for my $j ($i + 1..$#_) {
            my $p2 = $_[$j];
            my $area = (abs($p1->[0] - $p2->[0]) + 1) * (abs($p1->[1] - $p2->[1]) + 1);
            next if $area <= $result;
            next if has_vertex_inside_rectangle(\@_, \@x_sorted, $i, $j);
            next if !is_inside_figure(\@edges, $p1->[0], $p2->[1]);
            next if !is_inside_figure(\@edges, $p2->[0], $p1->[1]);
            next if is_dissected_by_an_edge(\@edges, $p1, $p2);
            $result = $area;
        }
    }
    return $result;
}

my @points = parse_points(AdventCommon::read_data('day_09.txt'));
print(find_largest_area(@points), "\n");
print(find_largest_inside_area(@points), "\n");
