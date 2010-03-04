//
//  UKFileFinder.m
//  Shovel
//
//  Created by Uli Kusterer on Wed Mar 24 2004.
//  Copyright (c) 2004 Uli Kusterer.
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

#import "UKFileFinder.h"


@implementation UKFileFinder

+(id)			fileFinderForFolder: (NSString*)folder withPattern: (NSString*)pattern
{
	return [[[self alloc] initForFolder: folder withPattern: pattern] autorelease];
}

-(id)			initForFolder: (NSString*)folder withPattern: (NSString*)pattern
{
	self = [super init];
	if( !self )
		return nil;
	
	tempBuffer = [[NSMutableString alloc] init];
	
	findPipe = [[NSPipe alloc] init];
	NSFileHandle*   fHand = [findPipe fileHandleForReading];
	
	findTask = [[NSTask alloc] init];
	[findTask setLaunchPath: @"/usr/bin/find"];
	[findTask setArguments: [NSArray arrayWithObjects: folder, @"-name", pattern, nil]];
	[findTask setStandardOutput: findPipe];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(captureOutput:)
											name: NSFileHandleReadCompletionNotification object: fHand];
	[fHand readInBackgroundAndNotify];
	
	[findTask launch];
	
	return self;
}


-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
			name:NSFileHandleReadCompletionNotification object: [findPipe fileHandleForReading]];
	
	[findTask release];
	findTask = nil;
	[tempBuffer release];
	tempBuffer = nil;
	[findPipe release];
	findPipe = nil;
	
	[super dealloc];
}


-(NSString*)	nextObject
{
	NSCharacterSet*			charset = [NSCharacterSet characterSetWithCharactersInString: @"\n\r"];
	[lastPath release];
	lastPath = nil;
	
	while( (findTask && [findTask isRunning]) || [tempBuffer length] > 0 )
	{
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1]];
	
		NSRange breakRange = [tempBuffer rangeOfCharacterFromSet: charset];
		if( breakRange.location != NSNotFound || breakRange.length > 0 )
		{
			lastPath = [[tempBuffer substringToIndex: breakRange.location] retain];
			breakRange.length += breakRange.location;
			breakRange.location = 0;
			[tempBuffer deleteCharactersInRange: breakRange];
			NSLog(@"Size: %d.",[tempBuffer length]);
			return lastPath;
		}
		else if( !findTask )
		{
			NSLog(@"Finished.");
			lastPath = tempBuffer;
			tempBuffer = [[NSMutableString alloc] init];
			return lastPath;
		}
	}
	
	return nil;
}


-(NSDictionary*)	fileAttributes
{
	return [[NSFileManager defaultManager] fileAttributesAtPath: lastPath traverseLink: NO];
}


-(void)		captureOutput: (NSNotification*)notif
{
	NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	NSFileHandle*		theHand = [notif object];
	NSData*				theData = [[notif userInfo] objectForKey: NSFileHandleNotificationDataItem];
	
	if( theData && [theData length] > 0 )
	{
		NSString*   newData = [[[NSString alloc] initWithData: theData encoding: NSUTF8StringEncoding] autorelease];
		
		[tempBuffer appendString: newData];
		
		[theHand readInBackgroundAndNotify];
	}
	/*else if( [findTask isRunning] )
		[theHand readInBackgroundAndNotify];*/
	else
	{
		NSTask*		oldTask = findTask;
		findTask = nil;
		[oldTask terminate];
		[oldTask release];
		//[findPipe release];
		//findPipe = nil;
	}
	
	NSLog(@"ReadNotification");
	
	[pool release];
}

@end
