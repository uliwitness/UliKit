//
//  NSColor+UKBrightenDarken.h
//  UKBorderlessWidgetizedWindow
//
//  Created by Uli Kusterer on 27.10.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSColor (UKBrightenDarken)

-(NSColor*)	brightenColorBy: (CGFloat)percentage;

-(NSColor*)	darkenColorBy: (CGFloat)percentage;

@end
