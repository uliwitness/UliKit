//
//  NSArray+DeepCopy.m
//  UKSyntaxColoredDocument
//
//  Created by Uli Kusterer on Tue May 18 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "NSArray+DeepCopy.h"


@implementation NSArray (UKDeepCopy)

-(NSArray*)  deepCopy
{
	NSMutableArray	*	theArray = [[NSMutableArray alloc] initWithCapacity: [self count]];
	NSEnumerator	*	enny = [self objectEnumerator];
	id					currObj = nil;
	
	while(( currObj = [enny nextObject] ))
	{
		if( [currObj respondsToSelector: @selector(deepCopy)] )
			currObj = [[currObj deepCopy] autorelease];
		else
			currObj = [[currObj copy] autorelease];
		[theArray addObject: currObj];
	}
	
	return theArray;
}


-(NSMutableArray*)  deepMutableContainerCopy
{
	NSMutableArray	*	theArray = [[NSMutableArray alloc] init];
	NSEnumerator	*	enny = [self objectEnumerator];
	id					currObj = nil;
	
	while(( currObj = [enny nextObject] ))
	{
		if( [currObj respondsToSelector: @selector(deepCopy)] )
			currObj = [[currObj deepMutableContainerCopy] autorelease];
		else
			currObj = [[currObj copy] autorelease];
		[theArray addObject: currObj];
	}
	
	return theArray;
}


-(NSMutableArray*)  deepMutableCopy
{
	NSMutableArray	*	theArray = [[NSMutableArray alloc] init];
	NSEnumerator	*	enny = [self objectEnumerator];
	id					currObj = nil;
	
	while(( currObj = [enny nextObject] ))
	{
		if( [currObj respondsToSelector: @selector(deepCopy)] )
			currObj = [[currObj deepMutableCopy] autorelease];
		else
			currObj = [[currObj mutableCopy] autorelease];
		[theArray addObject: currObj];
	}
	
	return theArray;
}

@end
