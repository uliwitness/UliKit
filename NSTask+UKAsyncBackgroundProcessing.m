//
//  NSTask+UKAsyncBackgroundProcessing.m
//  AngelBzr
//
//  Created by Uli Kusterer on 31.05.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import "NSTask+UKAsyncBackgroundProcessing.h"


@implementation NSTask (UKAsyncBackgroundProcessing)

-(void)	threadedWaitUntilExitTakingOverInfoArray: (NSArray*)infoArray
{
	// This method takes over the array it gets to avoid dangling pointers due to race conditions.
	SEL		didEndSelector = [[infoArray objectAtIndex: 1] pointerValue];
	id		didEndTarget = [infoArray objectAtIndex: 0];
	
	[self waitUntilExit];
	
	[didEndTarget performSelectorOnMainThread: didEndSelector withObject: self waitUntilDone: YES];
	
	[infoArray release];
}


-(void)	waitUntilExitAsynchronouslyWithTarget: (id)targ finishSelector: (SEL)fini
{
	NSArray*	info = [[NSArray alloc] initWithObjects: targ, [NSValue valueWithPointer: fini], nil];
	// Array is alloced by us, released by the child thread, otherwise we might release it while the
	//	other thread is swapped out and hasnt retained it yet.
	
	[NSThread detachNewThreadSelector: @selector(threadedWaitUntilExitTakingOverInfoArray:) toTarget: self withObject: info];
}


@end
