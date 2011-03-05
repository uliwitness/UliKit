//
//  ULIMultiMap.h
//  Propaganda
//
//  Created by Uli Kusterer on 21.03.10.
//  Copyright 2010 The Void Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ULIMultiMap : NSObject
{
	NSMutableDictionary*	mDictionary;
}

-(void)		addObject: (id)theObj forKey: (id)theKey;	// Adds it to the list of objects.
-(void)		setObject: (id)theObj forKey: (id)theKey;	// Removes all other objects.

-(void)		removeObject: (id)theObj forKey: (id)theKey;
-(void)		removeObjectsForKey: (id)theKey;
-(void)		removeObject: (id)theObj;

-(NSArray*)	objectsForKey: (id)theKey;

@end
