package Dist::Zilla::Plugin::DBICSchemaLoader;

# ABSTRACT: Database to DBIx::Class::Schema when building your dist

use autodie;
use Class::Inspector;
require DBIx::Class::Schema::Loader::Base;
use English '-no_match_vars';
use File::Copy 'copy';
use LWP::UserAgent;
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef ClassName Maybe Str);
use MooseX::Types::Path::Class 'Dir';
use MooseX::Types::URI 'Uri';
use Path::Class;
use Regexp::DefaultFlags;
use Dist::Zilla::Plugin::DBICSchemaLoader::Types qw(DSN LoaderOption);
with 'Dist::Zilla::Role::Tempdir';
with 'Dist::Zilla::Role::BeforeBuild';

=attr dsn

A Perl L<DBI|DBI> data source name (DSN) that will be dumped into classes.

=cut

has dsn => ( ro, required, isa => DSN );

=attr username

Username used to connect to the data source.

=attr password

Password used to connect to the data source.

=cut

has [qw(username password)] =>
    ( ro, required, isa => Maybe [Str], default => undef );

=attr dump_directory

Directory in which to create the class files.  Defaults to F<lib>.

=cut

has dump_directory =>
    ( ro, required, coerce, isa => Dir, default => sub { dir('lib') } );

has schema_class => ( ro, required, isa => ClassName );

has(Class::Inspector->methods(
        'DBIx::Class::Schema::Loader::Base', 'public'
    )
) => ( ro, coerce, isa => LoaderOption );

=method before_build

Instructs L<SOAP::WSDL|SOAP::WSDL> to generate Perl classes for the provided
WSDL and gathers them into the C<lib> directory of your distribution.

=cut

sub before_build {
    my $self = shift;

    my (@generated_files) = $self->capture_tempdir(
        sub {

        }
    );

    for my $file (
        map  { $ARG->file() }
        grep { $ARG->is_new() } @generated_files
        )
    {
        $file->name(
            $self->dump_directory->file( $file->name() )->stringify() );
        $self->log( 'Saving ' . $file->name() );
        my $file_path = $self->zilla->root->file( $file->name() );
        $file_path->dir->mkpath();
        my $fh = $file_path->openw();
        print {$fh} $file->content();
        close $fh;
    }
    return;
}

1;

__END__

=head1 DESCRIPTION

This L<Dist::Zilla|Dist::Zilla> plugin will create classes in your
distribution for a L<DBI|DBI> data source using L<DBIx::Class::Schema>.
