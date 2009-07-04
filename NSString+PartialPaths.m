//
//  NSString+PathCombiningExtensions.m
//  VerpackIt
//
//  Created by Uli Kusterer on 18.09.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSString+PartialPaths.h"


@implementation NSString (UKPartialPaths)

-(NSString*)	stringByCombiningWithPartialPath: (NSString*)inPartial
{
	NSMutableString*	partial = [[inPartial mutableCopy] autorelease];
	NSMutableString*	base = [[self mutableCopy] autorelease];
	NSRange				endRange;
	
	if( [base hasSuffix: @"/"] )	// Remove any trailing slashes that might screw up removal.
		[base deleteCharactersInRange: NSMakeRange([base length]-1,1)];
	
	if( [partial hasPrefix: @"/"] )	// Absolute path! No need for relativity.
		return partial;
	
	while( [partial hasPrefix: @"../"] )	// Relative path goes up? Do that.
	{
		[partial deleteCharactersInRange: NSMakeRange(0,3)];
		endRange = [base rangeOfString:@"/" options: NSBackwardsSearch];
		endRange.length = [base length] -endRange.location;	// This includes the slash.
		[base deleteCharactersInRange: endRange];			// Remove last item and its slash.
	}
	
	[base appendString: @"/"];	// Re-insert trailing slash.
	[base appendString: partial];
		
	return base;
}

-(NSString*)	stringBySubtractingBasePath: (NSString*)basePath
{
	if( [basePath characterAtIndex: [basePath length]-1] != '/' )
		basePath = [basePath stringByAppendingString: @"/"];
	
	NSString*			commonPrefix = [basePath commonPrefixWithString: self options: 0];	// Can't swap basePath and self here, or we could run afoul of decomposed char sequences.
	NSRange				endRange = [commonPrefix rangeOfString:@"/" options: NSBackwardsSearch],
						retainedRange;
	int					x = endRange.location +1;
	NSMutableString*	substr;
	
	retainedRange = [self rangeOfString: commonPrefix];
	if( retainedRange.location == NSNotFound )
		return self;
	
	substr = [[[self substringFromIndex: (retainedRange.location +retainedRange.length)] mutableCopy] autorelease];
	
	for( ; x < [basePath length]; x++ )
		if( [basePath characterAtIndex: x] == '/' )
			[substr insertString: @"../" atIndex: 0];
	
	return substr;
}

-(int)			upwardsDepth
{
	int					ud = 0;
	NSRange				range,
						searchRange = { 0, [self length] };
	while( true )
	{
		range = [self rangeOfString: @"../" options: 0 range: searchRange];
		if( range.location != searchRange.location )	// can't cope if it's in the middle. Also covers NSNotFound.
			break;
		searchRange.location = range.location +range.length;
		searchRange.length -= range.location +range.length;
		ud++;
	}
	
	return ud;
}

@end


@implementation NSArray (UKPathCombiningExtensions)

-(int)			maxUpwardsDepth
{
	int				ud = 0;
	NSEnumerator*	enny = [self objectEnumerator];
	NSString*		obj;
	
	while( (obj = [enny nextObject]) )
	{
		int	cud = [obj upwardsDepth];
		
		if( cud > ud )
			ud = cud;
	}
		
	return ud;
}

@end
