//
//  UKClickableImageView.m
//  CocoaMoose
//
//  Created by Uli Kusterer on Wed Apr 14 2004.
//  Copyright (c) 2004 Uli Kusterer.
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

#import "UKClickableImageView.h"


@implementation UKClickableImageView

-(void)	dealloc
{
	[cursor release];
	cursor = nil;
	
	[super dealloc];
}

-(void) mouseDown: (NSEvent*)evt
{
	[[self target] performSelector: [self action] withObject: self];
}

-(void) mouseUp: (NSEvent*)evt
{
	
}

-(BOOL) acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

-(void)	resetCursorRects
{
	if( cursor )
		[self addCursorRect: [self bounds] cursor: cursor];
}


-(void)	setCursor: (NSCursor*)theCursor
{
	[theCursor retain];
	[cursor release];
	cursor = theCursor;
}

-(NSCursor*)	cursor
{
	return cursor;
}

@end
