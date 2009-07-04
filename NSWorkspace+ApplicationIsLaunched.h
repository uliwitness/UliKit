//
//  NSWorkspace+ApplicationIsLaunched.h
//  TakeCovers
//
//  Created by Uli Kusterer on 11.05.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

/*
	Convenience methods for finding items in NSWorkspace's launchedApplications
	array.
*/

#import <Cocoa/Cocoa.h>


@interface NSWorkspace (UKApplicationIsLaunched)

-(BOOL)	applicationIsLaunchedAtPath: (NSString*)appPath;			// Faster.
-(BOOL)	applicationIsLaunchedWithIdentifier: (NSString*)bundleID;	// Generally safer.

@end
