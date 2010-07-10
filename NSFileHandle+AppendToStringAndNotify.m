//
//  NSFileHandle+AppendToStringAndNotify.m
//  MayaFTP
//
//  Created by Uli Kusterer on Thu Aug 26 2004.
//  Copyright (c) 2004 M. Uli Kusterer.
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

#import "NSFileHandle+AppendToStringAndNotify.h"


static NSMutableArray* gUKAppendAndNotifyData = nil;


@interface NSFileHandle (UKAppendToStringAndNotifyPrivateMethods)

-(NSDictionary*)		infoDictionaryForAppendAndNotify;

-(void)					notifyFileHandleReadCompletionForAppendAndNotify: (NSNotification*) notification;

@end


@implementation NSFileHandle (UKAppendToStringAndNotify)

-(void) readDataToEndOfFileIntoString: (NSMutableString*)str endSelector: (SEL)sel
										delegate: (id)del
{
	if( !gUKAppendAndNotifyData )
		gUKAppendAndNotifyData = [[NSMutableArray alloc] init];
	
	[gUKAppendAndNotifyData addObject: [NSDictionary dictionaryWithObjectsAndKeys:
							[NSValue valueWithNonretainedObject: self], @"object",
							[NSValue valueWithNonretainedObject: del], @"delegate",
							[NSValue valueWithBytes: &sel objCType: @encode(SEL)], @"selector",
							str, @"outputstring",
							nil] ];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(notifyFileHandleReadCompletionForAppendAndNotify:)
			name:NSFileHandleReadCompletionNotification object: self];
	[self readInBackgroundAndNotify];
}


-(void) readDataToEndOfFileIntoData: (NSMutableData*)theData endSelector: (SEL)sel
										delegate: (id)del
{
	if( !gUKAppendAndNotifyData )
		gUKAppendAndNotifyData = [[NSMutableArray alloc] init];
	
	[gUKAppendAndNotifyData addObject: [NSDictionary dictionaryWithObjectsAndKeys:
							[NSValue valueWithNonretainedObject: self], @"object",
							[NSValue valueWithNonretainedObject: del], @"delegate",
							[NSValue valueWithBytes: &sel objCType: @encode(SEL)], @"selector",
							theData, @"outputdata",
							nil] ];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(notifyFileHandleReadCompletionForAppendAndNotify:)
			name:NSFileHandleReadCompletionNotification object: self];
	[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(notifyFileHandleReadCompletionForAppendAndNotify:)
			name:NSFileHandleReadToEndOfFileCompletionNotification object: self];
	[self readInBackgroundAndNotify];
}


@end


@implementation NSFileHandle (UKAppendToStringAndNotifyPrivateMethods)

-(NSDictionary*)		infoDictionaryForAppendAndNotify
{
	NSEnumerator*		enny = [gUKAppendAndNotifyData objectEnumerator];
	NSDictionary*		dict;
	
	while( (dict = [enny nextObject]) )
	{
		if( [[dict objectForKey: @"object"] nonretainedObjectValue] == self )
			return dict;
	}
	
	return nil;
}

-(void)	notifyFileHandleReadCompletionForAppendAndNotify: (NSNotification*) notification
{
	NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	NSData*				data = nil;
	NSDictionary*		info = [self infoDictionaryForAppendAndNotify];
		
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

	data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
	if( data && [data length] ) // Still data left:
	{
		// Append data:
		NSMutableString*	outStr = [info objectForKey: @"outputstring"];
		if( outStr )
		{
			NSString* dataStr = [[[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding] autorelease];
			[outStr appendString: dataStr];
		}
		else
			[[info objectForKey: @"outputdata"] appendData: data];
		
		// Actually send notification:
		[inv setArgument: &finished atIndex:3];
		[inv invokeWithTarget: del];
		
		// Go on reading:
		[self readInBackgroundAndNotify];
	}
	else	// Out of data. We're finished:
	{
        [[NSNotificationCenter defaultCenter] removeObserver:self
			name:NSFileHandleReadCompletionNotification object: self];
        
		// Actually send notification:
		finished = YES;
		[inv setArgument: &finished atIndex:3];
		[inv invokeWithTarget: del];
		
		[gUKAppendAndNotifyData removeObject: info];
		if( [gUKAppendAndNotifyData count] == 0 )
		{
			[gUKAppendAndNotifyData autorelease];
			gUKAppendAndNotifyData = nil;
		}
	}
	
	[pool release];
}


@end
