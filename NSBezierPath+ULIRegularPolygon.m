//
//  NSBezierPath+ULIRegularPolygon.m
//  Stacksmith
//
//  Created by Uli Kusterer on 30.04.11.
//  Copyright 2011 Uli Kusterer. All rights reserved.
//

#import "NSBezierPath+ULIRegularPolygon.h"


@implementation NSBezierPath (ULIRegularPolygon)

-(void)	appendRegularPolygonAroundPoint: (NSPoint)centre startPoint: (NSPoint)startCorner cornerCount: (NSInteger)numCorners
{
	NSAssert( (numCorners >= 3), @"Too few corners on polygon." );
	
	// To draw a regular polygon, you simply calculate as many evenly-spaced
	//	points on a circle as you need corners, then connect them with lines.
	
	CGFloat		xDiff = fabs(startCorner.x -centre.x);
	CGFloat		yDiff = fabs(startCorner.y -centre.y);
	CGFloat		radius = sqrt( xDiff * xDiff + yDiff * yDiff );	// Pythagoras xDiff^2 + yDiff^2 = distance as the bird flies.
	
	if( xDiff <= 0 )	// Don't divide by zero, don't do work if there's nothing to draw.
		return;
	
	CGFloat		degrees = (xDiff == 0) ? 0 : ((yDiff == 0) ? 0.5 * M_PI : yDiff / xDiff);	// Calc angle at which centre & startCorner are, so we know at what angle to put the first point.
	CGFloat		stepSize = (2.0 * M_PI) / ((CGFloat)numCorners);
	
	// Draw first corner at start angle:
	NSPoint		firstCorner = NSZeroPoint;
	firstCorner.x = centre.x +radius * cos( degrees );
	firstCorner.y = centre.y +radius * sin( degrees );
	[self moveToPoint: firstCorner];
	
	// Now draw following corners:
	for( NSInteger x = 0; x < numCorners; x++ )
	{
		NSPoint		currCorner = NSZeroPoint;
		degrees += stepSize;
		if( degrees > (2.0 * M_PI) )
			degrees -= (2.0 * M_PI);
		currCorner.x = centre.x +radius * cos( degrees );
		currCorner.y = centre.y +radius * sin( degrees );
		
		[self lineToPoint: currCorner];	// Draw edge from prev to curr corner.
	}
	
	// Now close the shape by drawing final edge:
	[self lineToPoint: firstCorner];
}

@end
