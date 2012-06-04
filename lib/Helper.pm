package Helper;

use warnings;
use strict 'vars';

sub GetMongo {
    use MongoDB;
    return MongoDB::Connection->new;
}

sub login_isvalid {
    my ($username, $userpass) = @_;
    my $conn  = GetMongo();
    my $users = $conn->go2eat->users;

    my $user  = $users->find_one({
        username    =>  $username,
        userpass    =>  $userpass,
    });
    return 0 if not defined $user;
    return $user;
}

sub get_user_info {
    my $username = shift;
    my $conn  = GetMongo();
    my $users = $conn->go2eat->users;
    return $users->find_one({
        username    =>  $username,
    });
} 

1;
