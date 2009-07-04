//
//  NSStringDrawing+SizeWithRect.h
//  ScreencastBuddy
//
//  Created by Uli Kusterer on 01.09.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAttributedString (SizeWithRect)

-(NSSize)	sizeWithRect: (NSRect)box;

@end


@interface NSString (SizeWithRect)

-(NSSize)	sizeWithRect: (NSRect)box attributes: (NSDictionary*)attrs;

@end
