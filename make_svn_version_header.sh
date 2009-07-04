#
#   Run this file as part of your build process to extract the latest
#   revision from your Subversion working copy and create a 'svn_version.h'
#   file defining a SVN_VERSION constant to that value.
#
#   The file will be created in the current directory and the subversion
#   revision number is extracted from the current folder's .svn/entries
#   file.
#

echo -n "Finding revision in "
pwd
revnum=`/usr/bin/svnversion . | cut -f '2' -d ':' | cut -f '1' -d 'M'`

# Now write the constant declaration to the file:
echo "#define SVN_VERSION \"$revnum\"" > svn_version.h
echo "Wrote revision $revnum to svn_version.h"
