package Apache2My::FileMapping;

use strict;
use warnings;
use Apache2::RequestRec ();
use Apache2::Const -compile => qw(OK DECLINED);
use Apache2::Log;

sub handler {
    my $r = shift;
    
    my $uri = $r->uri;
    $r->log_error($r->uri);
    
    if ($uri =~ /test\.txt$/) {
        $r->filename('E:\Fayland\Perl\fayland.txt');
        return Apache2::Const::DECLINED;
    }

    return Apache2::Const::DECLINED;
}

1;