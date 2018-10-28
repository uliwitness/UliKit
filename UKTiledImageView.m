//
//  UKTiledImageView.m
//  TalkingMoose
//
//  Created by Uli Kusterer on 03.02.05.
//  Copyright 2005 Uli Kusterer.
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
        [img drawInRect: dstBox fromRect: srcBox operation: NSCompositingOperationCopy fraction: 1.0];
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

-(BOOL)	mouseDownCanMoveWindow
{
	return mMouseDownCanMoveWindow;
}


-(void)	setMouseDownCanMoveWindow: (BOOL)inCanMove
{
	mMouseDownCanMoveWindow = inCanMove;
}

@end
