# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lingua-Han2PinYin.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 7;
BEGIN { use_ok('Lingua::Han::PinYin') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.


my $h2p = new Lingua::Han::PinYin();
is(ref($h2p) => 'Lingua::Han::PinYin', 'class');
my $pinyin = $h2p->han2pinyin("ÎÒ");
is($pinyin, 'wo', 'correct');
$pinyin = $h2p->han2pinyin("ÉÙ");
is($pinyin, 'shao', 'correct');
$pinyin = $h2p->han2pinyin("ĞÒ");
is($pinyin, 'xing', 'correct');
$pinyin = $h2p->han2pinyin("°®Äã");
is($pinyin, 'aini', 'correct');
$pinyin = $h2p->han2pinyin("I love ÓàÈğ»ª a");
is($pinyin, 'i love yuruihua a', 'correct');