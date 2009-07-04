//
//  NSStringDrawing+SizeWithRect.m
//  ScreencastBuddy
//
//  Created by Uli Kusterer on 01.09.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import "NSStringDrawing+SizeWithRect.h"


@implementation NSAttributedString (SizeWithRect)

-(NSSize)	sizeWithRect: (NSRect)box
{
	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString: self];
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
	NSTextContainer *textContainer = [[NSTextContainer alloc] init];
	[layoutManager addTextContainer:textContainer];
	[textContainer release];
	[textStorage addLayoutManager:layoutManager];
	[layoutManager release];

	[textContainer setContainerSize: NSMakeSize(box.size.width, FLT_MAX)];
	(NSRange) [layoutManager glyphRangeForTextContainer: textContainer]; // Cause re-layout.
	NSRect neededBox = [layoutManager usedRectForTextContainer: textContainer];

	[textStorage release];
	
	return neededBox.size;
}

@end


@implementation NSString (SizeWithRect)

-(NSSize)	sizeWithRect: (NSRect)box attributes: (NSDictionary*)attrs
{
	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString: self attributes: attrs];
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
	NSTextContainer *textContainer = [[NSTextContainer alloc] init];
	[layoutManager addTextContainer:textContainer];
	[textContainer release];
	[textStorage addLayoutManager:layoutManager];
	[layoutManager release];

	[textContainer setContainerSize: NSMakeSize(box.size.width, FLT_MAX)];
	(NSRange) [layoutManager glyphRangeForTextContainer: textContainer]; // Cause re-layout.
	NSRect neededBox = [layoutManager usedRectForTextContainer: textContainer];

	[textStorage release];
	
	return neededBox.size;
}

@end
