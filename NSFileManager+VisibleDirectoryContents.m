//
//  NSFileManager+VisibleDirectoryContents.m
//  Shovel
//
//  Created by Uli Kusterer on 01.10.04.
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

#import "NSFileManager+VisibleDirectoryContents.h"
#import "NSString+CarbonUtilities.h"
#import <Carbon/Carbon.h>


@implementation NSFileManager (UKVisibleDirectoryContents)

-(NSArray*)	visibleDirectoryContentsAtPath: (NSString*)path
{
	NSDirectoryEnumerator*	enny = [[NSFileManager defaultManager] enumeratorAtPath: path];
	NSMutableArray*			arr = [NSMutableArray array];
	NSString*				currFN;
	
	while( (currFN = [enny nextObject]) )
	{
		[enny skipDescendents];
		if( [currFN characterAtIndex: 0] == '.' )
            continue;
        
        FSRef           fref;
        FSCatalogInfo   info;
        
        if( [[path stringByAppendingPathComponent: currFN] getFSRef: &fref] )
        {
            if( noErr == FSGetCatalogInfo( &fref, kFSCatInfoFinderInfo, &info, NULL, NULL, NULL ) )
            {
                FileInfo*   finderInfo = (FileInfo*)info.finderInfo;
                if( (finderInfo->finderFlags & kIsInvisible) == kIsInvisible )
                    continue;
            }
        }
        
        [arr addObject: currFN];
	}
	
	return arr;
}

@end
