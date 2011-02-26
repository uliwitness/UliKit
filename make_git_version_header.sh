#
#	make_git_version_header.sh
#	TalkingMoose
#
#	Created by Uli Kusterer on 2010-02-14
#	Copyright 2010 Uli Kusterer.
#	
#	This software is provided 'as-is', without any express or implied
#	warranty. In no event will the authors be held liable for any damages
#	arising from the use of this software.
#
#	Permission is granted to anyone to use this software for any purpose,
#	including commercial applications, and to alter it and redistribute it
#	freely, subject to the following restrictions:
#
#	   1. The origin of this software must not be misrepresented; you must not
#	   claim that you wrote the original software. If you use this software
#	   in a product, an acknowledgment in the product documentation would be
#	   appreciated but is not required.
#
#	   2. Altered source versions must be plainly marked as such, and must not be
#	   misrepresented as being the original software.
#
#	   3. This notice may not be removed or altered from any source
#	   distribution.
#

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
builddate=`date "+%Y-%m-%d"`

# Now write the constant declaration to the file:
echo "#define SVN_VERSION		\"$revnum\"" > svn_version.h
echo "#define GIT_HASH		\"$fullrevnum\"" >> svn_version.h
echo "#define SVN_VERSION_NUM	$revnum" >> svn_version.h
echo "#define SVN_BUILD_DATE	\"$builddate\"" >> svn_version.h
echo "note: Wrote revision $revnum to svn_version.h"
