#!perl

use Cwd;
use Dist::Zilla::Tester 4.101550;
use File::Temp;
use Test::Database;
use Test::Most;
use Test::Moose;

use Dist::Zilla::Plugin::DBICSchemaLoader;

my @handles = Test::Database->handles();
plan tests => scalar @handles;

for my $handle (@handles) {
    diag 'Testing with ', $handle->dbd();

    my $dbh = $handle->dbh();
    my ( $dsn, $username, $password ) = $handle->connection_info();

    my $dist_dir = File::Temp->newdir();
    my $zilla    = Dist::Zilla::Tester->from_config(
        { dist_root => "$dist_dir" },
        { add_files => { 'source/dist.ini' => <<"END_INI"} },
name     = test
author   = test user
abstract = test release
license  = Perl_5
version  = 1.0
copyright_holder = test holder

[DBICSchemaLoader]
schema_class = My::Schema
dsn = $dsn
username = $username
password = $password
END_INI
    );
    lives_ok( sub { $zilla->build() } );
}

