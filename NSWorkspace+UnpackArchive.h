//
//  NSWorkspace+UnpackArchive.h
//  Shovel
//
//  Created by Uli Kusterer on Wed Mar 31 2004.
//  Copyright (c) 2004 M. Uli Kusterer.
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

#import <Cocoa/Cocoa.h>


@interface NSWorkspace (UKUnpackArchive)

// Unpack a .zip file:
-(int)		unpackZipArchive: (NSString*)fpath;

// Unpack a .tgz or .tar.gz file:
-(int)		unpackTgzArchive: (NSString*)fpath;

// Unpack a .bz2 or .tbz2 file:
-(int)		unpackBz2Archive: (NSString*)fpath;

// Unpack a .dmg file:
-(int)		unpackDmgArchive: (NSString*)fpath;

/* To unpack any other files, it should usually suffice to just open it using
	my NSWorkspace+OpenFileAndBlock category. */

@end
