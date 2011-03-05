//
//  ULIMultiMap.m
//  Propaganda
//
//  Created by Uli Kusterer on 21.03.10.
//  Copyright 2010 The Void Software. All rights reserved.
//

#import "ULIMultiMap.h"


@implementation ULIMultiMap

-(void)		addObject: (id)theObj forKey: (id)theKey
{
	if( !mDictionary )
		mDictionary = [[NSMutableDictionary alloc] init];
	
	NSMutableArray*	arr = [mDictionary objectForKey: theKey];
	if( !arr )
	{
		arr = [NSMutableArray arrayWithObject: theObj];
		[mDictionary setObject: arr forKey: theKey];
	}
	else
		[arr addObject: theObj];
}


-(void)		setObject: (id)theObj forKey: (id)theKey
{
	if( !mDictionary )
		mDictionary = [[NSMutableDictionary alloc] init];
	
	[mDictionary setObject: [NSMutableArray arrayWithObject: theObj]
					forKey: theKey];
}


-(void)		removeObject: (id)theObj forKey: (id)theKey
{
	if( !mDictionary )
		return;
	
	NSMutableArray*	arr = [mDictionary objectForKey: theKey];
	if( !arr )
		return;
	
	[arr removeObject: theObj];
}


-(void)		removeObjectsForKey: (id)theKey;
{
	[mDictionary removeObjectForKey: theKey];
}


-(void)		removeObject: (id)theObj
{
	for( NSMutableArray* arr in [mDictionary allValues] )
		[arr removeObject: theObj];
}

-(NSArray*)	objectsForKey: (id)theKey
{
	return [mDictionary objectForKey: theKey];
}

@end
