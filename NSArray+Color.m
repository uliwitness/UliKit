//
//  NSArray+Color.m
//  CocoaTADS
//
//  Created by Uli Kusterer on Mon Jun 02 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import "NSArray+Color.h"


@implementation NSArray (Color)

+(NSArray*)		arrayWithColor: (NSColor*) col
{
	if( !col )
		return nil;
	
	float			fRed, fGreen, fBlue, fAlpha;
	
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
