//
//  NSTask+UKAsyncBackgroundProcessing.m
//  AngelBzr
//
//  Created by Uli Kusterer on 31.05.08.
//  Copyright 2008 Uli Kusterer.
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
