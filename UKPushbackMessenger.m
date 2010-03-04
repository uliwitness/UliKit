//
//	UKPushbackMessenger.m
//	Shovel
//
//	Created by Uli Kusterer on 14.10.2004.
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

#import "UKPushbackMessenger.h"


@implementation UKPushbackMessenger

-(id)	init
{
    self = [self initWithTarget: nil];
    return self;
}


-(id)   initWithTarget: (id)targ;
{
	self = [super init];
	
	if( self )
	{
		delay = 1.0;
		timers = [[NSMutableDictionary alloc] init];
		pushes = [[NSMutableDictionary alloc] init];
        target = targ;
	}
	
	return self;
}

-(void)	dealloc
{
	NSEnumerator*	enny = [timers objectEnumerator];
	NSTimer*		currT;
	
	while( (currT = [enny nextObject]) )
	{
		[currT invalidate];
	}
	
	[timers release];
	[pushes release];
	[super dealloc];
}

-(void)	doTimer: (NSTimer*)t
{
	[target performSelector: [[[t userInfo] objectForKey: @"selector"] pointerValue] withObject: [[t userInfo] objectForKey: @"object"]];
	NSArray*	arr = [timers allKeysForObject: t];
	[timers removeObjectForKey: [arr objectAtIndex: 0]];
	[pushes removeObjectForKey: [arr objectAtIndex: 0]];
}


-(void) setDelay: (NSTimeInterval)n
{
    delay = n;
}


-(void) setMaxPushTime: (NSTimeInterval)n
{
    maxPushTime = n;
}


-(id)	performSelector: (SEL)itemAction withObject: (id)obj
{
    NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	BOOL                does = [super respondsToSelector: itemAction];
	if( does )
    {
		[pool release];
        return [super performSelector: itemAction withObject: obj];
    }
	
	if( ![target respondsToSelector: itemAction] )
		[self doesNotRecognizeSelector: itemAction];
	
	NSString*       selStr = NSStringFromSelector(itemAction);
	NSTimer*        timer = [timers objectForKey: selStr];
    NSTimeInterval  currTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval  lastTime = currTime;
    
	if( timer )
	{
        lastTime = [[pushes objectForKey: selStr] doubleValue];
        if( maxPushTime == 0 || (currTime -lastTime) <= maxPushTime )
            [timer invalidate]; // Push back our timer.
		[timers removeObjectForKey: selStr];
	}
	[timers setObject: [NSTimer scheduledTimerWithTimeInterval: delay
							target: self selector:@selector(doTimer:)
							userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
									[NSValue valueWithPointer: itemAction], @"selector",
									obj, @"object",
									nil]
							repeats: NO]
				forKey: selStr];
    [pushes setObject: [NSNumber numberWithDouble: lastTime] forKey: selStr];
	
    [pool release];
    
	return nil;
}

-(BOOL)	respondsToSelector: (SEL)itemAction
{
	BOOL	does = [super respondsToSelector: itemAction];
	
	return( does || [target respondsToSelector: itemAction] );
}


// -----------------------------------------------------------------------------
//	Forwarding unknown methods:
// -----------------------------------------------------------------------------

-(NSMethodSignature*)	methodSignatureForSelector: (SEL)itemAction
{
    BOOL                does = [super respondsToSelector: itemAction];
	NSMethodSignature*	sig = does? [super methodSignatureForSelector: itemAction] : nil;

	if( sig )
		return sig;
	
    if( [target respondsToSelector: itemAction] )
        return [target methodSignatureForSelector: itemAction];
    else
        return nil;
}

-(void)	forwardInvocation: (NSInvocation*)invocation
{
    NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
    SEL                 itemAction = [invocation selector];

    if( [target respondsToSelector: itemAction] )
	{
		NSString*       selStr = NSStringFromSelector(itemAction);
		NSTimer*        timer = [timers objectForKey: selStr];
        NSTimeInterval  lastTime = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval  currTime = lastTime;
        
		if( timer )
		{
            lastTime = [[pushes objectForKey: selStr] doubleValue];
            if( maxPushTime == 0 || (currTime -lastTime) <= maxPushTime )
                [timer invalidate];
			[timers removeObjectForKey: selStr];
		}
		[invocation setTarget: target];
		[timers setObject: [NSTimer scheduledTimerWithTimeInterval: delay
								invocation: invocation repeats: NO]
				forKey: selStr];
        [pushes setObject: [NSNumber numberWithDouble: lastTime] forKey: selStr];
	}
    else
        [self doesNotRecognizeSelector: itemAction];
    
    [pool release];
}



@end
