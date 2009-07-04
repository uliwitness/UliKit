//
//  NSScreen+ScreenAtPoint.m
//  TalkingMoose (XC2)
//
//  Created by Uli Kusterer on 26.05.06.
//  Copyright 2006 Uli Kusterer. All rights reserved.
//

#import "NSScreen+ScreenAtPoint.h"


@implementation NSScreen (UKScreenAtPoint)

+(NSScreen*)	screenAtPoint: (NSPoint) pos
{
	NSArray*		screens = [NSScreen screens];
	NSEnumerator*	enny = [screens objectEnumerator];
	NSScreen*		currScreen = nil;
	
	while(( currScreen = [enny nextObject] ))
	{
		if( NSPointInRect( pos, [currScreen frame] ) )
			return currScreen;
	}
	
	return nil;
}

@end
