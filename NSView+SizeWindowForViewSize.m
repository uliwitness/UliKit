//
//  NSView+SizeWindowForViewSize.m
//  MovieTheatre
//
//  Created by Uli Kusterer on 25.06.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "NSView+SizeWindowForViewSize.h"


@implementation NSView (UKSizeWindowForViewSize)

-(void) sizeWindowForViewSize: (NSSize)sz
{
    NSRect      wdBox = [[self window] frame];
    
    wdBox.size = [self windowSizeForViewSize: sz];
    
    [[self window] setFrame: wdBox display: NO];
}

-(NSSize)   windowSizeForViewSize: (NSSize)sz
{
    NSRect      wdBox = NSZeroRect;
    NSRect      box = [self frame];
    NSRect      cvBox = [[[self window] contentView] frame];
    
    wdBox.size.width = sz.width + (cvBox.size.width -box.size.width);
    wdBox.size.height = sz.height + (cvBox.size.height -box.size.height);
	#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_3
    wdBox = [[self window] frameRectForContentRect: wdBox];
	#else
	wdBox = [NSWindow frameRectForContentRect: wdBox styleMask: [[self window] styleMask]];
	#endif
    
    return wdBox.size;
}

@end
