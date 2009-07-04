//
//  UKApplicationEnumerator.h
//  Shovel
//
//  Created by Uli Kusterer on Wed Mar 31 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
	Create one of these and use it just like an NSDirectoryEnumerator.
	
	This uses a private SPI in LaunchServices to get the list of apps. If it
	can't be found (i.e. Apple removed it in a new system version) it will
	fail and return NIL from -init, so be prepared for that.
*/


@interface UKApplicationEnumerator : NSObject
{
	NSEnumerator*		appsEnny;			// Enumerator for item array.
	NSArray*			appsArray;			// Array of applications.
	NSString*			currApp;			// Application at last queried enumerator position.
	NSMetadataQuery*	query;				// Metadata query we're running to find apps.
	int					currIndex;			// Current index in query we're working through.
	int					currIndexInCache;	// Current index in appsArray we're working through.
}

-(NSString*)		nextObject;
-(NSDictionary*)	fileAttributes;
-(void)				skipDescendents;

@end
