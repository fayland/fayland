package Catalyst::Model::DBIC::Schema::QueryLog;

use warnings;
use strict;
use vars qw/$VERSION/;
$VERSION = '0.01';

use base 'Catalyst::Model::DBIC::Schema';
__PACKAGE__->mk_accessors('querylog');

use DBIx::Class::QueryLog;
use DBIx::Class::QueryLog::Analyzer;

sub new {
    my $self = shift->NEXT::new(@_);

    my $schema = $self->schema;
    
    my $querylog = new DBIx::Class::QueryLog();
    $self->querylog($querylog);
    
    $schema->storage->debugobj( $querylog );
    $schema->storage->debug(1);
    
    return $self;
}

sub querylog_analyzer {
    my $self = shift;
    
    my $ann = new DBIx::Class::QueryLog::Analyzer({ querylog => $self->querylog });
    return $ann;
}

1; # End of Catalyst::Model::DBIC::Schema::QueryLog
__END__

=head1 NAME

Catalyst::Model::DBIC::Schema::QueryLog - The great new Catalyst::Model::DBIC::Schema::QueryLog!

=head1 SYNOPSIS

  package MyApp::Model::FilmDB;
  use base qw/Catalyst::Model::DBIC::Schema::QueryLog/;

  __PACKAGE__->config(
      schema_class => 'MyApp::Schema::FilmDB',
      connect_info => [
                        "DBI:...",
                        "username",
                        "password",
                        {AutoCommit => 1}
                      ]
  );

=head1 METHODS

=over 4

=item querylog

an instance of DBIx::Class::QueryLog.

=item querylog_analyzer

an instance of DBIx::Class::QueryLog::Analyzer.

=back

=head1 EXAMPLE CODE

  <div class="featurebox">
    <h3>Query Log Report</h3>
    [% SET total = c.model('DBIC').querylog.time_elapsed | format('%0.6f') %]
    <div>Total SQL Time: [% total | format('%0.6f') %] seconds</div>
    [% SET qcount = c.model('DBIC').querylog.count %]
    <div>Total Queries: [% qcount %]</div>
    [% IF qcount %]
    <div>Avg Statement Time: [% (c.model('DBIC').querylog.time_elapsed / qcount) | format('%0.6f') %] seconds.</div>
    <div>
     <table class="table1">
      <thead>
       <tr>
        <th colspan="3">5 Slowest Queries</th>
       </tr>
      </thead>
      <tbody>
       <tr>
        <th>Time</th>
        <th>%</th>
        <th>SQL</th>
       </tr>
       [% SET i = 0 %]
       [% FOREACH q = c.model('DBIC').querylog_analyzer.get_sorted_queries %]
       <tr class="[% IF loop.count % 2 %]odd[% END %]">
        <th class="sub">[% q.time_elapsed | format('%0.6f') %]
        <td>[% ((q.time_elapsed / total ) * 100 ) | format('%i') %]%</td>
        <td>[% q.sql %]</td>
       </th></tr>
       [% IF i == 5 %]
        [% LAST %]
       [% END %]
       [% SET i = i + 1 %]
       [% END %]
      </tbody>
     </table>
    </div>
    [% END %]
  </div>

=head1 SEE ALSO

L<Catalyst::Model::DBIC::Schema>

L<DBIx::Class::QueryLog>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut