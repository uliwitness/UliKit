//
//  NSDictionary+DeepCopy.m
//  UKSyntaxColoredDocument
//
//  Created by Uli Kusterer on Tue May 18 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
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
