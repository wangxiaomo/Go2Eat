package Go2Eat;
use Dancer ':syntax';
use strict;
use warnings;
use Cwd;
use Sys::Hostname;
use Data::Dump qw/dump/;

use Helper;

our $VERSION = '0.1';
my $flash;
set session => 'Simple';

sub set_flash {
    my $msg = shift;
    $flash = $msg;
}

sub get_flash {
    my $msg = $flash;
    $flash  = '';
    return $msg;
}

get  '/'        => sub { template 'index',{msg=>get_flash()}; };
get  '/about/?' => sub { template 'about'; };
any  '/login/?' => sub {
    if( request->method eq 'POST' ){
        my ($username, $userpass) = map {params->{$_}} qw/username userpass/;
        my $user = Helper::login_isvalid($username, $userpass);
        if($user){
            #login success
            session is_login => 1;
            session username => $username;
        }else{
            #login failed
            set_flash('username or userpass unvalid!');
        }
    }
    template 'index', {
        msg => get_flash(),
    };
};
get '/logout' => sub {
    session->destroy;
    set_flash('logout');
    redirect '/';
};

true;
