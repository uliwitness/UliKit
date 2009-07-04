//
//  NSFileHandle+UKReadLinewise.m
//  MayaFTP
//
//  Created by Uli Kusterer on Thu Aug 26 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSFileHandle+UKReadLinewise.h"
#import "NSString+FetchNextLine.h"


static NSMutableArray* gUKReadLinewiseData = nil;

//-(void) fileHandle: (NSFileHandle*)sender didReadLine: (NSString*)currLine

@interface NSFileHandle (UKReadLinewisePrivateMethods)

-(NSDictionary*)		infoDictionaryForReadLinewise;

-(void)					notifyFileHandleReadCompletionForReadLinewise: (NSNotification*) notification;

@end


@implementation NSFileHandle (UKReadLinewise)

-(void) readLinesToEndOfFileNotifyingTarget: (id)del newLineSelector: (SEL)sel
{
	if( !gUKReadLinewiseData )
		gUKReadLinewiseData = [[NSMutableArray alloc] init];
	
	[gUKReadLinewiseData addObject: [NSDictionary dictionaryWithObjectsAndKeys:
							[NSValue valueWithNonretainedObject: self], @"object",
							[NSValue valueWithNonretainedObject: del], @"delegate",
							[NSValue valueWithBytes: &sel objCType: @encode(SEL)], @"selector",
							[[[NSMutableString alloc] init] autorelease], @"outputstring",
							nil] ];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(notifyFileHandleReadCompletionForReadLinewise:)
			name: NSFileHandleReadCompletionNotification object: self];
	[self readInBackgroundAndNotify];
}


@end


@implementation NSFileHandle (UKReadLinewisePrivateMethods)

-(NSDictionary*)		infoDictionaryForReadLinewise
{
	NSEnumerator*		enny = [gUKReadLinewiseData objectEnumerator];
	NSDictionary*		dict;
	
	while( (dict = [enny nextObject]) )
	{
		if( [[dict objectForKey: @"object"] nonretainedObjectValue] == self )
			return dict;
	}
	
	return nil;
}

-(void)	notifyFileHandleReadCompletionForReadLinewise: (NSNotification*) notification
{
	NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	NSData*				data;
	NSDictionary*		info = [self infoDictionaryForReadLinewise];
		
	// Set up callback:
	SEL		sel = nil;
	id		del = [[info objectForKey: @"delegate"] nonretainedObjectValue];
	BOOL	finished = NO;
	
	[[info objectForKey: @"selector"] getValue: &sel];

	// Create NSInvocation and stuff so we can notify the other object:
	NSMethodSignature* sig = [del methodSignatureForSelector: sel];
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature: sig];
	[inv setSelector: sel];
	[inv setArgument: &self atIndex:2]; // 0 and 1 are reserved by objC for receiver's "self" and SEL.
	
	NSMutableString*	outStr = [info objectForKey: @"outputstring"];
	
	data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
	if( data && [data length] ) // Still data left:
	{
		// Append data:
		NSString* dataStr = [[[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding] autorelease];
		[outStr appendString: dataStr];
		
		// Extract all complete lines, which end in a line break. Ignore the
		//	others, because we don't know yet if they're fully read:
		NSString*	currLine = nil;
		while(( currLine = [outStr nextFullLine] ))
		{
			// Actually send notification:
			[inv setArgument: &currLine atIndex:3];
			[inv invokeWithTarget: del];
		}
		
		// Go on reading:
		[self readInBackgroundAndNotify];
	}
	else	// Out of data. We're finished:
	{
        [[NSNotificationCenter defaultCenter] removeObserver:self
			name:NSFileHandleReadCompletionNotification object: self];
        
		// Extract all lines left that we didn't send out yet:
		NSString*	currLine = nil;
		while(( currLine = [outStr nextLine] ))
		{
			// Actually send notification:
			[inv setArgument: &currLine atIndex: 3];
			[inv invokeWithTarget: del];
		}
		
		// Now send a final notification with a NIL string to indicate we're finished:
		finished = YES;
		NSString*	nilStr = nil;
		[inv setArgument: &nilStr atIndex:3];
		[inv invokeWithTarget: del];
		
		// Clean up:
		[gUKReadLinewiseData removeObject: info];
		if( [gUKReadLinewiseData count] == 0 )
		{
			[gUKReadLinewiseData autorelease];
			gUKReadLinewiseData = nil;
		}
	}
	
	[pool release];
}


@end
