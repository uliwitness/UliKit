//
//  NSView+SizeWindowForViewSize.m
//  MovieTheatre
//
//  Created by Uli Kusterer on 25.06.05.
//  Copyright 2005 Uli Kusterer.
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
