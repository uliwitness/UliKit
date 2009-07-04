//
//  NSViewViewIntersectingRect.h
//  UKDockableWindow
//
//  Created by Uli Kusterer on Wed Feb 04 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSView (ViewIntersectingRect)

-(NSView*)  subviewIntersectingRect: (NSRect)box ignoring: (NSView*)ignoreme; // ignoreme may be nil.
-(NSSize)   subviewsCombinedSize;   // The smallest NSSize for a rect enclosing all subviews.

@end
