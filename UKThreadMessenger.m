/* =============================================================================
	FILE:		UKThreadMessenger.m
	PROJECT:	Shovel
    
    COPYRIGHT:  (c) 2004 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   GPL, Modified BSD

	REVISIONS:
		2004-10-14	UK	Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import "UKThreadMessenger.h"
#include <unistd.h>


@implementation UKThreadMessenger

-(id)	initWithTarget: (id)trg newestFirst: (BOOL)nwf
{
	self = [super init];
	
	if( self )
	{
		messages = [[NSMutableArray alloc] init];
        target = trg;
        newestFirst = nwf;
        [NSThread detachNewThreadSelector: @selector(sendMessages:) toTarget: self withObject: nil];
	}
	
	return self;
}

-(void)	dealloc
{
	[messages release];
	[super dealloc];
    
    //NSLog(@"thread messenger released.");
}

// -----------------------------------------------------------------------------
//	release:
//		Since NSThread retains its target, we need this method to terminate the
//      thread when we reach a retain-count of two.
//
//	REVISIONS:
//		2004-11-12	UK	Created.
// -----------------------------------------------------------------------------

-(void) release
{
    if( [self retainCount] == 2 && threadRunning )
        threadRunning = NO;
    
    [super release];
}

-(void)	sendMessages: (id)sender
{
    threadRunning = YES;
    
    [NSThread setThreadPriority: 0.3];  // Lower this thread's priority.
    
	while( threadRunning )
    {
        while( threadRunning && (!messages || [messages count] <= 0) )
        {
            usleep(1000);
        }
        
        NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
        NSArray*    msgs = nil;
        
        @synchronized( self )
        {
            msgs = [messages autorelease];
            messages = [[NSMutableArray alloc] init];
        }
        
        NSEnumerator*   enny;
        if( newestFirst )
            enny = [msgs reverseObjectEnumerator];
        else
            enny = [msgs objectEnumerator];
        NSInvocation*   inv;
        while( (inv = [enny nextObject]) )
        {
            NSAutoreleasePool*  pool2 = [[NSAutoreleasePool alloc] init];
            [inv invoke];
            [pool2 release];
            //usleep(1);
        }
        [pool release];
    }
    
    //NSLog(@"sendMessages terminated.");
}


-(id)	performSelector: (SEL)itemAction withObject: (id)obj
{
	BOOL	does = [super respondsToSelector: itemAction];
	if( does )
		return [super performSelector: itemAction withObject: obj];
	
	if( ![target respondsToSelector: itemAction] )
		[self doesNotRecognizeSelector: itemAction];
	
	NSInvocation*   inv = [NSInvocation invocationWithMethodSignature: [target methodSignatureForSelector: @selector(itemAction)]];
	
    [inv setSelector: itemAction];
    [inv setTarget: target];
    [inv retainArguments];
    
    @synchronized( self )
    {
        [messages addObject: inv];
    }
    
	return nil;
}

-(BOOL)	respondsToSelector: (SEL)itemAction
{
	BOOL	does = [super respondsToSelector: itemAction];
	
	return( does || [target respondsToSelector: itemAction] );
}


// -----------------------------------------------------------------------------
//	Forwarding unknown methods to the first responder:
// -----------------------------------------------------------------------------

-(NSMethodSignature*)	methodSignatureForSelector: (SEL)itemAction
{
	NSMethodSignature*	sig = [super methodSignatureForSelector: itemAction];

	if( sig )
		return sig;
	
	return [target methodSignatureForSelector: itemAction];
	
	return nil;
}

-(void)	forwardInvocation: (NSInvocation*)invocation
{
    SEL             itemAction = [invocation selector];
    NSInvocation*   inv;

    if( [target respondsToSelector: itemAction] )
	{
        inv = invocation;
		[inv setTarget: target];
        [inv retainArguments];
        @synchronized( self )
        {
            [messages addObject: inv];
        }
	}
    else
        [self doesNotRecognizeSelector: itemAction];
}



@end
