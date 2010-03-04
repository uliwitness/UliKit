//
//  UKApplicationEnumerator.m
//  Shovel
//
//  Created by Uli Kusterer on Wed Mar 31 2004.
//  Copyright (c) 2004 Uli Kusterer.
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

#import "UKApplicationEnumerator.h"
#import <AppKit/AppKit.h>


OSStatus (*LSCopyAllApplicationURLs)( NSArray* *theList );


@implementation UKApplicationEnumerator

-(id) init
{
	self = [super init];
	if( !self )
		return nil;
	
	// Try Spotlight first:
	Class	UKMetadataQuery = NSClassFromString(@"NSMetadataQuery");
	query = [[UKMetadataQuery alloc] init];
	if( query )
	{
		[query setDelegate: self];
		[query setPredicate: [NSPredicate predicateWithFormat:@"kMDItemContentTypeTree == 'com.apple.application'"]];
		//[query setSearchScopes: [NSArray arrayWithObjects: NSMetadataQueryLocalComputerScope, nil]];
		[[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(metadataQueryGatheringProgress:) name: NSMetadataQueryGatheringProgressNotification object:query];
		[[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(metadataQueryGatheringProgress:) name: NSMetadataQueryDidStartGatheringNotification object:query];
		[[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(metadataQueryDidFinishGathering:) name: NSMetadataQueryDidFinishGatheringNotification object:query];
		
		appsArray = [[NSMutableArray alloc] init];
		appsEnny = [[appsArray objectEnumerator] retain];
		currIndex = 0;
		currIndexInCache = 0;
		
		if( [query startQuery] )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate distantPast]];
		else
			query = nil;	// Fall through to LS call.
	}
	
	// Then try Launch Services private call:
	CFBundleRef theBundle = CFBundleGetBundleWithIdentifier( CFSTR("com.apple.LaunchServices") );
	LSCopyAllApplicationURLs = CFBundleGetFunctionPointerForName( theBundle, CFSTR("_LSCopyAllApplicationURLs") );
	if( !query && LSCopyAllApplicationURLs )
	{
		LSCopyAllApplicationURLs( &appsArray );
		appsEnny = [[appsArray objectEnumerator] retain];
		currIndex = [appsArray count];
	}
	else if( !query )	// Fail and let caller cope with this mess:
	{
		[self release];
		return nil;
	}
	
	return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[query release];
	[appsEnny release];
	[appsArray release];
	
	[super dealloc];
}


-(NSString*)	nextObject
{
	while( currIndexInCache >= currIndex && query )	// Not enough items in array and query not finished?
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate distantPast]];	// Otherwise process events, which makes sure that NSMetadataQuery can send us our notifications.
	
	if( !query && currIndexInCache >= currIndex )	// Query has returned all results and we're out of cached and uncached indexes?
		return nil;
	
	currApp = [[appsArray objectAtIndex: currIndexInCache] path];
	currIndexInCache++;
	
	return currApp;
}


-(NSDictionary*)	fileAttributes
{
	return [[NSFileManager defaultManager] fileAttributesAtPath: currApp traverseLink: NO];
}


-(void)				skipDescendents
{
	// Dummied out.
}


-(void)	metadataQueryGatheringProgress: (NSNotification*)notif
{
	
	int					numResults = [query resultCount];
	//NSLog( @"Query progressing (%d results)...", numResults );
	while( currIndex < numResults )
	{
		NSObject*	mdi = [query resultAtIndex: currIndex];
		NSString*	path = [mdi valueForKey: (NSString*) kMDItemPath];
		[(NSMutableArray*)appsArray addObject: [NSURL fileURLWithPath: path]];
		currIndex++;
	}
	//NSLog( @"\tQuery processed (%d results)...", numResults );
}

-(void)	metadataQueryDidFinishGathering: (NSNotification*)notif
{
	[query disableUpdates];
	int					numResults = [query resultCount];

	//NSLog( @"Query finished (%d results).", numResults );
	
	if( currIndex < numResults )
		[self metadataQueryGatheringProgress: notif];	// Process the last remaining items.
	
	[query stopQuery];
	[query autorelease];
	query = nil;
}


@end
