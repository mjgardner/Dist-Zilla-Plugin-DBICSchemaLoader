package Dist::Zilla::Plugin::DBICSchemaLoader::Types;

# ABSTRACT: Subtypes for Dist::Zilla::Plugin::WSDL

use English '-no_match_vars';
use Regexp::DefaultFlags;
use Moose;
use MooseX::Types::Moose qw(Item Str);
use MooseX::Types -declare => [qw(DSN LoaderOption)];
## no critic (Subroutines::ProhibitCallsToUndeclaredSubs)
## no critic (Tics::ProhibitLongLines)

=head1 TYPES

=cut

subtype DSN, as Str, where {/\Adbi:\w+:/i};

=head2 C<LoaderOption>

An option for L<DBIx::Class::Schema::Loader|DBIx::Class::Schema::Loader>.

=cut

subtype LoaderOption, as Item;

coerce LoaderOption, from Str, via {
    ## no critic (ProhibitStringyEval, RequireCheckingReturnValueOfEval)
    /\A \s* (?:sub \s* [{] | q \w? \s* [^\w\s] | [[{] )/ ? eval $ARG : $ARG;
};

1;

__END__

=head1 DESCRIPTION

This is a L<Moose|Moose> subtype library for
L<Dist::Zilla::Plugin::DBICSchemaLoader|Dist::Zilla::Plugin::DBICSchemaLoader>.
