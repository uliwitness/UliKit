//
//  UKIdleTimer.m
//  CocoaMoose
//
//  Created by Uli Kusterer on Tue Apr 06 2004.
//  Copyright (c) 2004 Uli Kusterer.
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


#import "UKIdleTimer.h"
#import "UKHelperMacros.h"


@interface UKIdleTimer ()
{
	NSTimer			*actualTimer;
	NSTimeInterval	idleInterval;
	BOOL			isIdle;
	NSTimeInterval	lastFireTime;
	
	id				delegate;
}

@end


@implementation UKIdleTimer

-(id)   initWithTimeInterval: (NSTimeInterval)interval
{
	self = [super init];
	if( !self )
		return nil;
	
	idleInterval = interval;
	
	actualTimer = [[NSTimer scheduledTimerWithTimeInterval: 1.0 repeats: YES block: ^(NSTimer * _Nonnull timer) {
		[self checkIdleTime];
	}] retain];
	
	return self;
}

-(void) dealloc
{
	[actualTimer invalidate];
	[actualTimer release];
	
	[super dealloc];
}


-(void) checkIdleTime
{
	NSTimeInterval	currentTime = NSDate.timeIntervalSinceReferenceDate;
	NSTimeInterval	timeSinceLastFire = currentTime - lastFireTime;
	
	if (timeSinceLastFire < idleInterval ) {
		actualTimer.fireDate = [NSDate dateWithTimeIntervalSinceReferenceDate: lastFireTime + idleInterval];
		UKLog(@"Timer difference is %f, firing next at %@", timeSinceLastFire, actualTimer.fireDate);
		return;
	}
	
	lastFireTime = currentTime;
	BOOL areStillIdle = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateCombinedSessionState, kCGAnyInputEventType) > self->idleInterval;
	if ( areStillIdle && timeSinceLastFire >= idleInterval ) {
		if (isIdle) {
			UKLog(@"Continues idling... (%f)", timeSinceLastFire);
			[self timerContinuesIdling: nil];
		} else {
			UKLog(@"Begins idling... (%f)", timeSinceLastFire);
			[self timerBeginsIdling: nil];
			isIdle = YES;
		}
	} else if (!areStillIdle && isIdle) {
		UKLog(@"Finished idling... (%f)", timeSinceLastFire);
		[self timerFinishedIdling: nil];
		isIdle = NO;
	} else {
		UKLog(@"Waiting to idle again... (%f)", timeSinceLastFire);
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


-(void) timerBeginsIdling: (id)sender
{
	if( [delegate respondsToSelector: @selector(timerBeginsIdling:)] )
		[delegate timerBeginsIdling: self];
}


-(void) timerContinuesIdling: (id)sender
{
	if( [delegate respondsToSelector: @selector(timerContinuesIdling:)] )
		[delegate timerContinuesIdling: self];
}


-(void) timerFinishedIdling: (id)sender
{
	if( [delegate respondsToSelector: @selector(timerFinishedIdling:)] )
		[delegate timerFinishedIdling: self];
}

@end
