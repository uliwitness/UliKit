//
//  NSFileManager+VisibleDirectoryContents.m
//  Shovel
//
//  Created by Uli Kusterer on 01.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
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
