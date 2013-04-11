//
//	NSFileManager+NameForTempFile.m
//	Filie
//
//	Created by Uli Kusterer on 8.2.2004
//	Copyright 2004 by Uli Kusterer.
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

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import "NSFileManager+NameForTempFile.h"


@implementation NSFileManager (UKNameForTempFile)

// -----------------------------------------------------------------------------
//	nameForTempFile:
//		Quickly generates a (pretty random) unique file name for a file in the
//		NSTemporaryDirectory and returns that path. Use this for temporary
//		files the user will not see.
//
//	REVISIONS:
//		2004-03-21	witness	Documented.
// -----------------------------------------------------------------------------

-(NSString*)	nameForTempFile
{
	NSString*   tempDir = NSTemporaryDirectory();
	int			n = rand();
	NSString*   fname = nil;
	
	if( !tempDir )
		return nil;
	while( !fname || [self fileExistsAtPath: fname] )
		fname = [tempDir stringByAppendingPathComponent: [NSString stringWithFormat:@"temp_%i", n++]];
	
	return fname;
}

// -----------------------------------------------------------------------------
//	uniqueFileName:
//		Takes a file path and if an item already exists at that path, generates
//		a unique file name by appending a number. Use this to e.g. add files
//		to user-owned folders (like the desktop) to ensure you don't overwrite
//		any valuable data.
//
//      May return NIL if it's searched for a while (after about 2 billion
//      attempts).
//
//	REVISIONS:
//		2004-03-21	witness	Documented.
// -----------------------------------------------------------------------------

-(NSString*)	uniqueFileName: (NSString*)oldName
{
	NSString*	baseName = [oldName stringByDeletingPathExtension];
	NSString*	suffix = [oldName pathExtension];
	NSString*	numSuffix = nil;
	NSInteger	n = 1;
	NSString*   fname = oldName;
	BOOL		didRemoveTrailingNumber = NO;
	
	while( [self fileExistsAtPath: fname] ) // Keep looping until we have a unique name:
	{
		if( !didRemoveTrailingNumber )
		{
			// Remove trailing number or space, but only once we're *sure* the original name already exists:
			NSRange		nonNumericRange = { 0, 0 };
			nonNumericRange.length = [baseName length];
			while( nonNumericRange.length > 0 )
			{
				unichar	theCh = [baseName characterAtIndex: nonNumericRange.length -1];
				if( theCh == '0' || theCh == '1' || theCh == '2' || theCh == '3' || theCh == '4'
					|| theCh == '5' || theCh == '6' || theCh == '7' || theCh == '8' || theCh == '9'
					|| theCh == ' ' )
					nonNumericRange.length -= 1;
				else
					break;	// Found a non-numeric char.
			}
			
			if( nonNumericRange.length != [baseName length] )	// Was a number at the end? Remove it and start counting at that number.
			{
				numSuffix = [baseName substringFromIndex: nonNumericRange.location +nonNumericRange.length];
				baseName = [baseName substringWithRange: nonNumericRange];
				n = [numSuffix integerValue];
			}
			
			didRemoveTrailingNumber = YES;
		}
		
		if( [suffix length] == 0 )  // Build "/folder/file 1"-style path:
			fname = [baseName stringByAppendingString: [NSString stringWithFormat:@" %ld", n++]];
		else						// Build "/folder/file 1.suffix"-style path:
			fname = [baseName stringByAppendingString: [NSString stringWithFormat:@" %ld.%@", n++, suffix]];
		
		if( n <= 0 )	// overflow!
			return nil;
	}
	
	return fname;
}

@end
