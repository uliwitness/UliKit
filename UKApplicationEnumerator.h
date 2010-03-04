//
//  UKApplicationEnumerator.h
//  Shovel
//
//  Created by Uli Kusterer on Wed Mar 31 2004.
//  Copyright (c) 2004 Uli Kusterer.
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
