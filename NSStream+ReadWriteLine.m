//
//  NSStream+ReadWriteLine.m
//  RSSToPOP
//
//  Created by Uli Kusterer on 11.11.05.
//  Copyright 2005 Uli Kusterer. All rights reserved.
//

#import "NSStream+ReadWriteLine.h"


@implementation NSInputStream (UKReadWriteLine)

-(NSString*)	readOneLine
{
	uint8_t				theChar = 0;
	NSMutableString*	str = [NSMutableString string];
	BOOL				hadCR = NO;
	BOOL				hadData = NO;
	
	while( [self read: &theChar maxLength: 1] == 1 )
	{
		hadData = YES;
		if( theChar == '\r' )
		{
			hadCR = YES;
			continue;
		}
		else if( theChar == '\n' && hadCR )
			break;
		hadCR = NO;
		
		[str appendFormat: @"%c", theChar];
	
		NSLog( @"%@", str );
	}
	
	if( !hadData )
		return nil;
	else
		return str;
}

@end

@implementation NSOutputStream (UKReadWriteLine)

-(void)		writeOneLine: (NSString*)lineStr
{
	NSData* dt = [lineStr dataUsingEncoding: NSASCIIStringEncoding];
	[self write: [dt bytes] maxLength: [dt length]];
	unsigned char*		crlf = "\r\n";
	[self write: crlf maxLength: 2];
}

@end
