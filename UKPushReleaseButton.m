//
//  UKPushReleaseButton.m
//  DruckTalk
//
//  Created by Uli Kusterer on 14.07.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

#import "UKPushReleaseButton.h"


@implementation UKPushReleaseButton

-(void)	mouseDown: (NSEvent*)evt
{
	oldTarget = [self target];
	oldAction = [self action];
	[self setTarget: nil];
	[self setAction: nil];
	
	[oldTarget performSelector: oldAction withObject: self];
	
	[super mouseDown: evt];
	
	[self setTarget: oldTarget];
	[self setAction: oldAction];
	
	[oldTarget performSelector: oldAction withObject: self];
}

@end
