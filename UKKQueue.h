/* =============================================================================
	FILE:		UKKQueue.h
	PROJECT:	Filie
    
    COPYRIGHT:  (c) 2003 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   MIT License

	REVISIONS:
		2008-11-07	UK	Removed deprecated stuff, more comments.
		2008-11-05	UK	General cleanup, prettier thread handling.
		2006-03-13	UK	Clarified license, streamlined UKFileWatcher stuff,
						Changed notifications to be useful and turned off by
						default some deprecated stuff.
		2003-12-21	UK	Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#include <sys/types.h>
#include <sys/event.h>
#import "UKFileWatcher.h"


// -----------------------------------------------------------------------------
//  Constants:
// -----------------------------------------------------------------------------

// Flags for notifyingAbout:
#define UKKQueueNotifyAboutRename					NOTE_RENAME		// Item was renamed.
#define UKKQueueNotifyAboutWrite					NOTE_WRITE		// Item contents changed (also folder contents changed).
#define UKKQueueNotifyAboutDelete					NOTE_DELETE		// item was removed.
#define UKKQueueNotifyAboutAttributeChange			NOTE_ATTRIB		// Item attributes changed.
#define UKKQueueNotifyAboutSizeIncrease				NOTE_EXTEND		// Item size increased.
#define UKKQueueNotifyAboutLinkCountChanged			NOTE_LINK		// Item's link count changed.
#define UKKQueueNotifyAboutAccessRevocation			NOTE_REVOKE		// Access to item was revoked.


// -----------------------------------------------------------------------------
//  UKKQueue:
// -----------------------------------------------------------------------------

/*
	WARNING:	A kqueue retains itself while it is watching paths. If you want
				to make sure a kqueue gets released, call removeAllPaths on it
				before you release it.
*/

@interface UKKQueue : NSObject <UKFileWatcher>
{
	int				queueFD;				// The actual queue ID (Unix file descriptor).
	NSMutableArray* watchedPaths;			// List of NSStrings containing the paths we're watching. These match up with watchedFDs, as a dictionary that may have duplicate keys.
	NSMutableArray* watchedFDs;				// List of NSNumbers containing the file descriptors we're watching. These match up with watchedPaths, as a dictionary that may have duplicate keys.
	id				delegate;				// Gets messages about changes instead of notification center, if specified.
	id				delegateProxy;			// Proxy object to which we send messages so they reach delegate on the main thread.
	BOOL			alwaysNotify;			// Send notifications even if we have a delegate? Defaults to NO for alloc/inited instances, YES for the singleton.
	BOOL			keepThreadRunning;		// Termination criterion of our thread.
	BOOL			threadHasTerminated;	// Feedback whether our thread has successfully quit.
}

+(id)		sharedFileWatcher;      // Returns a singleton, a shared kqueue object. Handy if you're subscribing to the notifications. Use this, or just create separate objects using alloc/init. Whatever floats your boat.

-(int)		queueFD;		// I know you unix geeks want this...

// High-level file watching:
-(void)		addPath: (NSString*)path;		// UKFileWatcher protocol, preferred.
-(void)		addPath: (NSString*)path notifyingAbout: (u_int)fflags;
-(void)		removePath: (NSString*)path;	// UKFileWatcher protocol.
-(void)		removeAllPaths;					// UKFileWatcher protocol.

// For alloc/inited instances, you can specify a delegate instead of subscribing for notifications:
-(void)		setDelegate: (id)newDelegate;	// UKFileWatcher protocol.
-(id)		delegate;						// UKFileWatcher protocol.

-(void)		setAlwaysNotify: (BOOL)n;	// Send notifications even if we have a delegate.
-(BOOL)		alwaysNotify;

@end

