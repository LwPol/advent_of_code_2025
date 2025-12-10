#!/usr/bin/perl
use warnings;
use strict;

use List::Util qw(any sum max);
use IPC::Run qw(run); # uses python pulp script to solve part 2
use AdventCommon;

sub parse_input {
    map {
        $_ =~ /\[([.#]+)\]\s+((?:\([0-9,]+\)\s+)+)\{([0-9,]+)\}/;
        my $lights = $1;
        my $buttons_str = $2;
        my @joltages = split(/,/, $3);
        my @extracted = $buttons_str =~ /\(([0-9,]+)\)/g;
        my @buttons = map {
            my @ret = split(/,/, $_);
            \@ret;
        } @extracted;
        {
            lights => $lights,
            buttons => \@buttons,
            joltages => \@joltages
        }
    } @_;
}

sub click_button {
    my ($lights, $button) = @_;
    for my $light (@$button) {
        my $c = substr($lights, $light, 1);
        substr($lights, $light, 1, $c eq '#' ? '.' : '#');
    }
    return $lights;
}

sub find_fewest_button_clicks {
    my $entry = shift;
    my $lights = join('', map { '.' } 1..length($entry->{lights}));
    my @queue = map { [$lights, $_, 1] } @{$entry->{buttons}};
    my %visited = ($lights => undef);
    while (scalar(@queue) > 0) {
        my $next = shift @queue;
        my ($current, $button, $clicks) = @$next;
        my $new_lights = click_button($current, $button);
        return $clicks if $new_lights eq $entry->{lights};
        next if exists($visited{$new_lights});

        $visited{$new_lights} = undef;
        for my $button (@{$entry->{buttons}}) {
            push(@queue, [$new_lights, $button, $clicks + 1]);
        }
    }
}

sub sum_fewest_button_presses {
    sum(map { &find_fewest_button_clicks } @_);
}

sub get_upper_bound_for_button {
    my ($button, $joltages) = @_;
    max(map { $joltages->[$_] } @$button);
}

sub run_ilp_script {
    my ($bounds, $equations) = @_;
    my @cmd = ('python3', 'day_10_pulp.py', @$bounds);
    my $in = join("\n", @$equations);
    my $out = '';
    my $err = '';
    run(\@cmd, \$in, \$out, \$err) or die $?;
    
    my @lines = split(/\n/, $out);
    $lines[-1] =~ /Solution: (\d+)/;
    return $1;
}

sub prepare_buttons_matrix {
    my ($buttons, $rows_count) = @_;
    my @matrix = map {
        my @zeros = map { 0 } 1..scalar(@$buttons);
        \@zeros
    } 1..$rows_count;
    for my $i (0..scalar(@$buttons) - 1) {
        my $button = $buttons->[$i];
        for my $j (@$button) {
            my $row = $matrix[$j];
            $row->[$i] = 1;
        }
    }
    return @matrix;
}

sub find_fewest_joltage_clicks {
    my $entry = shift;
    my $joltages = @{$entry->{joltages}};
    my @upper_bounds = map { get_upper_bound_for_button($_, $entry->{joltages}) } @{$entry->{buttons}};
    my @matrix = prepare_buttons_matrix($entry->{buttons}, $joltages);
    my $joltages_ref = $entry->{joltages};
    my @equations = map {
        my $row = $matrix[$_];
        my $vars = join('+', grep { $row->[$_] > 0 } 0..scalar(@$row) - 1);
        $vars . '==' . $joltages_ref->[$_];
    } 0..$#matrix;
    return run_ilp_script(\@upper_bounds, \@equations);
}

sub sum_fewest_joltage_clicks {
    sum(map { &find_fewest_joltage_clicks } @_);
}

my @input = parse_input(AdventCommon::read_data('day_10.txt'));
print(sum_fewest_button_presses(@input), "\n");
print(sum_fewest_joltage_clicks(@input), "\n");
