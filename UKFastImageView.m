//
//  UKFastImageView.m
//  TalkingMoose
//
//  Created by Uli Kusterer on 03.02.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "UKFastImageView.h"


@implementation UKFastImageView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if( self )
    {
        // Initialization code here.
    }
    return self;
}

-(void) drawRect:(NSRect)rect
{
    NSImage*    img = [self image];
    NSRect      dstBox, srcBox;
    
    dstBox = srcBox = rect;
    
    [img drawInRect: dstBox fromRect: srcBox operation: NSCompositeCopy fraction: 1.0];
}

@end
