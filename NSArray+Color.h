//
//  NSArray+Color.h
//  CocoaTADS
//
//  Created by Uli Kusterer on Mon Jun 02 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import <AppKit/AppKit.h>


// Methods to treat an NSArray with three elements as an RGB color.
// Useful for storing colors in NSUserDefaults etc.
@interface NSArray (Color)

+(NSColor*)		colorValueOfArray: (NSArray*)arr withFallback: (NSArray*)fb;	// Returns colorValue of arr, if arr == NIL colorValue of fb.

+(NSArray*)		arrayWithColor: (NSColor*) col;
-(NSColor*)		colorValue;

@end
