//
//  NSBezierPathRoundRects.m
//  UKDockableWindow
//
//  Created by Uli Kusterer on Wed Feb 04 2004.
//  Based on code by John C. Randolph.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSBezierPath+RoundRect.h"


@implementation NSBezierPath (RoundRects)

+(void)		fillRoundRectInRect:(NSRect)rect radius:(float) radius
{
	NSBezierPath*   p = [self bezierPathWithRoundRectInRect: rect radius: radius];
	[p fill];
}


+(void)		strokeRoundRectInRect:(NSRect)rect radius:(float) radius
{
	NSBezierPath*   p = [self bezierPathWithRoundRectInRect: rect radius: radius];
	[p stroke];
}



// -----------------------------------------------------------------------------
//	bezierPathWithRoundRectInRect:radius:
//		This method adds the traditional Macintosh rounded-rectangle to
//		NSBezierPath's repertoire.
//
//	REVISIONS:
//		2004-02-04	witness	Created.
// -----------------------------------------------------------------------------

+(NSBezierPath*)	bezierPathWithRoundRectInRect:(NSRect)rect radius:(float) radius
{
	// Make sure radius doesn't exceed a maximum size to avoid artifacts:
	if( radius >= (rect.size.height /2) )
		radius = truncf(rect.size.height /2) -1;
	if( radius >= (rect.size.width /2) )
		radius = truncf(rect.size.width /2) -1;
	
	// Make sure silly values simply lead to un-rounded corners:
	if( radius <= 0 )
		return [self bezierPathWithRect: rect];
	
	// Now draw our rectangle:
	NSRect			innerRect = NSInsetRect( rect, radius, radius );	// Make rect with corners being centers of the corner circles.
	NSBezierPath	*path = [self bezierPath];

	[path moveToPoint: NSMakePoint(rect.origin.x,rect.origin.y +radius)];

	// Bottom left (origin):
	[path appendBezierPathWithArcWithCenter: UKBottomLeftOfRect(innerRect)
							radius: radius startAngle: 180.0 endAngle: 270.0 ];
	[path relativeLineToPoint: NSMakePoint(NSWidth(innerRect), 0.0) ];		// Bottom edge.

	// Bottom right:
	[path appendBezierPathWithArcWithCenter: UKBottomRightOfRect(innerRect)
							radius: radius startAngle: 270.0 endAngle: 360.0 ];
	[path relativeLineToPoint: NSMakePoint(0.0, NSHeight(innerRect)) ];		// Right edge.

	// Top right:
	[path appendBezierPathWithArcWithCenter: UKTopRightOfRect(innerRect)  
							radius: radius startAngle: 0.0  endAngle: 90.0 ];
	[path relativeLineToPoint: NSMakePoint( -NSWidth(innerRect), 0.0) ];	// Top edge.

	// Top left:
	[path appendBezierPathWithArcWithCenter: UKTopLeftOfRect(innerRect)
							radius: radius startAngle: 90.0  endAngle: 180.0 ];

	[path closePath];   // Implicitly causes left edge.

	return path;
}


NSPoint  UKCenterOfRect( NSRect rect )
{
	return NSMakePoint( NSMidX(rect), NSMidY(rect) );
}

NSPoint  UKTopCenterOfRect( NSRect rect )
{
	return NSMakePoint( NSMidX(rect), NSMaxY(rect) );
}

NSPoint  UKTopLeftOfRect( NSRect rect )
{
	return NSMakePoint( NSMinX(rect),NSMaxY(rect) );
}

NSPoint  UKTopRightOfRect( NSRect rect )
{
	return NSMakePoint( NSMaxX(rect), NSMaxY(rect) );
}

NSPoint  UKLeftCenterOfRect( NSRect rect )
{
	return NSMakePoint( NSMinX(rect), NSMidY(rect) );
}

NSPoint  UKBottomCenterOfRect( NSRect rect )
{
	return NSMakePoint( NSMidX(rect), NSMinY(rect) );
}

NSPoint  UKBottomLeftOfRect( NSRect rect )
{
	return rect.origin;
}

NSPoint  UKBottomRightOfRect( NSRect rect )
{
	return NSMakePoint( NSMaxX(rect), NSMinY(rect) );
}

NSPoint  UKRightCenterOfRect( NSRect rect )
{
	return NSMakePoint( NSMaxX(rect), NSMidY(rect) );
}
 

@end
