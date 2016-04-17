//
//  NSTask+ULIReadOutput.m
//  Lanyon
//
//  Created by Uli Kusterer on 17/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This file requires ARC. Please add the -fobjc-arc compiler option for this file.
#endif


#import "NSTask+ULIReadOutput.h"


@implementation NSTask (ULIReadOutput)

+(NSTask*)	taskWithLaunchPath:(NSString *)path arguments:(NSArray<NSString *> *)arguments terminationHandlerWithOutput: (void(^)(NSTask* sender, NSData* output, NSData* errOutput))inCompletionBlock progressHandler: (void(^ _Nullable)(NSTask* sender, NSData* _Nullable output, NSData* _Nullable errOutput))inProgressBlock
{
	NSTask	*	whichTask = [self new];
	whichTask.launchPath = path;
	whichTask.arguments = arguments;
	
	// Capture stdout:
	NSMutableData	*	output = [NSMutableData data];
	NSPipe			*	outputPipe = [NSPipe pipe];
	NSFileHandle	*	ofh = [outputPipe fileHandleForReading];
	whichTask.standardOutput = outputPipe;
	ofh.readabilityHandler = ^( NSFileHandle * theHandle )
	{
		NSData	*	currData = theHandle.availableData;
		if( inProgressBlock )
			inProgressBlock( whichTask, currData, nil );
		[output appendData: currData];
	};
	
	// Capture stderr:
	NSMutableData	*	errOutput = [NSMutableData data];
	NSPipe			*	errOutputPipe = [NSPipe pipe];
	NSFileHandle	*	efh = [errOutputPipe fileHandleForReading];
	whichTask.standardError = errOutputPipe;
	efh.readabilityHandler = ^( NSFileHandle * theHandle )
	{
		NSData	*	currData = theHandle.availableData;
		if( inProgressBlock )
			inProgressBlock( whichTask, nil, currData );
		[errOutput appendData: currData];
	};

	
	// Be notified when this finishes:
	whichTask.terminationHandler = ^( NSTask* sender )
	{
		[output appendData: ofh.availableData];
		[errOutput appendData: efh.availableData];
		inCompletionBlock( sender, output, errOutput );
	};
	
	return whichTask;
}


+(NSTask*)	launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray<NSString *> *)arguments terminationHandlerWithOutput: (void(^)(NSTask* sender, NSData* output, NSData* errOutput))inCompletionBlock progressHandler: (void(^ _Nullable)(NSTask* sender, NSData* _Nullable output, NSData* _Nullable errOutput))inProgressBlock
{
	NSTask*	whichTask = [self taskWithLaunchPath: path arguments: arguments terminationHandlerWithOutput: inCompletionBlock progressHandler: inProgressBlock];
	[whichTask launch];
	return whichTask;
}


+(NSTask*)	launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray<NSString *> *)arguments terminationHandlerWithOutput: (void(^)(NSTask* sender, NSData* output, NSData* errOutput))inCompletionBlock
{
	NSTask*	whichTask = [self taskWithLaunchPath: path arguments: arguments terminationHandlerWithOutput: inCompletionBlock progressHandler: nil];
	[whichTask launch];
	return whichTask;
}

@end
