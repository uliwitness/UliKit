//
//  ULIInvisiblePlayerView.m
//  ObjectCanvas
//
//  Created by Uli Kusterer on 2013-12-28.
//  Copyright (c) 2013 Uli Kusterer. All rights reserved.
//

#import "ULIInvisiblePlayerView.h"


@interface ULIInvisiblePlayerView ()

@property (strong)	AVPlayerLayer	*	playerLayer;

@end


@implementation ULIInvisiblePlayerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        self.wantsLayer = YES;
		self.layer = [CALayer layer];
    }
    return self;
}


-(void)	setPlayer: (AVPlayer*)inPlayer
{
	if( !self.playerLayer )
	{
		self.playerLayer = [AVPlayerLayer playerLayerWithPlayer: inPlayer];
		[self.playerLayer setFrame: self.layer.bounds];
		[self.playerLayer setAutoresizingMask: kCALayerWidthSizable | kCALayerHeightSizable];
		self.playerLayer.contentsGravity = kCAGravityResizeAspect;
		[self.layer addSublayer: self.playerLayer];
	}
	else
		self.playerLayer.player = inPlayer;
}


-(AVPlayer*)	player
{
	return self.playerLayer.player;
}

@end
