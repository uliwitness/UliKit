//
//  NSArray+Color.m
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

#import "NSArray+Color.h"


@implementation NSArray (Color)

+(NSArray*)		arrayWithColor: (NSColor*) col
{
	if( !col )
		return nil;
	
	CGFloat			fRed, fGreen, fBlue, fAlpha;
	
	col = [col colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
	[col getRed: &fRed green: &fGreen blue: &fBlue alpha: &fAlpha];
	
	return [self arrayWithObjects: [NSNumber numberWithFloat:fRed], [NSNumber numberWithFloat:fGreen],
									[NSNumber numberWithFloat:fBlue], [NSNumber numberWithFloat:fAlpha], nil];
}


-(NSColor*)		colorValue
{
	float			fRed, fGreen, fBlue, fAlpha = 1.0;
	
	fRed = [[self objectAtIndex:0] floatValue];
	fGreen = [[self objectAtIndex:1] floatValue];
	fBlue = [[self objectAtIndex:2] floatValue];
	if( [self count] > 3 )	// Have alpha info?
		fAlpha = [[self objectAtIndex:3] floatValue];
	
	return [NSColor colorWithCalibratedRed: fRed green: fGreen blue: fBlue alpha: fAlpha];
}

+(NSColor*)		colorValueOfArray: (NSArray*)arr withFallback: (NSArray*)fb
{
	if( !arr )
		return [fb colorValue];
	else
		return [arr colorValue];
}

@end
