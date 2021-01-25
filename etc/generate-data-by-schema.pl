#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use FindBin '$Bin';

use autodie qw/ open /;

use YAML::PP;
use YAML::PP::Common qw/ YAML_FLOW_MAPPING_STYLE PRESERVE_FLOW_STYLE PRESERVE_SCALAR_STYLE /;
use JSON::PP;

my $dir = "$Bin/../data";

my @schemas = qw(yaml11 failsafe json core);
my ($in) = @ARGV;
die "input file missing" unless $in;

my $coder = JSON::PP->new->canonical;
my $data = YAML::PP->new->load_file($in);
my $yp = YAML::PP->new( preserve => PRESERVE_FLOW_STYLE | PRESERVE_SCALAR_STYLE );
my $data_for_yaml = $yp->load_file($in);

my %schemas;
my %schemas_for_yaml;
for my $input (sort keys %$data) {
    for my $key (keys %{ $data->{ $input } }) {
        my $test = $data->{ $input }->{ $key };
        for my $schema (split m/, ?/, $key) {
            $schemas{ $schema }->{ $input } = $test;
        }
    }
}
for my $input (sort keys %$data_for_yaml) {
    for my $key (keys %{ $data_for_yaml->{ $input } }) {
        my $test_for_yaml = $data_for_yaml->{ $input }->{ $key };
        for my $schema (split m/, ?/, $key) {
            my $hash = $yp->preserved_mapping({});
            $schemas_for_yaml{ $schema } ||= $hash;
            $schemas_for_yaml{ $schema }->{ $input } = $test_for_yaml;
        }
    }
}

for my $schema (@schemas) {
    my $data = $schemas{ $schema };
    my $data_for_yaml = $schemas_for_yaml{ $schema };
    my $json = $coder->encode($data);

    my $file = "schema-$schema.json";
    open my $fh, '>', "$dir/schema-$schema.json";
    print $fh $json;
    close $fh;
    say "Created $file";

    $file = "schema-$schema.yaml";
    my $yaml = $yp->dump_file("$dir/$file", $data_for_yaml);
    say "Created $file";
}
