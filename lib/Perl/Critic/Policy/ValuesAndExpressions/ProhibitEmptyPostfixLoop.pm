package Perl::Critic::Policy::ValuesAndExpressions::ProhibitEmptyPostfixLoop;
# ABSTRACT: Prohibit writing an postfix loop with no statement

use strict;
use warnings;

use parent 'Perl::Critic::Policy';
use Perl::Critic::Utils qw(:severities :classification :ppi);
use List::Util qw< first >;

use constant 'DESC' => 'Loop with no statement body';
use constant 'EXPL' => 'You wrote a postix loop but did not '
                     . 'write a body for it. Maybe you accidentally '
                     . 'terminated the previous line?';

sub supported_parameters { () }
sub default_severity     {$SEVERITY_HIGH}
sub default_themes       {'bugs'}
sub applies_to           {'PPI::Token::Word'}

sub violates {
    my ( $self, $elem ) = @_;

    first { $elem eq $_ } qw< for foreach >
        or return ();

    # Don't be fooled by 'for' being used in a hash or somesuch
    $elem->parent && $elem->parent->isa('PPI::Statement::Expression')
        and return ();

    # Detect if this is postfix or not by looking for a block
    my $next = $elem;
    while ( $next = $next->snext_sibling ) {
        $next->isa('PPI::Structure::Block')
            and return ();
    }

    # Make sure this isn't a correct postfix loop
    $elem->sprevious_sibling
        and return ();

    return $self->violation( DESC(), EXPL(), $elem );
}

1;

__END__

=head1 DESCRIPTION

The postfix loop is a common pattern, but you can accidentally add a
semicolon and make it into a meaningless statement.

    do_something($_)
        for @items;     # ok

    do_something($_);
        for @items;     # not ok

    $_++ for @items;    # ok
    $_++; for @items;   # not ok

=head1 CONFIGURATION

This policy is not configurable except for the standard options.

=head1 SEE ALSO

L<Perl::Critic>
