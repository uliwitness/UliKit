//
//  NSView+SetFrameSizePinnedToTopLeft.m
//  AngelTemplate
//
//  Created by Uli Kusterer on 14.10.06.
//  Copyright 2006 M. Uli Kusterer. All rights reserved.
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
