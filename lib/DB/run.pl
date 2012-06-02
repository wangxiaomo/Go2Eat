
use warnings;
use strict 'vars';

use MongoDB;
my $conn  = MongoDB::Connection->new;
my $users = $conn->go2eat->users;

# remove all
$users->remove();

# bring some test data
$users->insert({username=>'user1', userpass=>'123', groups=>[], restaurants=>[]});
$users->insert({username=>'user2', userpass=>'123', groups=>[], restaurants=>[]});
$users->insert({username=>'user3', userpass=>'123', groups=>[], restaurants=>[]});
$users->insert({username=>'user4', userpass=>'123', groups=>[], restaurants=>[]});

print "Initialization Over.\n";
