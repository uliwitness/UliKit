#!/usr/bin/php
<?php
//
//	make_buildnumber_header.php
//	TalkingMoose
//
//	
//	Copyright 205 Uli Kusterer.
//	
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

$oldheader = file_get_contents("svn_version.h");

$matches = array();
$regexp = "/#define([ \\r\\n\\t]*)SVN_VERSION([ \\r\\n\\t]*)\"([^ \\r\\n]*)\"/";
if( preg_match( $regexp, $oldheader, $matches ) != 1 )
    $oldversion = 0;
else
    $oldversion = hexdec($matches[3]);

$newversion = $oldversion +1;
$filebody = "#define\tSVN_VERSION\t\"".dechex($newversion)."\"\n";

$fp = fopen("svn_version.h","w");
fwrite( $fp, $filebody );

echo $filebody;
?>