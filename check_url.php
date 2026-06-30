<?php
$url = 'https://gttp.efsouls.com/storage/user-avatars/01KVD1Z67XKXE3QV7SFZT3DQGM.png';
$headers = @get_headers($url);
echo "Headers for $url:\n";
print_r($headers);
