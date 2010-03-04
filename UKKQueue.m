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

#import "UKKQueue.h"
#import "UKMainThreadProxy.h"
#import <unistd.h>
#import <fcntl.h>
#include <sys/stat.h>

// -----------------------------------------------------------------------------
//  Macros:
// -----------------------------------------------------------------------------

#define DEBUG_LOG_THREAD_LIFETIME		1
#define DEBUG_DETAILED_MESSAGES			1

#ifndef MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
#define NSUInteger		unsigned
#endif

// -----------------------------------------------------------------------------
//  Helper class:
// -----------------------------------------------------------------------------

@interface UKKQueuePathEntry : NSObject
{
	NSString*		path;
	int				watchedFD;
	u_int			subscriptionFlags;
	int				pathRefCount;
}

-(id)	initWithPath: (NSString*)inPath flags: (u_int)fflags;

-(void)			retainPath;
-(BOOL)			releasePath;

-(NSString*)	path;
-(int)			watchedFD;

-(u_int)		subscriptionFlags;
-(void)			setSubscriptionFlags: (u_int)fflags;

@end

@implementation UKKQueuePathEntry

-(id)	initWithPath: (NSString*)inPath flags: (u_int)fflags;
{
	if(( self = [super init] ))
	{
		path = [inPath copy];
		watchedFD = open( [path fileSystemRepresentation], O_EVTONLY, 0 );
		if( watchedFD < 0 )
		{
			[self autorelease];
			return nil;
		}
		subscriptionFlags = fflags;
		pathRefCount = 1;
	}
	
	return self;
}

-(void)	dealloc
{
	[path release];
	path = nil;
	if( watchedFD >= 0 )
		close(watchedFD);
	watchedFD = -1;
	pathRefCount = 0;
	
	[super dealloc];
}

-(void)	retainPath
{
	@synchronized( self )
	{
		pathRefCount++;
	}
}

-(BOOL)	releasePath
{
	@synchronized( self )
	{
		pathRefCount--;
		
		return (pathRefCount == 0);
	}
	
	return NO;
}

-(NSString*)	path
{
	return path;
}

-(int)	watchedFD
{
	return watchedFD;
}

-(u_int)	subscriptionFlags
{
	return subscriptionFlags;
}

-(void)	setSubscriptionFlags: (u_int)fflags
{
	subscriptionFlags = fflags;
}


@end



// -----------------------------------------------------------------------------
//  Private stuff:
// -----------------------------------------------------------------------------

@interface UKKQueueCentral : NSObject
{
	int						queueFD;				// The actual queue ID (Unix file descriptor).
	NSMutableDictionary*	watchedFiles;			// List of UKKQueuePathEntries.
	BOOL					keepThreadRunning;
}

-(int)		queueFD;				// I know you unix geeks want this...

// UKFileWatcher protocol methods:
-(void)		addPath: (NSString*)path;
-(void)		addPath: (NSString*)path notifyingAbout: (u_int)fflags;
-(void)		removePath: (NSString*)path;
-(void)		removeAllPaths;

// Main bottleneck for subscribing:
-(UKKQueuePathEntry*)	addPathToQueue: (NSString*)path notifyingAbout: (u_int)fflags;

// Actual work is done here:
-(void)		watcherThread: (id)sender;
-(void)		postNotification: (NSString*)nm forFile: (NSString*)fp; // Message-posting bottleneck.

@end


// -----------------------------------------------------------------------------
//  Globals:
// -----------------------------------------------------------------------------

static UKKQueueCentral	*	gUKKQueueSharedQueueSingleton = nil;
static id					gUKKQueueSharedNotificationCenterProxy = nil;	// Object to which we send notifications so they get put in the main thread.


@implementation UKKQueueCentral

// -----------------------------------------------------------------------------
//	* CONSTRUCTOR:
//		Creates a new KQueue and starts that thread we use for our
//		notifications.
//
//	REVISIONS:
//		2008-11-07	UK	Adapted to new threading model.
//      2004-11-12  UK  Doesn't pass self as parameter to watcherThread anymore,
//                      because detachNewThreadSelector retains target and args,
//                      which would cause us to never be released.
//		2004-03-13	UK	Documented.
// -----------------------------------------------------------------------------

-(id)   init
{
	self = [super init];
	if( self )
	{
		if( !gUKKQueueSharedNotificationCenterProxy )
		{
			gUKKQueueSharedNotificationCenterProxy = [[[NSWorkspace sharedWorkspace] notificationCenter] copyMainThreadProxy];	// Singleton, 'intentional leak'.
			[gUKKQueueSharedNotificationCenterProxy setWaitForCompletion: NO];	// Better performance and avoid deadlocks.
		}
		
		queueFD = kqueue();
		if( queueFD == -1 )
		{
			[self release];
			return nil;
		}
		
		watchedFiles = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}


// -----------------------------------------------------------------------------
//	* DESTRUCTOR:
//		Releases the kqueue again.
//
//	REVISIONS:
//		2008-11-07	UK	Adapted to new threading model.
//		2004-03-13	UK	Documented.
// -----------------------------------------------------------------------------

-(void) dealloc
{
	keepThreadRunning = NO;
	
	// Close all our file descriptors so the files can be deleted:
	[self removeAllPaths];
	
	[watchedFiles release];
	watchedFiles = nil;
	
	[super dealloc];
}


// -----------------------------------------------------------------------------
//	removeAllPaths:
//		Stop listening for changes to all paths. This removes all
//		notifications.
//
//  REVISIONS:
//		2008-11-07	UK	Renamed from unsubscribeAll, for consistency.
//      2004-12-28  UK  Added as suggested by bbum.
// -----------------------------------------------------------------------------

-(void)	removeAllPaths
{
	@synchronized( self )
    {
		[watchedFiles removeAllObjects];
	}
}


// -----------------------------------------------------------------------------
//	queueFD:
//		Returns a Unix file descriptor for the KQueue this uses. The descriptor
//		is owned by this object. Do not close it!
//
//	REVISIONS:
//		2004-03-13	UK	Documented.
// -----------------------------------------------------------------------------

-(int)  queueFD
{
	return queueFD;
}

-(void) addPath: (NSString*)path
{
	[self addPath: path notifyingAbout: UKKQueueNotifyDefault];
}


-(void) addPath: (NSString*)path notifyingAbout: (u_int)fflags
{
	[self addPathToQueue: path notifyingAbout: fflags];
}

-(UKKQueuePathEntry*)	addPathToQueue: (NSString*)path notifyingAbout: (u_int)fflags
{
	@synchronized( self )
	{
		UKKQueuePathEntry*	pe = [watchedFiles objectForKey: path];	// Already watching this path?
		if( pe )
		{
			[pe retainPath];	// Just add another subscription to this entry.
			
			if( ([pe subscriptionFlags] & fflags) == fflags )	// All flags already set?
				return [[pe retain] autorelease];
			
			fflags |= [pe subscriptionFlags];
		}
		
		struct timespec		nullts = { 0, 0 };
		struct kevent		ev;
		
		if( !pe )
			pe = [[[UKKQueuePathEntry alloc] initWithPath: path flags: fflags] autorelease];
		
		if( pe )
		{
			EV_SET( &ev, [pe watchedFD], EVFILT_VNODE, 
					EV_ADD | EV_ENABLE | EV_CLEAR,
					fflags, 0, pe );
			
			[pe setSubscriptionFlags: fflags];
            [watchedFiles setObject: pe forKey: path];
            kevent( queueFD, &ev, 1, NULL, 0, &nullts );
		
			// Start new thread that fetches and processes our events:
			if( !keepThreadRunning )
			{
				keepThreadRunning = YES;
				[NSThread detachNewThreadSelector:@selector(watcherThread:) toTarget:self withObject:nil];
			}
        }
		return [[pe retain] autorelease];
   }
   
   return nil;
}


// -----------------------------------------------------------------------------
//	removePath:
//		Stop listening for changes to the specified path. Use this to balance
//		both addPath:notfyingAbout: as well as addPath:.
//
//	REVISIONS:
//		2004-03-13	UK	Documented.
// -----------------------------------------------------------------------------

-(void) removePath: (NSString*)path
{
	@synchronized( self )
	{
		UKKQueuePathEntry*	pe = [watchedFiles objectForKey: path];	// Already watching this path?
		if( pe && [pe releasePath] )	// Give up one subscription. Is this the last subscription?
			[watchedFiles removeObjectForKey: path];	// Unsubscribe from this file.
	}
}

// -----------------------------------------------------------------------------
//	description:
//		This method can be used to help in debugging. It provides the value
//      used by NSLog & co. when you request to print this object using the
//      %@ format specifier.
//
//	REVISIONS:
//		2008-11-05	UK	Made this indentation-aware.
//		2004-11-12	UK	Created.
// -----------------------------------------------------------------------------

-(NSString*)	descriptionWithLocale: (id)locale indent: (NSUInteger)level
{
	NSMutableString*	mutStr = [NSMutableString string];
	int					x = 0;
	
	for( x = 0; x < level; x++ )
		[mutStr appendString: @"    "];
	[mutStr appendString: NSStringFromClass([self class])];
	for( x = 0; x < level; x++ )
		[mutStr appendString: @"    "];
	[mutStr appendString: @"{"];
	for( x = 0; x < level; x++ )
		[mutStr appendString: @"    "];
	[mutStr appendFormat: @"watchedFiles = %@", [watchedFiles descriptionWithLocale: locale indent: level +1]];
	for( x = 0; x < level; x++ )
		[mutStr appendString: @"    "];
	[mutStr appendString: @"}"];
	
	return mutStr;
}


// -----------------------------------------------------------------------------
//	watcherThread:
//		This method is called by our NSThread to loop and poll for any file
//		changes that our kqueue wants to tell us about. This sends separate
//		notifications for the different kinds of changes that can happen.
//		All messages are sent via the postNotification:forFile: main bottleneck.
//
//		This also calls sharedWorkspace's noteFileSystemChanged.
//
//      To terminate this method (and its thread), set keepThreadRunning to NO.
//
//	REVISIONS:
//		2008-11-07	UK	Adapted to new threading model.
//		2005-08-27	UK	Changed to use keepThreadRunning instead of kqueueFD
//						being -1 as termination criterion, and to close the
//						queue in this thread so the main thread isn't blocked.
//		2004-11-12	UK	Fixed docs to include termination criterion, added
//                      timeout to make sure the bugger gets disposed.
//		2004-03-13	UK	Documented.
// -----------------------------------------------------------------------------

-(void)		watcherThread: (id)sender
{
	int					n;
    struct kevent		ev;
    struct timespec     timeout = { 1, 0 }; // 1 second timeout. Should be longer, but we need this thread to exit when a kqueue is dealloced, so 1 second timeout is quite a while to wait.
	int					theFD = queueFD;	// So we don't have to risk accessing iVars when the thread is terminated.
    
	#if DEBUG_LOG_THREAD_LIFETIME
	NSLog(@"watcherThread started.");
	#endif
	
    while( keepThreadRunning )
    {
		NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
		
		NS_DURING
			n = kevent( queueFD, NULL, 0, &ev, 1, &timeout );
			if( n > 0 )
			{
				NSLog( @"KEVENT returned %d", n );
				if( ev.filter == EVFILT_VNODE )
				{
					NSLog( @"KEVENT filter is EVFILT_VNODE" );
					if( ev.fflags )
					{
						NSLog( @"KEVENT flags are set" );
						UKKQueuePathEntry*	pe = [[(UKKQueuePathEntry*)ev.udata retain] autorelease];    // In case one of the notified folks removes the path.
						NSString*	fpath = [pe path];
						[[NSWorkspace sharedWorkspace] noteFileSystemChanged: fpath];
						
						if( (ev.fflags & NOTE_RENAME) == NOTE_RENAME )
							[self postNotification: UKFileWatcherRenameNotification forFile: fpath];
						if( (ev.fflags & NOTE_WRITE) == NOTE_WRITE )
							[self postNotification: UKFileWatcherWriteNotification forFile: fpath];
						if( (ev.fflags & NOTE_DELETE) == NOTE_DELETE )
							[self postNotification: UKFileWatcherDeleteNotification forFile: fpath];
						if( (ev.fflags & NOTE_ATTRIB) == NOTE_ATTRIB )
							[self postNotification: UKFileWatcherAttributeChangeNotification forFile: fpath];
						if( (ev.fflags & NOTE_EXTEND) == NOTE_EXTEND )
							[self postNotification: UKFileWatcherSizeIncreaseNotification forFile: fpath];
						if( (ev.fflags & NOTE_LINK) == NOTE_LINK )
							[self postNotification: UKFileWatcherLinkCountChangeNotification forFile: fpath];
						if( (ev.fflags & NOTE_REVOKE) == NOTE_REVOKE )
							[self postNotification: UKFileWatcherAccessRevocationNotification forFile: fpath];
					}
				}
			}
		NS_HANDLER
			NSLog(@"Error in UKKQueue watcherThread: %@",localException);
		NS_ENDHANDLER
		
		[pool release];
    }
    
	// Close our kqueue's file descriptor:
	if( close( theFD ) == -1 )
		NSLog(@"watcherThread: Couldn't close main kqueue (%d)", errno);
   
	#if DEBUG_LOG_THREAD_LIFETIME
	NSLog(@"watcherThread finished.");
	#endif
}


// -----------------------------------------------------------------------------
//	postNotification:forFile:
//		This is the main bottleneck for posting notifications. If you don't want
//		the notifications to go through NSWorkspace, override this method and
//		send them elsewhere.
//
//	REVISIONS:
//		2008-11-07	UK	Got rid of old notifications.
//      2004-02-27  UK  Changed this to send new notification, and the old one
//                      only to objects that respond to it. The old category on
//                      NSObject could cause problems with the proxy itself.
//		2004-10-31	UK	Helloween fun: Make this use a mainThreadProxy and
//						allow sending the notification even if we have a
//						delegate.
//		2004-03-13	UK	Documented.
// -----------------------------------------------------------------------------

-(void) postNotification: (NSString*)nm forFile: (NSString*)fp
{
	#if DEBUG_DETAILED_MESSAGES
	NSLog( @"%@: %@", nm, fp );
	#endif
	
	[gUKKQueueSharedNotificationCenterProxy postNotificationName: nm object: self
												userInfo: [NSDictionary dictionaryWithObjectsAndKeys: fp, @"path", nil]];	// The proxy sends the notification on the main thread.
}

@end


@implementation UKKQueue

// -----------------------------------------------------------------------------
//  sharedFileWatcher:
//		Returns a singleton queue object. In many apps (especially those that
//      subscribe to the notifications) there will only be one kqueue instance,
//      and in that case you can use this.
//
//      For all other cases, feel free to create additional instances to use
//      independently.
//
//	REVISIONS:
//		2006-03-13	UK	Renamed from sharedQueue.
//      2005-07-02  UK  Created.
// -----------------------------------------------------------------------------

+(id) sharedFileWatcher
{
    @synchronized( [UKKQueueCentral class] )
    {
        if( !gUKKQueueSharedQueueSingleton )
            gUKKQueueSharedQueueSingleton = [[UKKQueueCentral alloc] init];	// This is a singleton, and thus an intentional "leak".
    }
    
    return gUKKQueueSharedQueueSingleton;
}


-(id)	init
{
	if(( self = [super init] ))
	{
		watchedFiles = [[NSMutableDictionary alloc] init];
		NSNotificationCenter*	nc = [[NSWorkspace sharedWorkspace] notificationCenter];
		UKKQueueCentral*		kqc = [[self class] sharedFileWatcher];
		[nc addObserver: self selector: @selector(fileChangeNotification:)
				name: UKFileWatcherRenameNotification object: kqc];
		[nc addObserver: self selector: @selector(fileChangeNotification:)
				name: UKFileWatcherWriteNotification object: kqc];
		[nc addObserver: self selector: @selector(fileChangeNotification:)
				name: UKFileWatcherDeleteNotification object: kqc];
		[nc addObserver: self selector: @selector(fileChangeNotification:)
				name: UKFileWatcherAttributeChangeNotification object: kqc];
		[nc addObserver: self selector: @selector(fileChangeNotification:)
				name: UKFileWatcherSizeIncreaseNotification object: kqc];
		[nc addObserver: self selector: @selector(fileChangeNotification:)
				name: UKFileWatcherLinkCountChangeNotification object: kqc];
		[nc addObserver: self selector: @selector(fileChangeNotification:)
				name: UKFileWatcherAccessRevocationNotification object: kqc];
	}
	
	return self;
}


-(void)	finalize
{
	[self removeAllPaths];
	
	[super finalize];
}


-(void) dealloc
{
	delegate = nil;
	
	// Close all our file descriptors so the files can be deleted:
	[self removeAllPaths];
	
	[watchedFiles release];
	watchedFiles = nil;
	
	NSNotificationCenter*	nc = [[NSWorkspace sharedWorkspace] notificationCenter];
	UKKQueueCentral*		kqc = [[self class] sharedFileWatcher];
	[nc removeObserver: self
			name: UKFileWatcherRenameNotification object: kqc];
	[nc removeObserver: self
			name: UKFileWatcherWriteNotification object: kqc];
	[nc removeObserver: self
			name: UKFileWatcherDeleteNotification object: kqc];
	[nc removeObserver: self
			name: UKFileWatcherAttributeChangeNotification object: kqc];
	[nc removeObserver: self
			name: UKFileWatcherSizeIncreaseNotification object: kqc];
	[nc removeObserver: self
			name: UKFileWatcherLinkCountChangeNotification object: kqc];
	[nc removeObserver: self
			name: UKFileWatcherAccessRevocationNotification object: kqc];

	[super dealloc];
}


-(int)		queueFD
{
	return [[UKKQueue sharedFileWatcher] queueFD];	// We're all one big, happy family now.
}

// -----------------------------------------------------------------------------
//	addPath:
//		Tell this queue to listen for all interesting notifications sent for
//		the object at the specified path. If you want more control, use the
//		addPath:notifyingAbout: variant instead.
//
//	REVISIONS:
//		2004-03-13	UK	Documented.
// -----------------------------------------------------------------------------

-(void) addPath: (NSString*)path
{
	[self addPath: path notifyingAbout: UKKQueueNotifyDefault];
}


// -----------------------------------------------------------------------------
//	addPath:notfyingAbout:
//		Tell this queue to listen for the specified notifications sent for
//		the object at the specified path.
// -----------------------------------------------------------------------------

-(void) addPath: (NSString*)path notifyingAbout: (u_int)fflags
{
	UKKQueuePathEntry*		entry = [watchedFiles objectForKey: path];
	if( entry )
		return;	// Already have this one.
	
	entry = [[UKKQueue sharedFileWatcher] addPathToQueue: path notifyingAbout: fflags];
	[watchedFiles setObject: entry forKey: path];
}


-(void)	removePath: (NSString*)fpath
{
	UKKQueuePathEntry*		entry = [watchedFiles objectForKey: fpath];
	if( entry )	// Don't have this one, do nothing.
	{
		[watchedFiles removeObjectForKey: fpath];
		[[UKKQueue sharedFileWatcher] removePath: fpath];
	}
}


-(id)	delegate
{
    return delegate;
}


-(void)	setDelegate: (id)newDelegate
{
	delegate = newDelegate;
}


-(BOOL)	alwaysNotify
{
	return alwaysNotify;
}


-(void)	setAlwaysNotify: (BOOL)state
{
	alwaysNotify = state;
}


-(void)	removeAllPaths
{
	NSEnumerator*			enny = [watchedFiles objectEnumerator];
	UKKQueuePathEntry*		entry = nil;
	UKKQueueCentral*		sfw = [UKKQueue sharedFileWatcher];
	
	// Unsubscribe all:
	while(( entry = [enny nextObject] ))
		[sfw removePath: [entry path]];

	[watchedFiles removeAllObjects];	// Empty the list now we don't have any subscriptions anymore.
}


-(void)	fileChangeNotification: (NSNotification*)notif
{
	NSString*	fp = [[notif userInfo] objectForKey: @"path"];
	NSString*	nm = [notif name];
	if( [watchedFiles objectForKey: fp] == nil )	// Don't notify about files we don't care about.
		return;
	[delegate watcher: self receivedNotification: nm forPath: fp];
	if( !delegate || alwaysNotify )
	{
		[[[NSWorkspace sharedWorkspace] notificationCenter] postNotificationName: nm object: self
												userInfo: [notif userInfo]];	// Send the notification on to *our* clients only.
	}
}

@end


