//
//	UKMainThreadProxy.m
//	UKMainThreadProxy
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

#import "UKMainThreadProxy.h"


@implementation UKMainThreadProxy

-(id)	initWithTarget: (id)targ
{
	self = [super init];
	if( self )
	{
		target = targ;
		waitForCompletion = YES;
	}
	
	return self;
}


-(void)	setWaitForCompletion: (BOOL)state
{
	waitForCompletion = state;
}


// -----------------------------------------------------------------------------
//	Introspection overrides:
// -----------------------------------------------------------------------------

-(BOOL)	respondsToSelector: (SEL)itemAction
{
	BOOL	does = [super respondsToSelector: itemAction];
	
	return( does || [target respondsToSelector: itemAction] );
}


-(id)	performSelector: (SEL)itemAction
{
	BOOL	does = [super respondsToSelector: itemAction];
	if( does )
		return [super performSelector: itemAction];
	
	if( ![target respondsToSelector: itemAction] )
		[self doesNotRecognizeSelector: itemAction];
	
	[target retain];
	[target performSelectorOnMainThread: itemAction withObject: nil waitUntilDone: waitForCompletion];
	[target release];
	
	return nil;
}


-(id)	performSelector: (SEL)itemAction withObject: (id)obj
{
	BOOL	does = [super respondsToSelector: itemAction];
	if( does )
		return [super performSelector: itemAction withObject: obj];
	
	if( ![target respondsToSelector: itemAction] )
		[self doesNotRecognizeSelector: itemAction];
	
	[target retain];
	[obj retain];
	[target performSelectorOnMainThread: itemAction withObject: obj waitUntilDone: waitForCompletion];
	[obj release];
	[target release];
	
	return nil;
}

// -----------------------------------------------------------------------------
//	Forwarding unknown methods to the target:
// -----------------------------------------------------------------------------

-(NSMethodSignature*)	methodSignatureForSelector: (SEL)itemAction
{
	NSMethodSignature*	sig = [super methodSignatureForSelector: itemAction];

	if( sig )
		return sig;
	
	return [target methodSignatureForSelector: itemAction];
}

-(void)	forwardInvocation: (NSInvocation*)invocation
{
    SEL itemAction = [invocation selector];

    if( [target respondsToSelector: itemAction] )
	{
		[invocation retainArguments];
		[target retain];
		[invocation performSelectorOnMainThread: @selector(invokeWithTarget:) withObject: target waitUntilDone: waitForCompletion];
		[target release];
	}
	else
        [self doesNotRecognizeSelector: itemAction];
}


// -----------------------------------------------------------------------------
//	Safety net:
// -----------------------------------------------------------------------------

-(id)	mainThreadProxy     // Just in case someone accidentally sends this message to a main thread proxy.
{
	return self;
}

-(id)	copyMainThreadProxy	// Just in case someone accidentally sends this message to a main thread proxy.
{
	return [self retain];
}

@end


// -----------------------------------------------------------------------------
//	Shorthand notation for getting a main thread proxy:
// -----------------------------------------------------------------------------

@implementation NSObject (UKMainThreadProxy)

-(id)	mainThreadProxy
{
	return [[[UKMainThreadProxy alloc] initWithTarget: self] autorelease];
}

-(id)	copyMainThreadProxy
{
	return [[UKMainThreadProxy alloc] initWithTarget: self];
}

@end

