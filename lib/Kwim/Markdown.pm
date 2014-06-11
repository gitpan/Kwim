use strict;
package Kwim::Markdown;
$Kwim::Markdown::VERSION = '0.0.11';
use base 'Kwim::Markup';

# use XXX -with => 'YAML::XS';

use constant top_block_separator => "\n";

sub render_text {
    my ($self, $text) = @_;
    $text =~ s/\n/ /g;
    return $text;
}

sub render_para {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    return "$out\n";
}

sub render_title {
    my ($self, $node, $number) = @_;
    my ($name, $abstract) = ref $node ? @$node : (undef, $node);
    $name = $self->render($name);
    my $under = '=' x length $name;
    if (defined $abstract) {
        $abstract = $self->render($abstract);
        "$name\n$under\n\n$abstract\n";
    }
    else {
        "$name\n$under\n";
    }
}

sub render_head {
    my ($self, $node, $number) = @_;
    my $out = $self->render($node);
    my $len = length $out;
    ('#' x $number) . " $out\n";
}



sub render_list {
    my ($self, $node) = @_;
    push @{$self->{bullet}}, '*';
    my $out = $self->render($node);
    pop @{$self->{bullet}};
    $out;
}

sub render_item {
    my ($self, $node) = @_;
    my $item = shift @$node;
    my $bullet = $self->{bullet}[-1];
    my $out = "$bullet " . $self->render($item) . "\n";
    $out .= $self->render($node);
    my $indent = '  ' x (@{$self->{bullet}} - 1);
    $out =~ s/^/$indent/gm;
    $out;
}

sub render_pref {
    my ($self, $node) = @_;
    return '' if @{$self->{bullet}};
    my $out = "$node\n";
    $out =~ s/^/    /gm;
    $out;
}

sub render_func {
    my ($self, $node) = @_;
    if ($node =~ /^([\-\w]+)(?:[\ \:]|\z)((?s:.*)?)$/) {
        my ($name, $args) = ($1, $2);
        $name =~ s/-/_/g;
        my $method = "phrase_func_$name";
        if ($self->can($method)) {
            my $out = $self->$method($args);
            return $out if defined $out;
        }
    }
    "<$node>";
}

sub render_blank { '' }

sub render_comment { '' }

sub render_bold {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "**$out**";
}

sub render_emph {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "_$out\_";
}

sub render_code {
    my ($self, $node) = @_;
    my $out = $self->render($node);
    "`$out`";
}

sub render_hyper {
    my ($self, $node) = @_;
    my ($link, $text) = @{$node}{qw(link text)};
    (length $text == 0)
    ? "<$link>"
    : "[$text]($link)";
}

sub render_link {
    my ($self, $node) = @_;
    my ($link, $text) = @{$node}{qw(link text)};
    (length $text == 0)
    ? "[$link]($link)"
    : "[$text]($link)";
}

sub phrase_func_badge_travis {
    my ($self, $args) = @_;
    return unless $args =~ /^(\S+)\/(\S+)$/;
    qq{[![Travis build status](https://travis-ci.org/$args.png?branch=master)](https://travis-ci.org/$args)};
}

sub phrase_func_badge_coveralls {
    my ($self, $args) = @_;
    return unless $args =~ /^(\S+)\/(\S+)$/;
    qq{[![Coverage Status](https://coveralls.io/repos/$args/badge.png?branch=master)](https://coveralls.io/r/$args?branch=master)};
}

1;
