//
//  UKFNSubscribeFileWatcher.m
//  Filie
//
//  Created by Uli Kusterer on 03.02.05.
//  Copyright 2005 Uli Kusterer.
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

#import "UKFNSubscribeFileWatcher.h"
#import <Carbon/Carbon.h>


// -----------------------------------------------------------------------------
//  Private stuff:
// -----------------------------------------------------------------------------

@interface UKFNSubscribeFileWatcher (UKPrivateMethods)

-(void) sendDelegateMessage: (FNMessage)message forSubscription: (FNSubscriptionRef)subscription;

@end


// -----------------------------------------------------------------------------
//  Prototypes:
// -----------------------------------------------------------------------------

void    UKFileSubscriptionProc(FNMessage message, OptionBits flags, void *refcon, FNSubscriptionRef subscription);


@implementation UKFNSubscribeFileWatcher

// -----------------------------------------------------------------------------
//  sharedFileWatcher:
//		Singleton accessor.
// -----------------------------------------------------------------------------

+(id) sharedFileWatcher
{
	static UKFNSubscribeFileWatcher* sSharedFileWatcher = nil;
	
	@synchronized( self )
	{
		if( !sSharedFileWatcher )
			sSharedFileWatcher = [[UKFNSubscribeFileWatcher alloc] init];	// This is a singleton, and thus an intentional "leak".
    }
	
    return sSharedFileWatcher;
}


// -----------------------------------------------------------------------------
//  * CONSTRUCTOR:
// -----------------------------------------------------------------------------

-(id)   init
{
    self = [super init];
    if( !self ) 
        return nil;
    
    subscribedPaths = [[NSMutableArray alloc] init];
    subscribedObjects = [[NSMutableArray alloc] init];
    
    return self;
}


// -----------------------------------------------------------------------------
//  * DESTRUCTOR:
// -----------------------------------------------------------------------------

-(void) dealloc
{
    [self removeAllPaths];
    
    [subscribedPaths release];
	subscribedPaths = nil;
    [subscribedObjects release];
	subscribedObjects = nil;
	
    [super dealloc];
}


-(void) finalize
{
    [self removeAllPaths];

    [super finalize];
}

// -----------------------------------------------------------------------------
//  addPath:
//		Start watching the object at the specified path. This only sends write
//		notifications for all changes, as FNSubscribe doesn't tell what actually
//		changed about our folder.
// -----------------------------------------------------------------------------

-(void) addPath: (NSString*)path
{
	@synchronized( self )
	{
		OSStatus                    err = noErr;
		static FNSubscriptionUPP    subscriptionUPP = NULL;
		FNSubscriptionRef           subscription = NULL;
		
		if( !subscriptionUPP )
			subscriptionUPP = NewFNSubscriptionUPP( UKFileSubscriptionProc );
		
		err = FNSubscribeByPath( (UInt8*) [path fileSystemRepresentation], subscriptionUPP, (void*)self,
									kNilOptions, &subscription );
		if( err != noErr )
		{
			NSLog( @"UKFNSubscribeFileWatcher addPath: %@ failed due to error ID=%ld.", path, err );
			return;
		}
		
		[subscribedPaths addObject: path];
		[subscribedObjects addObject: [NSValue valueWithPointer: subscription]];
	}
}


// -----------------------------------------------------------------------------
//  removePath:
//		Stop watching the object at the specified path.
// -----------------------------------------------------------------------------

-(void) removePath: (NSString*)path
{
    NSValue*            subValue = nil;
    @synchronized( self )
    {
		NSInteger		idx = [subscribedPaths indexOfObject: path];
		if( idx != NSNotFound )
		{
			subValue = [[[subscribedObjects objectAtIndex: idx] retain] autorelease];
			[subscribedPaths removeObjectAtIndex: idx];
			[subscribedObjects removeObjectAtIndex: idx];
		}
   }
    
	if( subValue )
	{
		FNSubscriptionRef   subscription = [subValue pointerValue];
		
		FNUnsubscribe( subscription );
	}
}


// -----------------------------------------------------------------------------
//  delegate:
//		Accessor for file watcher delegate.
// -----------------------------------------------------------------------------

-(id)   delegate
{
    return delegate;
}


// -----------------------------------------------------------------------------
//  setDelegate:
//		Mutator for file watcher delegate.
// -----------------------------------------------------------------------------

-(void) setDelegate: (id)newDelegate
{
    delegate = newDelegate;
}


-(void)	removeAllPaths
{
    @synchronized( self )
    {
		NSEnumerator*	enny = [subscribedObjects objectEnumerator];
		NSValue*        subValue = nil;
	
        while(( subValue = [enny nextObject] ))
		{
			FNSubscriptionRef   subscription = [subValue pointerValue];
			FNUnsubscribe( subscription );
		}
		
		[subscribedPaths removeAllObjects];
 		[subscribedObjects removeAllObjects];
   }
}

@end

@implementation UKFNSubscribeFileWatcher (UKPrivateMethods)

// -----------------------------------------------------------------------------
//  sendDelegateMessage:forSubscription:
//		Bottleneck for change notifications. This is called by our callback
//		function to actually inform the delegate and send out notifications.
//
//		This *only* sends out write notifications, as FNSubscribe doesn't tell
//		what changed about our folder.
// -----------------------------------------------------------------------------

-(void) sendDelegateMessage: (FNMessage)message forSubscription: (FNSubscriptionRef)subscription
{
    NSValue*                    subValue = [NSValue valueWithPointer: subscription];
	NSInteger						idx = [subscribedObjects indexOfObject: subValue];
	if( idx == NSNotFound )
	{
		NSLog( @"Notification for unknown subscription." );
		return;
	}
    NSString*                   path = [subscribedPaths objectAtIndex: idx];
    
	[[[NSWorkspace sharedWorkspace] notificationCenter] postNotificationName: UKFileWatcherWriteNotification
															object: self
															userInfo: [NSDictionary dictionaryWithObjectsAndKeys: path, @"path", nil]];
	
    [delegate watcher: self receivedNotification: UKFileWatcherWriteNotification forPath: path];
    //NSLog( @"UKFNSubscribeFileWatcher noticed change to %@", path );	// DEBUG ONLY!
}

@end



// -----------------------------------------------------------------------------
//  UKFileSubscriptionProc:
//		Callback function we hand to Carbon so it can tell us when something
//		changed about our watched folders. We set the refcon to a pointer to
//		our object. This simply extracts the object and hands the info off to
//		sendDelegateMessage:forSubscription: which does the actual work.
// -----------------------------------------------------------------------------

void    UKFileSubscriptionProc( FNMessage message, OptionBits flags, void *refcon, FNSubscriptionRef subscription )
{
    UKFNSubscribeFileWatcher*   obj = (UKFNSubscribeFileWatcher*) refcon;
    
    if( message == kFNDirectoryModifiedMessage )    // No others exist as of 10.4
        [obj sendDelegateMessage: message forSubscription: subscription];
    else
        NSLog( @"UKFileSubscriptionProc: Unknown message %d", message );
}