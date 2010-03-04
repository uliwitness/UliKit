//
//  NSOpenGLContext+DrawingExtensions.h
//  TheBigRedButton
//
//  Created by Uli Kusterer on 02.09.07.
//  Copyright 2007 M. Uli Kusterer.
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
