use inc::Module::Install;
name 'WebService-AndroidMarketAPI';
all_from 'lib/WebService/AndroidMarketAPI.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
install_share;
WriteAll;
