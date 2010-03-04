//
//  NSViewViewIntersectingRect.m
//  UKDockableWindow
//
//  Created by Uli Kusterer on Wed Feb 04 2004.
//  Copyright (c) 2004 M. Uli Kusterer.
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
