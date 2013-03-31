//
//  NSStringDrawing+SizeWithRect.m
//  ScreencastBuddy
//
//  Created by Uli Kusterer on 01.09.08.
//  Copyright 2008 Uli Kusterer.
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
	[layoutManager glyphRangeForTextContainer: textContainer]; // Cause re-layout.
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
	[layoutManager glyphRangeForTextContainer: textContainer]; // Cause re-layout.
	NSRect neededBox = [layoutManager usedRectForTextContainer: textContainer];

	[textStorage release];
	
	return neededBox.size;
}

@end
