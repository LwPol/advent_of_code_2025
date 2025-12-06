#!/usr/bin/perl
use warnings;
use strict;

use List::Util qw(reduce sum all);
use AdventCommon;

sub parse_homework_p1 {
    map {
        my @values = grep { length($_) > 0 } split(/\s+/, $_);
        \@values;
    } @_;
}

sub find_blank_columns {
    my $lines = shift;
    my $row_len = length($lines->[0]);
    my @blank_cols = grep {
        my $col_idx = $_;
        all { substr($lines->[$_], $col_idx, 1) eq ' ' } 0..scalar(@$lines) - 1;
    } 0..$row_len - 1;
    return (-1, @blank_cols, $row_len);
}

sub add {
    my ($a, $b) = @_;
    return $a + $b;
}

sub multiply {
    my ($a, $b) = @_;
    return $a * $b;
}

sub solve_problem_p1 {
    my ($homework, $idx) = @_;
    my $op_row = $homework->[-1];
    my $op = ($op_row->[$idx] eq '+') ? \&add : \&multiply;
    my @column = map {
        my $row = $homework->[$_];
        $row->[$idx]
    } 0..scalar(@$homework) - 2;
    reduce { &$op($a, $b) } @column;
}

sub solve_homework_p1 {
    my @homework = &parse_homework_p1;
    my $first_row = $homework[0];
    my @problems = map { solve_problem_p1(\@homework, $_) } 0..scalar(@$first_row) - 1;
    return sum @problems;
}

sub read_numbers {
    my ($homework, $start_col, $end_col) = @_;
    my @result = ();
    for my $i ($start_col..$end_col - 1) {
        my @nums = map { substr($_, $i, 1) } @$homework;
        my $value = join('', grep { $_  =~ /\d/ } @nums);
        push(@result, $value);
    }
    return @result;
}

sub solve_problem_p2 {
    my ($homework, $start_col, $end_col) = @_;
    my @numbers = read_numbers @_;
    my $op = substr($homework->[-1], $start_col, $end_col - $start_col) =~ /\+/
        ? \&add : \&multiply;
    reduce { &$op($a, $b) } @numbers;
}

sub solve_homework_p2 {
    my $args_ref = \@_;
    my @blanks = find_blank_columns($args_ref);
    sum(map {
        my $start = $blanks[$_] + 1;
        my $end = $blanks[$_ + 1];
        solve_problem_p2($args_ref, $start, $end);
    } 0..$#blanks - 1);
}

my @lines = AdventCommon::read_data('day_06.txt');
print(solve_homework_p1(@lines), "\n");
print(solve_homework_p2(@lines), "\n");
