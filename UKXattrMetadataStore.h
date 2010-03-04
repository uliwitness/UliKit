//
//  UKXattrMetadataStore.h
//  BubbleBrowser
//
//  Created by Uli Kusterer on 12.03.06.
//  Copyright 2006 Uli Kusterer. All rights reserved.
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

#import <Cocoa/Cocoa.h>

/*
	This is a wrapper around The Mac OS X 10.4 and later xattr API that lets
	you attach arbitrary metadata to a file. Currently it allows querying and
	changing the attributes of a file, as well as retrieving a list of attribute
	names.
	
	It also includes some conveniences for storing/retrieving UTF8 strings,
	and objects as XML property lists in addition to the raw data.
	
	NOTE: keys (i.e. xattr names) are strings of 127 characters or less and
	should be made like bundle identifiers, e.g. @"de.zathras.myattribute".
*/

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
// -----------------------------------------------------------------------------
//	Class declaration:
// -----------------------------------------------------------------------------

@interface UKXattrMetadataStore : NSObject
{
	
}

+(NSArray*)		allKeysAtPath: (NSString*)path traverseLink:(BOOL)travLnk;

// Store UTF8 strings:
+(void)				setString: (NSString*)str forKey: (NSString*)key
						atPath: (NSString*)path traverseLink:(BOOL)travLnk;
+(id)				stringForKey: (NSString*)key atPath: (NSString*)path
						traverseLink:(BOOL)travLnk;

// Store raw data:
+(void)				setData: (NSData*)data forKey: (NSString*)key
						atPath: (NSString*)path traverseLink:(BOOL)travLnk;
+(NSMutableData*)	dataForKey: (NSString*)key atPath: (NSString*)path
						traverseLink:(BOOL)travLnk;

// Store objects: (Only can get/set plist-type objects for now)â
+(void)				setObject: (id)obj forKey: (NSString*)key atPath: (NSString*)path
						traverseLink:(BOOL)travLnk;
+(id)				objectForKey: (NSString*)key atPath: (NSString*)path
						traverseLink:(BOOL)travLnk;

@end

#endif /*MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4*/
