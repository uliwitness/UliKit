//
//  NSFileManager+ExistingFilesAtPaths.m
//  SVNBrowser
//
//  Created by Uli Kusterer on 14.10.04.
//  Copyright 2004 M. Uli Kusterer.
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

#import "NSFileManager+ExistingFilesAtPaths.h"


@implementation NSFileManager (UKExistingFilesAtPaths)

-(NSArray*)		existingFilesAtPaths: (NSArray*)paths
{
	NSEnumerator*	enny = [paths objectEnumerator];
	NSString*		currPath;
	NSMutableArray*	muarr = [NSMutableArray array];
	
	while( (currPath = [enny nextObject]) )
	{
		if( [self fileExistsAtPath: currPath] )
			[muarr addObject: currPath];
	}
	
	return muarr;
}


-(NSString*)	firstExistingFileAtPaths: (NSArray*)paths
{
	NSArray*	arr = [self existingFilesAtPaths: paths];
	
	if( [arr count] < 1 )
		return nil;
	else
		return [arr objectAtIndex: 0];
}


@end
