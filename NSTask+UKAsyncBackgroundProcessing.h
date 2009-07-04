//
//  NSTask+UKAsyncBackgroundProcessing.h
//  AngelBzr
//
//  Created by Uli Kusterer on 31.05.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

/*
	This adds a method to NSTask that lets you run an NSTask on another thread
	and tell it to call you back on the main thread when it's finished.
*/

#import <Cocoa/Cocoa.h>


@interface NSTask (UKAsyncBackgroundProcessing)

-(void)	waitUntilExitAsynchronouslyWithTarget: (id)targ finishSelector: (SEL)fini;

@end
