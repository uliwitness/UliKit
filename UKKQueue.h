//
//	UKKQueue.m
//	Filie
//
//	Created by Uli Kusterer on 21.12.2003
//	Copyright 2003 Uli Kusterer.
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

#define UKKQueueNotifyDefault						(UKKQueueNotifyAboutRename | UKKQueueNotifyAboutWrite \
													| UKKQueueNotifyAboutDelete | UKKQueueNotifyAboutAttributeChange \
													| UKKQueueNotifyAboutSizeIncrease | UKKQueueNotifyAboutLinkCountChanged \
													| UKKQueueNotifyAboutAccessRevocation)

// -----------------------------------------------------------------------------
//  UKKQueue:
// -----------------------------------------------------------------------------

@interface UKKQueue : NSObject <UKFileWatcher>
{
	NSMutableDictionary*	watchedFiles;	// List of NSStrings containing the paths we're watching. These match up with watchedFDs, as a dictionary that may have duplicate keys.
	id						delegate;		// Gets messages about changes instead of notification center, if specified.
	BOOL					alwaysNotify;	// Send notifications with us as the object even when we have a delegate.
}

+(id)		sharedFileWatcher;      // Returns a singleton, a shared kqueue object. Handy if you're subscribing to the notifications. Use this, or just create separate objects using alloc/init. Whatever floats your boat.

-(int)		queueFD;		// I know you unix geeks want this...

-(BOOL)		alwaysNotify;
-(void)		setAlwaysNotify: (BOOL)state;

// High-level file watching:
-(void)		addPath: (NSString*)path;			// UKFileWatcher protocol, preferred.
-(void)		addPath: (NSString*)path notifyingAbout: (u_int)fflags;
-(void)		removePath: (NSString*)path;		// UKFileWatcher protocol.
-(void)		removeAllPaths;						// UKFileWatcher protocol.

// For alloc/inited instances, you can specify a delegate instead of subscribing for notifications:
-(void)		setDelegate: (id)newDelegate;		// UKFileWatcher protocol.
-(id)		delegate;							// UKFileWatcher protocol.

@end

