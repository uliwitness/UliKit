//
//  NSWorkspace+ApplicationIsLaunched.m
//  TakeCovers
//
//  Created by Uli Kusterer on 11.05.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import "NSWorkspace+ApplicationIsLaunched.h"


@implementation NSWorkspace (UKApplicationIsLaunched)

-(BOOL)	applicationIsLaunchedAtPath: (NSString*)appPath
{
	NSArray*			runningApps = [[[self launchedApplications] retain] autorelease];
	NSEnumerator*		runningAppsEnumerator = [runningApps objectEnumerator];
	NSDictionary*		currRunningApp = nil;
	
	while( (currRunningApp = [runningAppsEnumerator nextObject]) )
	{
		if( [appPath isEqualToString: [currRunningApp objectForKey: @"NSApplicationPath"]] )
			return YES;
	}
	
	return NO;
}

-(BOOL)	applicationIsLaunchedWithIdentifier: (NSString*)bundleID
{
	NSArray*			runningApps = [[[self launchedApplications] retain] autorelease];
	NSEnumerator*		runningAppsEnumerator = [runningApps objectEnumerator];
	NSDictionary*		currRunningApp = nil;
	
	while( (currRunningApp = [runningAppsEnumerator nextObject]) )
	{
		NSString*		currAppPath = [currRunningApp objectForKey: @"NSApplicationPath"];
		NSString*		currAppID = [[NSBundle bundleWithPath: currAppPath] bundleIdentifier];
		if( [bundleID isEqualToString: currAppID] )
			return YES;
	}
	
	return NO;
}



@end
