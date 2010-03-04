//
//  NSArray+Color.h
//  CocoaTADS
//
//  Created by Uli Kusterer on Mon Jun 02 2003.
//  Copyright (c) 2003 M. Uli Kusterer.
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

#import <AppKit/AppKit.h>


// Methods to treat an NSArray with three elements as an RGB color.
// Useful for storing colors in NSUserDefaults etc.
@interface NSArray (Color)

+(NSColor*)		colorValueOfArray: (NSArray*)arr withFallback: (NSArray*)fb;	// Returns colorValue of arr, if arr == NIL colorValue of fb.

+(NSArray*)		arrayWithColor: (NSColor*) col;
-(NSColor*)		colorValue;

@end
