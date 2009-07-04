//
//  UKPushReleaseButton.h
//  DruckTalk
//
//  Created by Uli Kusterer on 14.07.07.
//  Copyright 2007 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UKPushReleaseButton : NSButton
{
	id		oldTarget;
	SEL		oldAction;
}

@end
