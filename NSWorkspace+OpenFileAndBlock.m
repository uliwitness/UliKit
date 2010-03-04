//
//  NSWorkspace+OpenFileAndBlock.m
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

#import "NSWorkspace+OpenFileAndBlock.h"


@implementation NSWorkspace (UKOpenFileAndBlock)

// -----------------------------------------------------------------------------
//	externalAppWasQuitNotification:
//		This notification is sent whenever one of the apps this app launched
//		quits.
//
//	REVISIONS:
//		2004-03-31	witness	Created.
// -----------------------------------------------------------------------------

-(void) externalAppWasQuitNotification: (NSNotification*)notif
{
	NSMutableDictionary*	dict = [[NSThread currentThread] threadDictionary];

	// If this is the app this thread is listening for, set our thread-global UKOpenFileAndBlockAppFinished to YES so we stop blocking:
	if( [[dict objectForKey: @"UKOpenFileAndBlockAppPath"] isEqualToString: [[notif userInfo] objectForKey: @"NSApplicationPath"]] )
		[dict setObject: [NSNumber numberWithInt: YES] forKey: @"UKOpenFileAndBlockAppFinished"];
}


// -----------------------------------------------------------------------------
//	openFileAndBlock:
//		Open the specified file with the associated application and don't
//		return until the application has been quit. This returns YES on success,
//		NO if it couldn't launch the app.
//
//	REVISIONS:
//		2004-03-31	witness	Created.
// -----------------------------------------------------------------------------

-(BOOL) openFileAndBlock: (NSString*)path
{
	NSString*		app = nil;
	NSString*		type = nil;
	
	if( [[path pathExtension] isEqualToString: @"app"] )
		app = nil;
	else
	{
		if( ![self getInfoForFile: path application: &app type: &type] )
			return NO;
	}
	
	return [self openFileAndBlock: path withApplication: app];
}


// -----------------------------------------------------------------------------
//	openFileAndBlock:withApplication:
//		Open the specified file with the specified application and don't return
//		until the application has been quit. This returns YES on success, NO if
//		it couldn't launch the app.
//
//	REVISIONS:
//		2004-03-31	witness	Created.
// -----------------------------------------------------------------------------

-(BOOL) openFileAndBlock: (NSString*)path withApplication: (NSString*)appPath
{
	static int  nestedCalls = 0;	// Ref-count for adding/removing observer for app died notifications. Across all threads.
	BOOL		didLaunch = NO;
	
	// Get us two thread-globals to keep our app path in and whether it has quit:
	NSMutableDictionary*	dict = [[NSThread currentThread] threadDictionary];
	
	[dict setObject: [NSNumber numberWithInt: NO] forKey: @"UKOpenFileAndBlockAppFinished"];
	if( appPath )
		[dict setObject: [[appPath copy] autorelease] forKey: @"UKOpenFileAndBlockAppPath"];
	else
		[dict setObject: [[path copy] autorelease] forKey: @"UKOpenFileAndBlockAppPath"];
	
	nestedCalls++;  // FIX ME! Is this thread-safe?
	
	// Register for "app quit" notifications:
	NSNotificationCenter* centre = [self notificationCenter];
	if( nestedCalls == 1 )
		[centre addObserver: self selector:@selector(externalAppWasQuitNotification:)
						name:NSWorkspaceDidTerminateApplicationNotification object: nil];
	
	// Launch the app!
	if( appPath )
		didLaunch = [self openFile: path withApplication: appPath];
	else
		didLaunch = [self openFile: path];
	
	if( didLaunch )
	{
		// Loop until app has quit:
		while( ![[dict objectForKey: @"UKOpenFileAndBlockAppFinished"] intValue] )
		{
			NSEvent* evt = [NSApp nextEventMatchingMask: NSAnyEventMask
				untilDate:[NSDate dateWithTimeIntervalSinceNow: 1]  // 1 second so we get to check whether the flag was set.
				inMode: NSModalPanelRunLoopMode dequeue: YES];
			if( evt )
				[NSApp sendEvent: evt];
		}
	}
	
	// Unregister for notifications:
	if( --nestedCalls == 0 )  // FIX ME! Is this thread-safe?
		[centre removeObserver: self];
	
	return didLaunch;
}


@end
