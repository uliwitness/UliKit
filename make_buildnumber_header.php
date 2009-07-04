#!/usr/bin/php
<?php
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