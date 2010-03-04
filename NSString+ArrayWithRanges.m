//
//  NSString+ArrayWithRanges.m
//  SVNBrowser
//
//  Created by Uli Kusterer on 14.10.04.
//  Copyright 2004 M. Uli Kusterer.
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
