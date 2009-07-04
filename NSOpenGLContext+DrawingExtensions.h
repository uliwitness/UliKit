//
//  NSOpenGLContext+DrawingExtensions.h
//  TheBigRedButton
//
//  Created by Uli Kusterer on 02.09.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// This is our equivalent to NSPoint:
typedef struct _UK3DPoint
{
	float		x;		// Horizontal.
	float		y;		// Vertical.
	float		z;		// Depth.
} UK3DPoint;


// Quads are four-sided polygons. Since we're talking
//	3D, "top", "left", "bottom" and "right" don't make
//	much sense, but the drawing order is the same, so
//	all points are connected to their predecessors, and
//	in addition to that, A is connected to D.
typedef struct _UK3DQuad
{
	UK3DPoint		a;
	UK3DPoint		b;
	UK3DPoint		c;
	UK3DPoint		d;
} UK3DQuad;


@interface NSOpenGLContext (UKDrawingExtensions)

-(void)		fillQuad: (UK3DQuad)quad;
-(void)		fillQuadReflection: (UK3DQuad)quad;
-(void)		fillQuadShadow: (UK3DQuad)quad;

@end
