//
//  NSApplicationWindowAtPoint.h
//  UKDockableWindow
//
//  Created by Uli Kusterer on Wed Feb 04 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSApplication (WindowAtPoint)

-(NSWindow*)	windowAtPoint: (NSPoint)pos ignoreWindow: (NSWindow*)ignorew;   // ignorew may be nil.

@end
