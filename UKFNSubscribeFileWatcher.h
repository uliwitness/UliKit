/* =============================================================================
	FILE:		UKFNSubscribeFileWatcher.m
	PROJECT:	Filie
    
    COPYRIGHT:  (c) 2005 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   MIT License

	REVISIONS:
		2008-11-07	UK	Made more similar to UKKQueue.
		2006-03-13	UK	Commented, added singleton.
		2005-03-02	UK	Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "UKFileWatcher.h"
#import <Carbon/Carbon.h>

/*
	NOTE: FNSubscribe has a built-in delay: If your application is in the
	background while the changes happen, all notifications will be queued up
	and sent to your app at once the moment it is brought to front again. If
	your app really needs to do live updates in the background, use a KQueue
	instead.
*/

// -----------------------------------------------------------------------------
//  Class declaration:
// -----------------------------------------------------------------------------

@interface UKFNSubscribeFileWatcher : NSObject <UKFileWatcher>
{
    id					delegate;			// Delegate must respond to UKFileWatcherDelegate protocol.
    NSMutableArray*		subscribedPaths;	// List of pathnames we've subscribed to. This maps to subscribedObjects, like a dictionary that can have duplicate keys.
	NSMutableArray*		subscribedObjects;	// List of FNSubscription pointers in NSValues. This maps to subscribedPaths, like a dictionary that can have duplicate keys.
}

+(id) sharedFileWatcher;

// UKFileWatcher defines the methods: addPath: removePath:, removeAllPaths and delegate accessors.

@end
