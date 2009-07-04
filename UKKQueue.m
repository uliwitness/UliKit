/* =============================================================================
	FILE:		UKKQueue.m
	PROJECT:	Filie
    
    COPYRIGHT:  (c) 2003 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   MIT License

	REVISIONS:
		2008-11-05	UK	General cleanup, prettier thread handling.
		2006-03-13	UK	Clarified license, streamlined UKFileWatcher stuff,
						Changed notifications to be useful and turned off by
						default some deprecated stuff.
        2004-12-28  UK  Several threading fixes.
		2003-12-21	UK	Created.
   ========================================================================== */

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


// -----------------------------------------------------------------------------
//  Private stuff:
// -----------------------------------------------------------------------------

@interface UKKQueue (UKPrivateMethods)

-(void)		watcherThread: (id)sender;
-(void)		postNotification: (NSString*)nm forFile: (NSString*)fp; // Message-posting bottleneck.

@end


// -----------------------------------------------------------------------------
//  Globals:
// -----------------------------------------------------------------------------

static UKKQueue		*	gUKKQueueSharedQueueSingleton = nil;
static id				gUKKQueueSharedNotificationCenterProxy = nil;	// Object to which we send notifications so they get put in the main thread.


@implementation UKKQueue

// -----------------------------------------------------------------------------
//  sharedQueue:
//		Returns a singleton queue object. In many apps (especially those that
//      subscribe to the notifications) there will only be one kqueue instance,
//      and in that case you can use this.
//
//      For all other cases, feel free to create additional instances to use
//      independently.
//
//	REVISIONS:
//		2008-11-07	UK	Made this always notify, in case some nit sets a
//						delegate on the singleton.
//		2006-03-13	UK	Renamed from sharedQueue.
//      2005-07-02  UK  Created.
// -----------------------------------------------------------------------------

+(id) sharedFileWatcher
{
    @synchronized( self )
    {
        if( !gUKKQueueSharedQueueSingleton )
		{
            gUKKQueueSharedQueueSingleton = [[UKKQueue alloc] init];	// This is a singleton, and thus an intentional "leak".
			[gUKKQueueSharedQueueSingleton setAlwaysNotify: YES];
		}
    }
    
    return gUKKQueueSharedQueueSingleton;
}


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
		
		watchedPaths = [[NSMutableArray alloc] init];
		watchedFDs = [[NSMutableArray alloc] init];
		
		threadHasTerminated = YES;
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
	delegate = nil;
	[delegateProxy release];
	
	// Close all our file descriptors so the files can be deleted:
	[self removeAllPaths];
	
	[watchedPaths release];
	watchedPaths = nil;
	[watchedFDs release];
	watchedFDs = nil;
	
	[super dealloc];
    
    //NSLog(@"kqueue released.");
}


-(void)	finalize
{
	// Close all our file descriptors so the files can be deleted:
	[self removeAllPaths];
	
	[super finalize];
}


-(void)	invalidate
{
	@synchronized( self )
	{
		keepThreadRunning = NO;
	}
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

-(void)	unsubscribeAll
{
	[self removeAllPaths];
}

-(void)	removeAllPaths
{
	@synchronized( self )
    {
        NSEnumerator *  fdEnumerator = [watchedFDs objectEnumerator];
        NSNumber     *  anFD;
        
        while( (anFD = [fdEnumerator nextObject]) != nil )
            close( [anFD intValue] );

        [watchedFDs removeAllObjects];
        [watchedPaths removeAllObjects];
		
		[self invalidate];
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


// -----------------------------------------------------------------------------
//	addPathToQueue:
//		Tell this queue to listen for all interesting notifications sent for
//		the object at the specified path. If you want more control, use the
//		addPathToQueue:notifyingAbout: variant instead.
//
//	REVISIONS:
//		2004-03-13	UK	Documented.
// -----------------------------------------------------------------------------

-(void) addPath: (NSString*)path
{
	[self addPath: path notifyingAbout: UKKQueueNotifyAboutRename
										| UKKQueueNotifyAboutWrite
										| UKKQueueNotifyAboutDelete
										| UKKQueueNotifyAboutAttributeChange
										| UKKQueueNotifyAboutSizeIncrease
										| UKKQueueNotifyAboutLinkCountChanged
										| UKKQueueNotifyAboutAccessRevocation ];
}


// -----------------------------------------------------------------------------
//	addPath:notfyingAbout:
//		Tell this queue to listen for the specified notifications sent for
//		the object at the specified path.
//
//	NOTE:	This keeps track of each time you call it. If you subscribe twice,
//			you are expected to unsubscribe twice. This is necessary for the
//			singleton to be reasonably safe to use, because otherwise two
//			objects could subscribe for the same path, and when one of them
//			unsubscribes, it would unsubscribe both.
//
//	REVISIONS:
//		2008-11-07	UK	Renamed from addPathToQueue:notifyingAbout:
//      2005-06-29  UK  Files are now opened using O_EVTONLY instead of O_RDONLY
//                      which allows ejecting or deleting watched files/folders.
//                      Thanks to Phil Hargett for finding this flag in the docs.
//		2004-03-13	UK	Documented.
// -----------------------------------------------------------------------------

-(void) addPathToQueue: (NSString*)path notifyingAbout: (u_int)fflags
{
	[self addPath: path notifyingAbout: fflags];
}

-(void) addPath: (NSString*)path notifyingAbout: (u_int)fflags
{
	struct timespec		nullts = { 0, 0 };
	struct kevent		ev;
	int					fd = open( [path fileSystemRepresentation], O_EVTONLY, 0 );
	
    if( fd >= 0 )
    {
        EV_SET( &ev, fd, EVFILT_VNODE, 
				EV_ADD | EV_ENABLE | EV_CLEAR,
				fflags, 0, (void*)path );
		
        @synchronized( self )
        {
            [watchedPaths addObject: path];
            [watchedFDs addObject: [NSNumber numberWithInt: fd]];
            kevent( queueFD, &ev, 1, NULL, 0, &nullts );
		
			// Start new thread that fetches and processes our events:
			if( !keepThreadRunning )
			{
				while( !threadHasTerminated )
					usleep(10);
				
				keepThreadRunning = YES;
				threadHasTerminated = NO;
				[NSThread detachNewThreadSelector:@selector(watcherThread:) toTarget:self withObject:nil];
			}
        }
    }
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
    int		index = 0;
    int		fd = -1;
    
    @synchronized( self )
    {
        index = [watchedPaths indexOfObject: path];
        
        if( index == NSNotFound )
		    return;
        
        fd = [[watchedFDs objectAtIndex: index] intValue];
        
        [watchedFDs removeObjectAtIndex: index];
        [watchedPaths removeObjectAtIndex: index];
		
		if( [watchedPaths count] == 0 )
			[self invalidate];
    }
	
	if( close( fd ) == -1 )
        NSLog(@"removePathFromQueue: Couldn't close file descriptor (%d)", errno);
}


/*-(NSString*)	filePathForFileDescriptor:(const int)fd oldPath: (NSString*)oldPath
{
   struct stat fileStatus;
   struct stat currentFileStatus;
   
   // Get file status
   if( fstat(fd, &fileStatus) == -1 )
       return nil;
   
   NSString*		basePath = [oldPath stringByDeletingLastPathComponent];
   NSEnumerator *dirEnumerator;
   dirEnumerator = [[NSFileManager defaultManager] enumeratorAtPath: basePath];

   NSString *path;
   while( (path = [dirEnumerator nextObject]) )
   {
       NSString *fullPath = [basePath stringByAppendingPathComponent:path];
       if( stat([fullPath fileSystemRepresentation], &currentFileStatus) == 0 )
       {
           if ((currentFileStatus.st_dev == fileStatus.st_dev) &&
               (currentFileStatus.st_ino == fileStatus.st_ino))
           {
               // Found file
               return fullPath;
           }
       }
   }
   
   // Didn't find file
   return nil;
}*/


-(id)	delegate
{
    return delegate;
}

-(void)	setDelegate: (id)newDelegate
{
	id	oldProxy = delegateProxy;
	delegate = newDelegate;
	delegateProxy = [delegate copyMainThreadProxy];
	[delegateProxy setWaitForCompletion: NO];	// Better performance and avoid deadlocks.
	[oldProxy release];
}

// -----------------------------------------------------------------------------
//	Flag to send a notification even if we have a delegate:
// -----------------------------------------------------------------------------

-(BOOL)	alwaysNotify
{
	return alwaysNotify;
}


-(void)	setAlwaysNotify: (BOOL)n
{
	alwaysNotify = n;
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
	[mutStr appendFormat: @"watchedPaths = %@", [watchedPaths descriptionWithLocale: locale indent: level +1]];
	for( x = 0; x < level; x++ )
		[mutStr appendString: @"    "];
	[mutStr appendFormat: @"alwaysNotify = %@", (alwaysNotify? @"YES" : @"NO")];
	for( x = 0; x < level; x++ )
		[mutStr appendString: @"    "];
	[mutStr appendString: @"}"];
	
	return mutStr;
}

@end

@implementation UKKQueue (UKPrivateMethods)

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
	
	threadHasTerminated = NO;
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
						NSString*		fpath = [[(NSString *)ev.udata retain] autorelease];    // In case one of the notified folks removes the path.
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
	
	threadHasTerminated = YES;
   
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
	
	if( delegate && delegateProxy )
    {
		[delegateProxy watcher: self receivedNotification: nm forPath: fp];
    }
	
	if( !delegateProxy || alwaysNotify )
	{
		[gUKKQueueSharedNotificationCenterProxy postNotificationName: nm object: self
													userInfo: [NSDictionary dictionaryWithObjectsAndKeys: fp, @"path", nil]];	// The proxy sends the notification on the main thread.
	}
}

@end


