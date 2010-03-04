//
//  NSView+SetFrameSizePinnedToTopLeft.m
//  AngelTemplate
//
//  Created by Uli Kusterer on 14.10.06.
//  Copyright 2006 M. Uli Kusterer.
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

#import "NSView+SetFrameSizePinnedToTopLeft.h"


@implementation NSView (UKSetFrameSizePinnedToTopLeft)

-(void)	setFrameSizePinnedToTopLeft: (NSSize)siz
{
	NSRect		theBox = [self frame];
	NSPoint		topLeft = theBox.origin;
	topLeft.y += theBox.size.height;

	[[self superview] setNeedsDisplayInRect: theBox];	// Inval old box.
	
	theBox.size = siz;
	topLeft.y -= siz.height;
	theBox.origin = topLeft;
	[self setFrame: theBox];
	[self setNeedsDisplay: YES];
}

@end
