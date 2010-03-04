//
//  UKLoginItemRegistry.h
//  TalkingMoose (XC2)
//
//  Created by Uli Kusterer on 14.03.06.
//  Copyright 2006 Uli Kusterer.
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

#import <Foundation/Foundation.h>
#import "LoginItemsAE.h"

/*
	This class is a wrapper around Apple's LoginItemsAE sample code.
	
	allLoginItems returns an array of dictionaries containing the URL of the
	login item under key UKLoginItemURL and the launch hidden status under
	UKLoginItemHidden.
	
	All methods that return a BOOL generally return YES on success and NO on
	failure.
*/

// -----------------------------------------------------------------------------
//	Constants:
// -----------------------------------------------------------------------------

#define UKLoginItemURL		((NSString*)kLIAEURL)
#define UKLoginItemHidden	((NSString*)kLIAEHidden)


// -----------------------------------------------------------------------------
//	Class Declaration:
// -----------------------------------------------------------------------------

@interface UKLoginItemRegistry : NSObject
{

}

+(NSArray*)	allLoginItems;
+(BOOL)		removeLoginItemAtIndex: (int)idx;

+(BOOL)		addLoginItemWithURL: (NSURL*)url hideIt: (BOOL)hide;
+(int)		indexForLoginItemWithURL: (NSURL*)url;		// Use this to detect whether you've already been set, if needed.
+(BOOL)		removeLoginItemWithURL: (NSURL*)url;

+(BOOL)		addLoginItemWithPath: (NSString*)path hideIt: (BOOL)hide;
+(int)		indexForLoginItemWithPath: (NSString*)path;	// Use this to detect whether you've already been set, if needed.
+(BOOL)		removeLoginItemWithPath: (NSString*)path;

@end
