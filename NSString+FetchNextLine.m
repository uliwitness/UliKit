//
//  NSString+FetchNextLine.m
//  MayaFTP
//
//  Created by Uli Kusterer on Fri Aug 27 2004.
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

#import "NSString+FetchNextLine.h"


@implementation NSMutableString (UKFetchNextLine)

-(NSString*)	nextLine
{
	NSRange		range = [self rangeOfString: @"\n"];
	NSString*   firstline = nil;
	
	if( range.location != NSNotFound && range.length != 0 )
	{
		firstline = [self substringToIndex: (range.location)];
		[self deleteCharactersInRange: NSMakeRange(0,range.location +range.length)];
	}
	
	return firstline;
}

-(NSString*)    nextFullLine
{
	NSString*		string = nil;
	unsigned int	start = 0,
					end = 0,
					nextStart = 1;
	NSRange			range, oldRange, lineRange;
	
    oldRange = NSMakeRange(0,0);
    if( (nextStart+1) < [self length] )
    {
        range = NSMakeRange(nextStart, 1);
        [self getLineStart: &start end:&nextStart contentsEnd:&end forRange:range];
        lineRange = NSMakeRange( start, nextStart-start );
        string = [self substringWithRange:lineRange];
        if( [string characterAtIndex:([string length] -1)] != '\n'
            && [string characterAtIndex:([string length] -1)] != '\r' )
            string = nil;
        else
        {
            oldRange = lineRange;
            lineRange.length--;
        }
    }
    
    range = NSMakeRange( 0, oldRange.length +oldRange.location );
    [self deleteCharactersInRange:range];
    
    return string;
}

@end
