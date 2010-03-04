//
//  NSDictionary+DeepCopy.m
//  UKSyntaxColoredDocument
//
//  Created by Uli Kusterer on Tue May 18 2004.
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

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "NSDictionary+DeepCopy.h"


@implementation NSDictionary (UKDeepCopy)

-(NSDictionary*)  deepCopy
{
	NSMutableDictionary	*	theDict = [[NSMutableDictionary alloc] initWithCapacity: [self count]];
	NSEnumerator		*	enny = [self keyEnumerator];
	NSString			*	currKey = nil;
	
	while(( currKey = [enny nextObject] ))
	{
		id	currObj = [self objectForKey: currKey];
		if( [currObj respondsToSelector: @selector(deepCopy)] )
			currObj = [[currObj deepCopy] autorelease];
		else
			currObj = [[currObj copy] autorelease];
		[theDict setObject: currObj forKey: currKey];
	}
	
	return theDict;
}


-(NSMutableDictionary*)  deepMutableContainerCopy
{
	NSMutableDictionary	*	theDict = [[NSMutableDictionary alloc] init];
	NSEnumerator		*	enny = [self keyEnumerator];
	NSString			*	currKey = nil;
	
	while(( currKey = [enny nextObject] ))
	{
		id	currObj = [self objectForKey: currKey];
		if( [currObj respondsToSelector: @selector(deepCopy)] )
			currObj = [[currObj deepMutableContainerCopy] autorelease];
		else
			currObj = [[currObj copy] autorelease];
		[theDict setObject: currObj forKey: currKey];
	}
	
	return theDict;
}


-(NSMutableDictionary*)  deepMutableCopy
{
	NSMutableDictionary	*	theDict = [[NSMutableDictionary alloc] init];
	NSEnumerator		*	enny = [self keyEnumerator];
	NSString			*	currKey = nil;
	
	while(( currKey = [enny nextObject] ))
	{
		id	currObj = [self objectForKey: currKey];
		if( [currObj respondsToSelector: @selector(deepCopy)] )
			currObj = [[currObj deepMutableCopy] autorelease];
		else
			currObj = [[currObj mutableCopy] autorelease];
		[theDict setObject: currObj forKey: currKey];
	}
	
	return theDict;
}

@end
