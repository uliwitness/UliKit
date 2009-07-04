//
//  NSFileManager+ExistingFilesAtPaths.m
//  SVNBrowser
//
//  Created by Uli Kusterer on 14.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
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
