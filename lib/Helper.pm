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

sub get_user_data_of_restaurants {
    my $username = shift;
    my $conn     = GetMongo();
    my $users    = $conn->go2eat->users;
    my $ret      = $users->find_one(
        {username    =>  $username},
        {username=>1, restaurants=>1}
    );

    # 整理算法
    my $f = sub {
        my $ref   = shift;
        my $items = $ref->{restaurants};

        my $rests = {};
        foreach my $item (@$items){
            my $restaurant_name = $item->{name};
            #TODO
            if($rests->{$restaurant_name}->{count}){
                $rests->{$restaurant_name}->{count} += 1;
                $rests->{$restaurant_name}->{score} += $item->{score};
            }else{
                $rests->{$restaurant_name} = {};
                $rests->{$restaurant_name}->{count} = 1;
                $rests->{$restaurant_name}->{score} = $item->{score};
            }
        }
        map {
            $rests->{$_}->{score} = $rests->{$_}->{score}/$rests->{$_}->{count}
            and
            delete $rests->{$_}->{count};
        } keys %$rests;
        return $rests;
    };
    return $f->($ret);
}

sub get_recommand_lists {
    my $users = shift;
    my $users_data_of_restaurants = {map {
        $_=>get_user_data_of_restaurants($_)
    } @$users};

    # 推荐算法
    my $f = sub {
        my $ref   = shift;
        my $rests = shift;

        foreach my $user (keys %$ref){
            my $user_data = $ref->{$user};
            foreach my $restaurant_name (keys %$user_data){
                if($rests->{$restaurant_name}->{count}){
                    $rests->{$restaurant_name}->{count} += 1;
                    $rests->{$restaurant_name}->{score} += $user_data->{$restaurant_name}->{score};
                }else{
                    $rests->{$restaurant_name} = {};
                    $rests->{$restaurant_name}->{count} = 1;
                    $rests->{$restaurant_name}->{score} = $user_data->{$restaurant_name}->{score};
                }
            }
        }
        map {
            $rests->{$_}->{score} = $rests->{$_}->{score}/$rests->{$_}->{count}
            and
            delete $rests->{$_}->{count};
        } keys %$rests;
        my $tmp = [map{$_} reverse sort {$rests->{$a}->{score} cmp $rests->{$b}->{score}} keys %$rests];
        if(scalar(keys %$rests)>10){
            $tmp = [@$tmp[0 .. 9]];
        }
        return {map{$_=>$rests->{$_}->{score}} @$tmp};
    };
    return $f->($users_data_of_restaurants);
}

1;

get_recommand_lists(['user1','user2']);
