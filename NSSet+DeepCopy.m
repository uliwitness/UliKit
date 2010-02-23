//
//  NSSet+DeepCopy.m
//  UKSyntaxColoredDocument
//
//  Created by Uli Kusterer on Tue May 18 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "NSSet+DeepCopy.h"


@implementation NSSet (UKDeepCopy)

-(NSSet*)  deepCopy
{
	NSMutableSet	*	theSet = [[NSMutableSet alloc] initWithCapacity: [self count]];
	NSEnumerator	*	enny = [self objectEnumerator];
	id					currObj = nil;
	
	while(( currObj = [enny nextObject] ))
	{
		if( [currObj respondsToSelector: @selector(deepCopy)] )
			currObj = [[currObj deepCopy] autorelease];
		else
			currObj = [[currObj copy] autorelease];
		[theSet addObject: currObj];
	}
	
	return theSet;
}


-(NSMutableSet*)  deepMutableContainerCopy
{
	NSMutableSet	*	theSet = [[NSMutableSet alloc] init];
	NSEnumerator	*	enny = [self objectEnumerator];
	id					currObj = nil;
	
	while(( currObj = [enny nextObject] ))
	{
		if( [currObj respondsToSelector: @selector(deepCopy)] )
			currObj = [[currObj deepMutableContainerCopy] autorelease];
		else
			currObj = [[currObj copy] autorelease];
		[theSet addObject: currObj];
	}
	
	return theSet;
}


-(NSMutableSet*)  deepMutableCopy
{
	NSMutableSet	*	theSet = [[NSMutableSet alloc] init];
	NSEnumerator	*	enny = [self objectEnumerator];
	id					currObj = nil;
	
	while(( currObj = [enny nextObject] ))
	{
		if( [currObj respondsToSelector: @selector(deepCopy)] )
			currObj = [[currObj deepMutableCopy] autorelease];
		else
			currObj = [[currObj mutableCopy] autorelease];
		[theSet addObject: currObj];
	}
	
	return theSet;
}

@end
