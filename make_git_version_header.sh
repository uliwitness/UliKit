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
#   file defining a SVN_VERSION constant to that value in the current directory.
#
#	This is for a user-visible build number, so we use the number of revisions
#	and not the actual git hash. You can override this value if you want to e.g.
#	have your CI server provide the build number, simply by defining
#	SVN_VERSION_NUM.
#
#	There is also a SVN_BUILD_MEANS define that is a string with which you can
#	indicate who built it (kind of as a namespace for the build number, e.g.
#	-DSVN_BUILD_MEANS=nightly
#

echo -n "note: Finding revision in "
pwd

XCODE=`xcode-select --print-path 2> /dev/null`
if [ $? -ne 0 ]; then
	XCODE=/Applications/Xcode.app/Contents/Developer
fi
GIT="$XCODE/usr/bin/git"
revnum=`$GIT rev-list HEAD | /usr/bin/wc -l | tr -d ' '`
fullrevnum=`$GIT rev-parse HEAD`
builddate=`date "+%Y-%m-%d"`

# Now write the constant declaration to the file:
echo "#define MGVH_TOSTRING2(n)			#n" > svn_version.h
echo "#define MGVH_TOSTRING(n)			MGVH_TOSTRING2(n)" >> svn_version.h
echo "#ifndef SVN_VERSION_NUM" >> svn_version.h
echo "#define SVN_VERSION_NUM				$revnum" >> svn_version.h
echo "#endif /* SVN_VERSION_NUM */" >> svn_version.h
echo "#define SVN_VERSION					MGVH_TOSTRING(SVN_VERSION_NUM)" >> svn_version.h
echo "#define GIT_HASH					\"$fullrevnum\"" >> svn_version.h
echo "#define SVN_BUILD_DATE				\"$builddate\"" >> svn_version.h
echo "#ifndef SVN_BUILD_MEANS" >> svn_version.h
echo "#define SVN_BUILD_MEANS				manual" >> svn_version.h
echo "#endif /* SVN_BUILD_MEANS */" >> svn_version.h
echo "#define SVN_BUILD_MEANS_STR		MGVH_TOSTRING(SVN_BUILD_MEANS)" >> svn_version.h

echo "note: Wrote revision $revnum to svn_version.h"
