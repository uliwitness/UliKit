#	
#	make_svn_version_header.sh
#	TalkingMoose
#
#	Copyright 2004 Uli Kusterer.
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
