//
//	UKThreadMessenger.m
//	Shovel
//
//	Created 14.10.2004 by Uli Kusterer.
//	Copyright 2004 Uli Kusterer.
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
