#!perl

use Carp;
use Dist::Zilla::Tester 4.101550;
use File::Temp;
use SQL::Translator;
use Test::Database;
use Test::Most;
use Test::Moose;

use Dist::Zilla::Plugin::DBICSchemaLoader;

my $tests      = 0;
my @handles    = Test::Database->handles();
my $translator = SQL::Translator->new();
$translator->parser('YAML');
$translator->data(<<'END_YAML');
---
schema:
  tables:
    TEST_TABLE:
      fields:
        ID:
          data_type: NUMBER
          default_value: ~
          is_nullable: 0
          is_primary_key: 1
          is_unique: 0
          name: ID
          order: 1
          size:
            - 11
        NAME:
          data_type: VARCHAR2
          default_value: ~
          is_nullable: 1
          is_primary_key: 0
          is_unique: 1
          name: NAME
          order: 2
          size:
            - 4000
END_YAML

for my $handle (@handles) {
    eval { $translator->producer( $handle->dbd() ); 1 } or next;
    diag 'Testing with ', $handle->dbd();
    $tests++;

    my $dbh = $handle->dbh();
    my ( $dsn, $username, $password ) = $handle->connection_info();
    my $sql = $translator->translate() or croak $translator->error();
    $handle->dbh->do($sql) or croak $handle->dbh->errstr();

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
done_testing($tests);
