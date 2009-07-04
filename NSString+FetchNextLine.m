//
//  NSString+FetchNextLine.m
//  MayaFTP
//
//  Created by Uli Kusterer on Fri Aug 27 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
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
