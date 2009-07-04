//
//  NSAppleEventDescriptor+AESend.m
//  GrowlMooseDisplay
//
//  Created by Uli Kusterer on 08.07.06.
//  Copyright 2006 Uli Kusterer. All rights reserved.
//

#import "NSAppleEventDescriptor+AESend.h"


@implementation NSAppleEventDescriptor (AESendAddition)

-(void)  sendEvent
{
	OSStatus err = AESendMessage( [self aeDesc], NULL, kAENoReply, kAEDefaultTimeout );
	if( err != noErr )
		NSLog( @"Error %d sending Apple Event.", err );
}

@end