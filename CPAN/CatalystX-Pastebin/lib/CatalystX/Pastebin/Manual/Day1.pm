package CatalystX::Pastebin::Manual::Day1;

use vars qw/$VERSION/;
$VERSION = '0.01';

1;
__END__

=pod

=head1 NAME

CatalystX::Pastebin::Manual::Day1 - Setup and Database Schema

=head1 STEPS

=over 4

=item 1, catalyst CatalystX::Pastebin

    E:\Fayland\googlesvn\trunk\CPAN>catalyst CatalystX::Pastebin
    created "CatalystX-Pastebin"
    created "CatalystX-Pastebin\script"
    created "CatalystX-Pastebin\lib"
    created "CatalystX-Pastebin\root"
    created "CatalystX-Pastebin\root\static"
    created "CatalystX-Pastebin\root\static\images"
    created "CatalystX-Pastebin\t"
    created "CatalystX-Pastebin\lib\CatalystX\Pastebin"
    created "CatalystX-Pastebin\lib\CatalystX\Pastebin\Model"
    created "CatalystX-Pastebin\lib\CatalystX\Pastebin\View"
    created "CatalystX-Pastebin\lib\CatalystX\Pastebin\Controller"
    created "CatalystX-Pastebin\catalystx_pastebin.yml"
    created "CatalystX-Pastebin\lib\CatalystX\Pastebin.pm"
    created "CatalystX-Pastebin\lib\CatalystX\Pastebin\Controller\Root.pm"
    created "CatalystX-Pastebin/README"
    created "CatalystX-Pastebin/Changes"
    created "CatalystX-Pastebin\t/01app.t"
    created "CatalystX-Pastebin\t/02pod.t"
    created "CatalystX-Pastebin\t/03podcoverage.t"
    created "CatalystX-Pastebin\root\static\images\catalyst_logo.png"
    created "CatalystX-Pastebin\root\static\images\btn_120x50_built.png"
    created "CatalystX-Pastebin\root\static\images\btn_120x50_built_shadow.png"
    created "CatalystX-Pastebin\root\static\images\btn_120x50_powered.png"
    created "CatalystX-Pastebin\root\static\images\btn_120x50_powered_shadow.png"
    created "CatalystX-Pastebin\root\static\images\btn_88x31_built.png"
    created "CatalystX-Pastebin\root\static\images\btn_88x31_built_shadow.png"
    created "CatalystX-Pastebin\root\static\images\btn_88x31_powered.png"
    created "CatalystX-Pastebin\root\static\images\btn_88x31_powered_shadow.png"
    created "CatalystX-Pastebin\root\favicon.ico"
    created "CatalystX-Pastebin/Makefile.PL"
    created "CatalystX-Pastebin\script/catalystx_pastebin_cgi.pl"
    created "CatalystX-Pastebin\script/catalystx_pastebin_fastcgi.pl"
    created "CatalystX-Pastebin\script/catalystx_pastebin_server.pl"
    created "CatalystX-Pastebin\script/catalystx_pastebin_test.pl"
    created "CatalystX-Pastebin\script/catalystx_pastebin_create.pl"

=item 2, edit DBIx::Class to Makefile.PL

    requires 'DBIx::Class';
    requires 'DBD::SQLite';
    requires 'Catalyst::Model::DBIC::Schema';

=item 3, create SQLite db. script/db.pl

    #!/usr/bin/perl
    
    use strict;
    use warnings;
    use DBI;
    use FindBin qw/$Bin/;
    
    my $dbh = DBI->connect("dbi:SQLite:$Bin/../pastebin.sqlite", '', '');
    my $sql = <<'SQL';
    CREATE TABLE `pastebin` (`id` CHAR PRIMARY KEY  NOT NULL , `text` TEXT NOT NULL );
    SQL
    $dbh->do($sql) or die $DBI::errstr;
    
    print "OK\n";

=item 4, write schema stuff

    # lib/CatalystX/Pastebin/Schema.pm
    package CatalystX::Pastebin::Schema;
    
    use strict;
    use warnings;
    use base 'DBIx::Class::Schema';
    __PACKAGE__->load_classes;
    
    1;
    
    # lib/CatalystX/Pastebin/Schema/Pastebin.pm
    package CatalystX::Pastebin::Schema::Pastebin;

    use strict;
    use warnings;
    use base 'DBIx::Class';
    __PACKAGE__->load_components("Core");
    __PACKAGE__->table("pastebin");
    __PACKAGE__->add_columns(
      "id",
      { data_type => "VARCHAR", default_value => "", is_nullable => 0, size => 12 },
      "text",
      {
        data_type => "TEXT",
        default_value => undef,
        is_nullable => 0,
        size => 65535,
      }
    );
    __PACKAGE__->set_primary_key("id");
    
    1;

=back

=head1 SEE ALSO

=head1 AUTHOR

Fayland Lam L<fayland at gmail.com>

=cut
