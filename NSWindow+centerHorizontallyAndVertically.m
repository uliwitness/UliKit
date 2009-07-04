//
//  NSWindow+centerHorizontallyAndVertically.m
//  TheBigRedButton
//
//  Created by Uli Kusterer on 20.08.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

#import "NSWindow+centerHorizontallyAndVertically.h"


@implementation NSWindow (UKCenterHorizontallyAndVertically)

-(void)	centerHorizontallyAndVertically
{
	[self center];
	NSRect		box = [self frame];
	NSRect		screenBox = [[self screen] visibleFrame];
	
	box.origin.y = screenBox.origin.y +truncf((screenBox.size.height -box.size.height) /2);
	box.origin.x = screenBox.origin.x +truncf((screenBox.size.width -box.size.width) /2);
	[self setFrame: box display: NO];
}

@end
