package FirstGoodURL;

$VERSION = '1.00';

use LWP::UserAgent;
use Carp;
use strict;

my $ctype = "";
my $ua;

sub import { $ua ||= LWP::UserAgent->new }

sub with {
  my $class = shift;
  carp "no content-type given" if not @_;

  if (@_ > 1) { @$ctype{@_} = () }
  else { $ctype = shift }

  return $class;
}


sub in {
  shift;

  for (@_) {
    my $req = $ua->request(HTTP::Request->new(HEAD => $_));
    next if $req->code != 200;
    return $_ if not $ctype;
    my $ct = $req->content_type;
    $ctype = "", return $_ if
      (not(ref $ctype) and $ct eq $ctype) or
      (ref $ctype eq 'Regexp' and $ct =~ $ctype) or
      (ref $ctype eq 'HASH' and exists $ctype->{$ct});
  }
}


1;

__END__

=head1 NAME

FirstGoodURL - determines first successful URL in list

=head1 SYNOPSIS

  use FirstGoodURL;
  use strict;

  my @URLs = (...);
  my $match;

  if ($match = FirstGoodURL->in(@URLs)) {
    print "good URL: $match\n";
  }
  else {
    print "no URL was alive\n";
  }

  if ($match = FirstGoodURL->with('image/png')->in(@URLs)) {
    print "PNG found at $match\n";
  }
  else {
    print "no PNG found\n";
  }

=head1 DESCRIPTION

This module uses the LWP suite to scan through a list of URLs.  It returns
the first URL that returns a C<200 Ok> status.  In addition, you can specify
a Content-type that the URL must return.

=head1 Methods

=over 4

=item * C<FirstGoodURL->in(...)>

Scans a list of URLs for a 200 response code, and possibly a requisite
Content-type (see the C<with> method below)

=item * C<FirstGoodURL->with(...)>

Sets a Content-type for the next (successful) call to C<in>.  You can send a
single string, a list of strings, or a compiled regex (using C<qr//>).  If a
match is returned from the call to C<in>, the Content-type is forgotten; if
there is no match found, the Content-type is remembered.  This method returns
the class name, so that you can daisy-chain calls for readability:

  my $match = FirstGoodURL->with(qr/image/)->in(@URLs);

=back

=head1 AUTHOR

  Jeff "japhy" Pinyan
  CPAN ID: PINYAN
  japhy@pobox.com
  http://www.pobox.com/~japhy/

=cut
