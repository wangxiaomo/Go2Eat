package Go2Eat;
use Dancer ':syntax';
use strict;
use warnings;
use Cwd;
use Sys::Hostname;
use Data::Dump qw/dump/;

our $VERSION = '0.1';

get '/'        => sub { template 'index'; };
get '/about/?' => sub { template 'about'; };

true;
