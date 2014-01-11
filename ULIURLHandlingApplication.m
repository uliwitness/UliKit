//
//  ULIURLHandlingApplication.m
//  Stacksmith
//
//  Created by Uli Kusterer on 2014-01-11.
//  Copyright (c) 2014 Uli Kusterer. All rights reserved.
//

#import "ULIURLHandlingApplication.h"

@implementation ULIURLHandlingApplication

-(void)	didReceiveGetURLEvent: (NSAppleEventDescriptor*)URLEvent replyEvent: (NSAppleEventDescriptor*)replyEvent
{
    if( [self.delegate respondsToSelector: @selector(application:openURL:)])
    {
		NSString	*	theURLString = [[URLEvent paramDescriptorForKeyword: keyDirectObject] stringValue];
		NSURL	*		theURL = theURLString ? [NSURL URLWithString: theURLString] : nil;
		if( theURL )
			[self.delegate application: self openURL: theURL];
	}
}
 
-(void)	finishLaunching
{
    [NSAppleEventManager.sharedAppleEventManager setEventHandler: self andSelector: @selector(didReceiveGetURLEvent:replyEvent:) forEventClass: kInternetEventClass andEventID: kAEGetURL];
    
    [super finishLaunching];
}


-(void)	setDelegate: (id<ULIURLHandlingApplicationDelegate>)inDelegate
{
	[super setDelegate: inDelegate];
}


-(id<ULIURLHandlingApplicationDelegate>)	delegate
{
	return (id<ULIURLHandlingApplicationDelegate>)[super delegate];
}


@end
