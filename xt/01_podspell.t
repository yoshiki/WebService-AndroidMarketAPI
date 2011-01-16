use Test::More;
eval q{ use Test::Spelling; system("which", "spell") == 0 or die };
plan skip_all => "Test::Spelling or spell command is not installed." if $@;
add_stopwords(map { split /[\s\:\-]/ } <DATA>);
$ENV{LANG} = 'C';
all_pod_files_spelling_ok('lib');
__DATA__
Yoshiki Kurihara
kurihara at cpan.org
WebService::AndroidMarketAPI
