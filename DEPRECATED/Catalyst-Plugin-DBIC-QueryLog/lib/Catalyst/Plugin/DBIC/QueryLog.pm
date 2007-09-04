package Catalyst::Plugin::DBIC::QueryLog;

use warnings;
use strict;

use NEXT;
use DBIx::Class::QueryLog;
use DBIx::Class::QueryLog::Analyzer;

use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors('querylog');
__PACKAGE__->mk_accessors('_querylog_analyzer');

use vars qw/$VERSION/;
$VERSION = '0.01';

sub querylog_analyzer {
    my $c = shift;
    
    unless ($c->_querylog_analyzer) {
        $c->_querylog_analyzer( new DBIx::Class::QueryLog::Analyzer({ querylog => $c->querylog }) );
    }
    
    return $c->_querylog_analyzer;
}

sub prepare {
    my $c = shift;
    $c = $c->NEXT::prepare(@_);

    my $model_name = $c->config->{'DBIC::QueryLog'}->{MODEL_NAME} || 'DBIC';

    my $schema = $c->model($model_name)->schema;
    $c->querylog( new DBIx::Class::QueryLog() );
    $schema->storage->debugobj( $c->querylog );
    $schema->storage->debug(1);

    return $c;
}

1; # End of Catalyst::Plugin::DBIC::QueryLog
__END__

=head1 NAME

Catalyst::Plugin::DBIC::QueryLog - Catalyst Plugin for DBIx::Class::QueryLog!

=head1 SYNOPSIS

    # MyApp.pm
    use Catalyst qw/
      ...
      DBIC::QueryLog    # Load this plugin.
      ...
    /;
    
    # myapp.yml
    DBIC::QueryLog:
      MODEL_NAME: DBIC

=head1 USAGE

then in templates:

    [% IF c.querylog %]
      <div class="featurebox">
        <h3>Query Log Report</h3>
        [% SET total = c.querylog.time_elapsed | format('%0.6f') %]
        <div>Total SQL Time: [% total | format('%0.6f') %] seconds</div>
        [% SET qcount = c.querylog.count %]
        <div>Total Queries: [% qcount %]</div>
        [% IF qcount %]
        <div>Avg Statement Time: [% (c.querylog.time_elapsed / qcount) | format('%0.6f') %] seconds.</div>
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
           [% FOREACH q = c.querylog_analyzer.get_sorted_queries %]
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
    [% END %]

=head1 SEE ALSO

L<DBIx::Class::QueryLog>

L<http://www.onemogin.com/blog/554-profile-your-catalystdbixclass-app-with-querylog.html>

=head1 KNOWN ISSUE

This module is not working well alone with L<Catalyst::Plugin::DBIC::Schema::Profiler> since they are using the same ->storage->debugobj.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
