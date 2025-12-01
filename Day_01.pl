#!/usr/bin/perl
use warnings;
use strict;

use AdventCommon;

sub count_zero_clicks {
    my ($start, $end) = @_;
    return int($end / 100) if $end > 0;

    my $left_rotation_res = int(abs($end - 100) / 100);
    --$left_rotation_res if $start == 0;
    return $left_rotation_res;
}

sub rotate_dial {
    my ($current, $rotation) = @_;
    my $new_value = substr($rotation, 0, 1) eq 'L'
        ? $current - substr($rotation, 1)
        : $current + substr($rotation, 1);
    return ($new_value % 100, count_zero_clicks($current, $new_value));
}

sub get_password_p1 {
    my $dial = 50;
    my $password = 0;
    for my $rotation (@_) {
        my @result = rotate_dial($dial, $rotation);
        $dial = $result[0];
        ++$password if $dial == 0;
    }
    return $password;
}

sub get_password_p2 {
    my $dial = 50;
    my $password = 0;
    for my $rotation (@_) {
        my @result = rotate_dial($dial, $rotation);
        $dial = $result[0];
        $password += $result[1];
    }
    return $password;
}

my @lines = AdventCommon::read_data('day_01.txt');
print(get_password_p1(@lines), "\n");
print(get_password_p2(@lines), "\n");
