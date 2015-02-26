package RebuildRelatedObjects::L10N::ja;

use strict;
use base 'RebuildRelatedObjects::L10N::en_us';
use vars qw ( %Lexicon );

%Lexicon = (
    'bit part LLC' => 'bit part 合同会社',
    'Rebuild related entries or pages.' => '記事/ウェブページの相互関連付けや再構築を行います。',
    # config_blog.tmpl
    'Entry Field Basename' => 'フィールドのベースネーム(記事)',
    'Save basename of a field on Entry.' => '記事のフィールドのベースネームを入力',
    'Page Field Basename' => 'フィールドのベースネーム(ウェブページ)',
    'Save basename of a field on Page.' => 'ウェブページのフィールドのベースネームを入力',
    'Enable Mutual Relation' => '相互関連付けを有効にする',
    'Relate each other' => '相互に関連付けます',
);

1;
