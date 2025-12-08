#!/usr/bin/perl
use warnings;
use strict;

use List::Util qw(uniq);
use AdventCommon;

sub parse_points {
    map {
        $_ =~ /(\d+),(\d+),(\d+)/;
        [$1, $2, $3];
    } @_;
}

sub measure_distances_squared {
    my @result = ();
    for my $i (0..$#_ - 1) {
        my $p1 = $_[$i];
        my ($x1, $y1, $z1) = @$p1;
        for my $j ($i + 1..$#_) {
            my $p2 = $_[$j];
            my ($x2, $y2, $z2) = @$p2;
            push(@result, {
                p1 => $p1,
                p2 => $p2,
                measure => ($x2 - $x1) ** 2 + ($y2 - $y1) ** 2 + ($z2 - $z1) ** 2
            });
        }
    }
    sort { $a->{measure} <=> $b->{measure} } @result;
}

sub pos_to_str {
    my $pos_ref = shift;
    my ($x, $y, $z) = @$pos_ref;
    return "$x,$y,$z";
}

sub connect_pair_of_junctions {
    my ($circuits, $junctions) = @_;
    my $p1 = pos_to_str($junctions->{p1});
    my $p2 = pos_to_str($junctions->{p2});
    my $circuit_ref = $circuits->{$p1};
    for (keys(%{$circuits->{$p2}})) {
        $circuit_ref->{$_} = undef;
        $circuits->{$_} = $circuit_ref;
    }
    return scalar(keys(%$circuit_ref));
}

sub connect_junctions {
    my ($points, $count) = @_;
    my @measured = measure_distances_squared(@$points);
    my %circuits = map {
        my $pos_str = pos_to_str($_);
        $pos_str => { $pos_str => undef };
    } @$points;
    for my $i (0..$count - 1) {
        connect_pair_of_junctions(\%circuits, $measured[$i]);
    }
    return %circuits;
}

sub get_three_largest_circuits {
    my $hash_ref = shift;
    my @circuits = uniq (map { $hash_ref->{$_} } keys(%$hash_ref));
    my @sorted = sort { -(scalar(keys(%$a)) <=> scalar(keys(%$b))) } @circuits;
    return @sorted[0..2];
}

sub find_product_of_3_largest_circuits {
    my %circuits = &connect_junctions;
    my ($x, $y, $z) = get_three_largest_circuits(\%circuits);
    return scalar(keys(%$x)) * scalar(keys(%$y)) * scalar(keys(%$z));
}

sub connect_all_junctions {
    my @measured = &measure_distances_squared;
    my $points_count = @_;
    my %circuits = map {
        my $pos_str = pos_to_str($_);
        $pos_str => { $pos_str => undef };
    } @_;
    for my $i (0..$#measured) {
        my $pair = $measured[$i];
        my $new_size = connect_pair_of_junctions(\%circuits, $pair);
        return $pair if $new_size == $points_count;
    }
}

sub find_last_connection_coords_product {
    my $last_pair = &connect_all_junctions;
    my $p1 = $last_pair->{p1};
    my $p2 = $last_pair->{p2};
    return $p1->[0] * $p2->[0];
}

my @points = parse_points(AdventCommon::read_data('day_08.txt'));
print(find_product_of_3_largest_circuits(\@points, 1000), "\n");
print(find_last_connection_coords_product(@points), "\n");
