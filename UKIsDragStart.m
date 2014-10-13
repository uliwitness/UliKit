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
		
		NSEvent*	currEvent = [NSApp nextEventMatchingMask: NSLeftMouseUpMask | NSRightMouseUpMask | NSOtherMouseUpMask
															| NSLeftMouseDraggedMask | NSRightMouseDraggedMask | NSOtherMouseDraggedMask
									untilDate: expireTime inMode: NSEventTrackingRunLoopMode dequeue: YES];
		if( currEvent )
		{
			switch( [currEvent type] )
			{
				case NSLeftMouseUp:
				case NSRightMouseUp:
				case NSOtherMouseUp:
				{
					[pool release];
					return UKIsDragStartMouseReleased;	// Mouse released within the wait time.
					break;
				}
				
				case NSLeftMouseDragged:
				case NSRightMouseDragged:
				case NSOtherMouseDragged:
				{
					NSPoint	newPos = [currEvent locationInWindow];
					CGFloat	xMouseMovement = fabs(newPos.x -startPos.x),
							yMouseMovement = abs(newPos.y -startPos.y);
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


