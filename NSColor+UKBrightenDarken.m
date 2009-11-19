//
//  NSColor+UKBrightenDarken.m
//  UKBorderlessWidgetizedWindow
//
//  Created by Uli Kusterer on 27.10.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

#import "NSColor+UKBrightenDarken.h"


@implementation NSColor (UKBrightenDarken)

-(NSColor*)	brightenColorBy: (CGFloat)percentage
{
	NSColor*	hsbColor = [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
	
	return [NSColor colorWithCalibratedHue: [hsbColor hueComponent] saturation: [hsbColor saturationComponent]
						brightness: [hsbColor brightnessComponent] +[hsbColor brightnessComponent] *percentage alpha: [hsbColor alphaComponent]];
}


-(NSColor*)	darkenColorBy: (CGFloat)percentage
{
	NSColor*	hsbColor = [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
	
	return [NSColor colorWithCalibratedHue: [hsbColor hueComponent] saturation: [hsbColor saturationComponent]
						brightness: [hsbColor brightnessComponent] -[hsbColor brightnessComponent] *percentage alpha: [hsbColor alphaComponent]];
}

@end
