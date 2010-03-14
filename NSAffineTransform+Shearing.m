//
//  NSAffineTransform+Shearing.m
//  Propaganda
//
//  Created by Uli Kusterer on 14.03.10.
//  Copyright 2010 The Void Software. All rights reserved.
//

#import "NSAffineTransform+Shearing.h"


@implementation NSAffineTransform (UKShearing)

-(void)	shearXBy: (CGFloat)xFraction yBy: (CGFloat)yFraction
{
	NSAffineTransform*		theTransform = [NSAffineTransform transform];
	NSAffineTransformStruct	transformStruct = { 0 };
	
	transformStruct.m11 = 1.0;
	transformStruct.m12 = yFraction;
	transformStruct.m21 = xFraction;
	transformStruct.m22 = 1.0;
	
	[theTransform setTransformStruct: transformStruct];
	[self prependTransform: theTransform];
}

@end
