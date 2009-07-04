//
//  UKWellControl.m
//  UKWellControl
//
//  Created by Uli Kusterer on 12.02.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "UKWellControl.h"
#import "UKGraphics.h"
#import "UKFinderIconCell.h"


@implementation UKWellControl

-(void) awakeFromNib
{
    NSImageCell*   theCell;
    theCell = [[[UKFinderIconCell alloc] initTextCell: @"HELLo tHERE"] autorelease];
    [theCell setImagePosition: NSImageAbove];
    [self setCell: theCell];
}

-(void) drawRect: (NSRect)dirtyArea
{
    UKDrawGenericWell( [self bounds], dirtyArea );
    
    [[self cell] drawInteriorWithFrame: NSInsetRect([self bounds], 8, 8) inView: self];
}

@end
