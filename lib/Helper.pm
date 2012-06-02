package Helper;

use warnings;
use strict 'vars';

sub GetMongo {
    use MongoDB;
    return MongoDB::Connection->new;
}

1;

package main;
use Data::Dumper;

my $conn  = Helper::GetMongo;
my $users = $conn->go2eat->users;
my $ret   = $users->find();

while (my $user = $ret->next) {
    print Dumper($user);
}
