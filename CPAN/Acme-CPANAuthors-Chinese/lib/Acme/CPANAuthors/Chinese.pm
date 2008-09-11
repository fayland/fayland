package Acme::CPANAuthors::Chinese;

use strict;
use warnings;

our $VERSION = '0.01';

use Acme::CPANAuthors::Register (
    AGENT       => 'Agent Zhang (章亦春)',
    CHAOSLAW    => '王晓哲',
    CHENYR      => 'Chen Yirong (春江)',
    CHUNZI      => 'Chunzi',
    CHYLLI      => 'chylli',
    CNHACKTNT   => '王晖',
    DONGXU      => 'Dongxu Ma <马东旭>',
    FAYLAND     => 'Fayland 林',
    FKIORI      => '陈正伟',
    FLW         => '王兴华',
    FOOLFISH    => '錢宇/Qian Yu',
    HGNENG      => '黄冠能',
    HOOWA       => '孙冰',
    ISLUE       => '胡海麟',
    JOEJIANG    => '蒋永清',
    JWU         => '吴健源',
    JZHANG      => '张军',
    KAILI       => '李凯',
    MAIN        => '吴健源',
    PANGJ       => 'Jeff Pang',
    QJZHOU      => 'Qing-Jie Zhou',
    RANN        => '灿烂微笑 / Ran Ningyu',
    SAL         => 'Sal Zhong (仲伟祥)',
    WEIQK       => '万朝伟',
    YEWENBIN    => '叶文彬',
    ZHUZHU      => 'Zhu Zhu',
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
   my @distros  = $authors->distributions('AGENT');
   my $url      = $authors->avatar_url('FAYLAND');
   my $kwalitee = $authors->kwalitee('YEWENBIN');


=head1 DESCRIPTION

This class is used to provide a hash of chinese CPAN author's PAUSE id/name to Acme::CPANAuthors.

=head1 MAINTENANCE

If you are a chinese CPAN author not listed here, please send me your id/name via email or RT so we can always keep this module up to date. If there's a mistake and you're listed here but are not chinese (or just don't want to be listed), sorry for the inconvenience: please contact me and I'll remove the entry right away.

=head1 SEE ALSO

L<Acme::CPANAuthors> - Main class to manipulate this one

L<Acme::CPANAuthors::Japanese> - Code and documentation nearly taken verbatim from it

L<Acme::CPANAuthors::Brazilian> - inspired me directly

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
