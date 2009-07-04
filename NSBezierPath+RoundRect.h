//
//  NSBezierPathRoundRects.h
//  UKDockableWindow
//
//  Created by Uli Kusterer on Wed Feb 04 2004.
//  Based on code by John C. Randolph.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (RoundRects)

+(void)				fillRoundRectInRect:(NSRect)rect radius:(float) radius;
+(void)				strokeRoundRectInRect:(NSRect)rect radius:(float) radius;

+(NSBezierPath*)	bezierPathWithRoundRectInRect:(NSRect)rect radius:(float) radius;

@end

// Some nifty utility functions this uses:
NSPoint  UKCenterOfRect( NSRect rect );
NSPoint  UKTopCenterOfRect( NSRect rect );
NSPoint  UKTopLeftOfRect( NSRect rect );
NSPoint  UKTopRightOfRect( NSRect rect );
NSPoint  UKLeftCenterOfRect( NSRect rect );
NSPoint  UKBottomCenterOfRect( NSRect rect );
NSPoint  UKBottomLeftOfRect( NSRect rect );
NSPoint  UKBottomRightOfRect( NSRect rect );
NSPoint  UKRightCenterOfRect( NSRect rect );