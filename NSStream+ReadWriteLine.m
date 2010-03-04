//
//  NSStream+ReadWriteLine.m
//  RSSToPOP
//
//  Created by Uli Kusterer on 11.11.05.
//  Copyright 2005 Uli Kusterer.
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
