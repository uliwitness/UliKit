//
//  UKFlippedBoxView.m
//  UKProgressPanel
//
//  Created by Uli Kusterer on 22.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import "UKFlippedBoxView.h"


@implementation UKFlippedBoxView

-(id)	initWithFrame: (NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        // Initialization code here.
    }
    return self;
}

-(BOOL)	isFlipped
{
    return YES;
}

@end
