//
//  NSViewViewIntersectingRect.m
//  UKDockableWindow
//
//  Created by Uli Kusterer on Wed Feb 04 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSViewViewIntersectingRect.h"


@implementation NSView (ViewIntersectingRect)

-(NSView*)  subviewIntersectingRect: (NSRect)box ignoring: (NSView*)ignoreme
{
	NSEnumerator*   enny = [[self subviews] objectEnumerator];
	NSView*			theView;
	BOOL			canHideViews = [NSView instancesRespondToSelector: @selector(isHidden)];
	
	while( theView = [enny nextObject] )
	{
		if( canHideViews && [theView isHidden] )
			continue;
		
		if( theView == ignoreme )
			continue;
		
		NSRect  otherBox = [theView frame];
		
		if( NSIntersectsRect( box, otherBox ) )
			return theView;
	}
	
	return nil;
}

-(NSSize)   subviewsCombinedSize
{
	NSSize			size = { 0, 0 };
	NSEnumerator*   enny = [[self subviews] objectEnumerator];
	NSView*			theView;
	
	while( theView = [enny nextObject] )
	{
		if( [theView isHidden] )
			continue;
		
		NSRect  otherBox = [theView frame];
		
		if( (otherBox.origin.x +otherBox.size.width) > size.width )
			size.width = otherBox.origin.x +otherBox.size.width;
		if( (otherBox.origin.y +otherBox.size.height) > size.height )
			size.height = otherBox.origin.y +otherBox.size.height;
	}
	
	return size;
}

@end
