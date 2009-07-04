//
//  NSApplicationWindowAtPoint.m
//  UKDockableWindow
//
//  Created by Uli Kusterer on Wed Feb 04 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSApplicationWindowAtPoint.h"


@implementation NSApplication (WindowAtPoint)

-(NSWindow*)	windowAtPoint: (NSPoint)pos ignoreWindow: (NSWindow*)ignorew
{
	NSArray*		winArray = [self windows];
	NSEnumerator*   enny = [winArray objectEnumerator];
	NSWindow*		theWin = nil;
	
	while( theWin = [enny nextObject] )
	{
		if( theWin == ignorew )		// Skip the window to ignore.
			continue;
		
		if( ![theWin isVisible] )   // Skip invisible windows.
			continue;
		
		if( NSPointInRect( pos, [theWin frame] ) )
			return theWin;
	}
	
	return nil;
}

@end
