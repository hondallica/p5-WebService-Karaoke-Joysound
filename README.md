# NAME

WebService::Karaoke::Joysound - カラオケJoysoundの検索フォームラッパー

# SYNOPSIS

    use WebService::Karaoke::Joysound;

    my $joysound = new WebService::Karaoke::Joysound;

    my $data = $joysound->search('artist', 'Metallica');
    $data = $joysound->search('songs', 233048);

# DESCRIPTION

カラオケJoysoundの検索フォームラッパー

# LICENSE

Copyright (C) Hondallica.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Hondallica <hondallica@gmail.com>
