//
//  UKTiledImageView.m
//  TalkingMoose
//
//  Created by Uli Kusterer on 03.02.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "UKTiledImageView.h"


@implementation UKTiledImageView

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
	NSSize		desiredImageSize = [img size];
    NSRect      dstBox = { { 0, 0 }, { 0, 0 } },
                srcBox = { { 0, 0 }, { 0, 0 } };
    float       xend = [self bounds].size.width;
	
	if( scaleVertically )
	{
		float scaleFactor = [self bounds].size.height / desiredImageSize.height;
		desiredImageSize.height *= scaleFactor;
		desiredImageSize.width *= scaleFactor;
	}
	
    srcBox.size = [img size];
    dstBox.size = desiredImageSize;
    
    while( dstBox.origin.x <= xend )
    {
        [img drawInRect: dstBox fromRect: srcBox operation: NSCompositeCopy fraction: 1.0];
        dstBox.origin.x += dstBox.size.width;
    }
}


-(BOOL)	scaleVertically
{
	return scaleVertically;
}


-(void)	setScaleVertically: (BOOL)doScale
{
	if( scaleVertically != doScale )
	{
		scaleVertically = doScale;
		[self setNeedsDisplay: YES];
	}
}


@end
