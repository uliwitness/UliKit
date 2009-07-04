//
//  UKClickableImageView.m
//  CocoaMoose
//
//  Created by Uli Kusterer on Wed Apr 14 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
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
