//
//  UKIsDragStart.m
//  Propaganda
//
//  Created by Uli Kusterer on 01.05.10.
//  Copyright 2010 Uli Kusterer. All rights reserved.
//

#import "UKIsDragStart.h"

#import <iso646.h>


UKIsDragStartResult	UKIsDragStart( NSEvent *startEvent, NSTimeInterval theTimeout )
{
	if( theTimeout == 0.0 )
		theTimeout = 1.5;
	
	NSPoint			startPos = [startEvent locationInWindow];
	NSTimeInterval	startTime = [NSDate timeIntervalSinceReferenceDate];
	NSDate*			expireTime = [NSDate dateWithTimeIntervalSinceReferenceDate: startTime +theTimeout];
	
	NSAutoreleasePool	*pool = nil;
	while( ([expireTime timeIntervalSinceReferenceDate] -[NSDate timeIntervalSinceReferenceDate]) > 0 )
	{
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];
		
		NSEvent*	currEvent = [NSApp nextEventMatchingMask: NSEventMaskLeftMouseUp | NSEventMaskRightMouseUp | NSEventMaskOtherMouseUp
															| NSEventMaskLeftMouseDragged | NSEventMaskRightMouseDragged | NSEventMaskOtherMouseDragged
									untilDate: expireTime inMode: NSEventTrackingRunLoopMode dequeue: YES];
		if( currEvent )
		{
			switch( [currEvent type] )
			{
				case NSEventTypeLeftMouseUp:
				case NSEventTypeRightMouseUp:
				case NSEventTypeOtherMouseUp:
				{
					[pool release];
					return UKIsDragStartMouseReleased;	// Mouse released within the wait time.
					break;
				}
				
				case NSEventTypeLeftMouseDragged:
				case NSEventTypeRightMouseDragged:
				case NSEventTypeOtherMouseDragged:
				{
					NSPoint	newPos = [currEvent locationInWindow];
					CGFloat	xMouseMovement = fabs(newPos.x -startPos.x),
							yMouseMovement = fabs(newPos.y -startPos.y);
					if( xMouseMovement > 2 or yMouseMovement > 2 )
					{
						[pool release];
						return (xMouseMovement > yMouseMovement) ? UKIsDragStartMouseMovedHorizontally : UKIsDragStartMouseMovedVertically;	// Mouse moved within the wait time, probably a drag!
					}
					break;
				}
				
				default:
					break;
			}
		}
		
	}
	
	[pool release];
	return UKIsDragStartTimedOut;	// If they held the mouse that long, they probably wanna drag.
}


