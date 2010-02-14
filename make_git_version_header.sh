#
#   Run this file as part of your build process to extract the latest
#   revision from your Git working copy and create a 'svn_version.h'
#   file defining a SVN_VERSION constant to that value.
#
#	This is for a user-visible build number, so we use the number of revisions
#	and not the actual git hash.
#
#   The file will be created in the current directory and the subversion
#   revision number is extracted from the current folder's .svn/entries
#   file.
#

echo -n "note: Finding revision in "
pwd
revnum=`/usr/local/git/bin/git rev-list HEAD | /usr/bin/wc -l | sed -e 's/^ *//g;s/ *$//g'`
fullrevnum=`/usr/local/git/bin/git rev-parse HEAD`

# Now write the constant declaration to the file:
echo "#define SVN_VERSION	\"$revnum\"" > svn_version.h
echo "#define GIT_HASH	\"$fullrevnum\"" >> svn_version.h
echo "note: Wrote revision $revnum to svn_version.h"
