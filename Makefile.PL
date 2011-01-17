use inc::Module::Install;
name 'WebService-AndroidMarketAPI';
all_from 'lib/WebService/AndroidMarketAPI.pm';

requires 'Net::Google::AuthSub';
requires 'Google::ProtocolBuffers';
requires 'File::ShareDir';
requires 'LWP::UserAgent';
requires 'HTTP::Request';
requires 'HTTP::Headers';
requires 'IO::Uncompress::Gunzip';
requires 'Class::Accessor::Fast';
requires 'MIME::Base64';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
install_share;
WriteAll;
