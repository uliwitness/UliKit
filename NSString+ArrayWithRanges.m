//
//  NSString+ArrayWithRanges.m
//  SVNBrowser
//
//  Created by Uli Kusterer on 14.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSString+ArrayWithRanges.h"
#import <stdarg.h>


@implementation NSString (UKArrayWithRanges)

-(NSArray*)	arrayWithRanges: (int)firstEnd, ...
{
	va_list			vlst;
	NSMutableArray*	arr = [NSMutableArray array];
	NSRange			currRange = { 0, 0 };
	int				currEnd = 1;
	
	currRange.length = firstEnd +1;
	[arr addObject: [self substringWithRange: currRange]];
	
	va_start( vlst, firstEnd );
	while( currEnd != 0 )
	{
		currEnd = va_arg( vlst, int );
		if( currEnd == 0 )
			break;
		currRange.location += currRange.length;
		currRange.length = currEnd -currRange.location;
		[arr addObject: [self substringWithRange: currRange]];
	}
	va_end( vlst );
	
	currRange.location += currRange.length;
	currRange.length = [self length] -currRange.location;
	[arr addObject: [self substringWithRange: currRange]];
	
	return arr;
}

@end
