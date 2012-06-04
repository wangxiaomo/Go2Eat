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

get '/debug' => sub {
    my $flag = cookie 'is_login';
    return $flag;
};

get  '/' => sub { 
    if(cookie 'is_login'){
    # if(session('is_login')){
        # already login
        session is_login => 1;
        my $username = cookie 'username';
        my $user = Helper::get_user_info($username);
        template 'index',{
            msg     =>  get_flash(),
            username=>  $username,
            user    =>  $user,
        };
    }else{
        template 'index',{msg=>get_flash()};
    }
};
get  '/about/?' => sub { template 'about'; };
any  '/login/?' => sub {
    if( request->method eq 'POST' ){
        my ($username, $userpass) = map {params->{$_}} qw/username userpass/;
        my $user = Helper::login_isvalid($username, $userpass);
        if($user){
            # login success
            # session is_login => 1;
            # session username => $username;
            cookie is_login => 1;
            cookie username => $username;
        }else{
            #login failed
            set_flash('username or userpass unvalid!');
        }
    }
    redirect '/';
};
get '/logout' => sub {
    session->destroy;
    cookie is_login => 0;
    cookie username => '';
    set_flash('logout success!');
    redirect '/';
};

true;
