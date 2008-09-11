package Acme::CPANAuthors::Chinese;

use strict;
use warnings;

our $VERSION = '0.01';

use Acme::CPANAuthors::Register (
    AGENT       => 'Agent Zhang (章亦春)',
    CHUNZI      => 'Chunzi',
    CHYLLI      => 'chylli',
    FAYLAND     => 'Fayland 林',
    FKIORI      => '陈正伟',
    FLW         => '王兴华',
    YEWENBIN    => '叶文彬',
);

1;

__END__

=head1 NAME

Acme::CPANAuthors::Chinese - We are chinese CPAN authors

Acme::CPANAuthors::Chinese - CPAN 中国作者

=head1 SYNOPSIS

   use Acme::CPANAuthors;
   use Acme::CPANAuthors::Chinese;

   my $authors = Acme::CPANAuthors->new('Chinese');

   my $number   = $authors->count;
   my @ids      = $authors->id;
   my @distros  = $authors->distributions('FGLOCK');
   my $url      = $authors->avatar_url('GARU');
   my $kwalitee = $authors->kwalitee('FCO');


=head1 DESCRIPTION

This class is used to provide a hash of chinese CPAN author's PAUSE id/name to Acme::CPANAuthors.

Essa classe é usada para fornecer um hash de id/nome PAUSE de autores brasileiros no CPAN para o Acme::CPANAuthors.

=head1 MAINTENANCE

If you are a chinese CPAN author not listed here, please send me your id/name via email, IRC, or RT so we can always keep this module up to date. If there's amistake and you're listed here but are not chinese (or just don't want to be listed), sorry for the inconvenience: please contact me and I'll remove the entry right away.

Se você é um autor brasileiro no CPAN e n?o está listado aqui, por favor me envie seu id/nome via email, IRC, ou RT para que possamos manter esse módulo sempre atualizado. Se houve um erro e você está listado aqui mas n?o é brasileiro (ou simplesmente n?o quer ser listado), desculpe a inconveniencia: por favor entre em contato que removerei a entrada imediatamente.

=head1 SEE ALSO

L<Acme::CPANAuthors> - Main class to manipulate this one (Classe principal para manipular esta)

L<Acme::CPANAuthors::Japanese> - Code and documentation nearly taken verbatim from it (Código e documenta??o copiadas daqui quase verbatim)

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
