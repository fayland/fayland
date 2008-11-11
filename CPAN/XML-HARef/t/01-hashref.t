#!perl -T

use Test::More;

use XML::HARef qw/ref_to_xml/;

my @tests = ( {
	data => {
		a => 'b',
	},
	xml  => '<a>b</a>'
}, {
	data => {
		a => 'b',
		_attrs => {
			c => 'd'
		}
	},
	xml  => '<a c="d">b</a>'
}, {
	data => {
		a => 'b',
		_attrs => {
			c => 'd'
		},
		f => 'g',
	},
	xml  => '<a c="d">b</a><f c="d">g</f>'
}, {
	data => {
            '_attrs' => {
                        'last_visit' => '2008-11-11',
                        'member_since' => '2006-03-07',
                      },
            user => {
				'basic' => {
                         'birthday' => '1984-02-06',
                         'city' => 'Wenzhou',
                       },
				'education' => [
                             {
                               '_attrs' => {
                                           'attended' => '1998-2001',
                                           'name' => 'RenYanSong High School',
                                           'type' => 'University'
                                         },
                               'school' => undef
                             },
                             {
                               '_attrs' => {
                                           'attended' => '1998-2001',
                                           'name' => 'RenYanSong High School',
                                           'type' => 'High School'
                                         },
                               'school' => undef
                             },
                           ],
				}
	},
	xml  => '<user last_visit="2008-11-11" member_since="2006-03-07"><basic><city>Wenzhou</city><birthday>1984-02-06</birthday></basic><education><school attended="1998-2001" name="RenYanSong High School" type="University" /><school attended="1998-2001" name="RenYanSong High School" type="High School" /></education></user>'
}, {
	data => [ {
		a => 'b',
		_attrs => {
			c => 'd'
		},
		f => 'g',
	}, {
		h => 'i',
		_attrs => {
			j => 'k'
		},
		m => 'n',
	} ],
	xml  => '<a c="d">b</a><f c="d">g</f><h j="k">i</h><m j="k">n</m>'
}

);

plan tests => scalar @tests;

foreach my $t ( @tests ) {
	my $xml  = $t->{xml};
	my $data = $t->{data};
	
	my $ret = ref_to_xml( $data );
	is $ret, $xml;
}

1;