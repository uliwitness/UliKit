//
//  NSWorkspace+UnpackArchive.h
//  Shovel
//
//  Created by Uli Kusterer on Wed Mar 31 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
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
