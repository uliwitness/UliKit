//
//  UKColorWell.m
//  TheBigRedButton
//
//  Created by Uli Kusterer on 27.08.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

#import "UKColorWell.h"


@implementation UKColorWell

-(void)	awakeFromNib
{
	wasInited = YES;
}

- (void)setColor:(NSColor *)color
{
	[super setColor: color];
	if( wasInited && [self target] && [self action] )
		[[self target] performSelector: [self action] withObject: self];
}

@end
