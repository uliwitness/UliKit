//
//  UKXattrMetadataStore.m
//  BubbleBrowser
//
//  Created by Uli Kusterer on 12.03.06.
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

#if !__has_feature(objc_arc)
#error this file needs to be compiled with Automatic Reference Counting (ARC)
#endif

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "UKXattrMetadataStore.h"
#include <sys/xattr.h>


// -----------------------------------------------------------------------------
//	Constants:
// -----------------------------------------------------------------------------

const NSInteger ULIMaxXAttrKeyLength = 127;


@implementation UKXattrMetadataStore

+(NSArray*) allKeysAtPath: (NSString*)path traverseLink:(BOOL)travLnk
{
	NSMutableArray<NSString*>*	allKeys = [NSMutableArray array];
	size_t dataSize = listxattr( [path fileSystemRepresentation],
								NULL, ULONG_MAX,
								(travLnk ? 0 : XATTR_NOFOLLOW) );
	if (dataSize == ULONG_MAX) {
		return allKeys;	// Empty list.
	}
	
	NSMutableData*	listBuffer = [NSMutableData dataWithLength: dataSize];
	dataSize = listxattr( [path fileSystemRepresentation],
							[listBuffer mutableBytes], [listBuffer length],
							(travLnk ? 0 : XATTR_NOFOLLOW) );
	
	NSString *allStrKeys = [[NSString alloc] initWithData: listBuffer encoding: NSUTF8StringEncoding];
	[allKeys setArray: [allStrKeys componentsSeparatedByString:@"\0"]];
	if (allKeys.lastObject.length == 0) {
		[allKeys removeLastObject];
	}
	
	return [allKeys copy];
}


+(void) setData: (NSData*)data forKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk
{
	[self setData: data forKey: key atPath: path traverseLink: travLnk error: NULL];
}


+(BOOL) setData: (NSData*)data forKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
	NSAssert(key.length <= ULIMaxXAttrKeyLength, @"Key length limit exceeded.");

	int iErr = setxattr([path fileSystemRepresentation], [key UTF8String],
				[data bytes], [data length],
				0, (travLnk ? 0 : XATTR_NOFOLLOW) );
	if (iErr == -1) {
		if (error) {
			*error = [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: @{NSFilePathErrorKey: path}];
		}
		return NO;
	}
	return YES;
}


+(void)	setObject: (id)obj forKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk
{
	// Serialize our objects into a property list XML string:
	NSString*	errMsg = nil;
	NSData*		plistData = [NSPropertyListSerialization dataFromPropertyList: obj
								format: NSPropertyListXMLFormat_v1_0
								errorDescription: &errMsg];
	if (errMsg) {
		[NSException raise: @"UKXattrMetastoreCantSerialize" format: @"%@", errMsg];
	} else {
		[self setData: plistData forKey: key atPath: path traverseLink: travLnk error: NULL];
	}
}


+(BOOL)	setPlist: (id)obj asXMLForKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
	// Serialize our objects into a property list XML string:
	NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:obj format:NSPropertyListXMLFormat_v1_0 options:0 error:error];

	if (!plistData) {
		//NSPropertyListSerialization should have filled out the error.
		return NO;
	} else {
		return [self setData: plistData forKey: key atPath: path traverseLink: travLnk error: error];
	}
}


+(void)	setString: (NSString*)str forKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk
{
	NSData*		data = [str dataUsingEncoding: NSUTF8StringEncoding];
	
	if( !data ) {
		[NSException raise: NSCharacterConversionException format: @"Couldn't convert string to UTF8 for xattr storage."];
	}
	
	[[self class] setData: data forKey: key atPath: path traverseLink: travLnk error: nil];
}

+(BOOL)	setString: (NSString*)str forKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk error:(NSError * _Nullable __autoreleasing * _Nullable)outError
{
	NSData *data = [str dataUsingEncoding: NSUTF8StringEncoding];
	
	if (!data) {
		if (outError) {
			*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteInapplicableStringEncodingError userInfo:
						 @{NSLocalizedDescriptionKey: @"Couldn't convert string to UTF8 for xattr storage.",
						   NSStringEncodingErrorKey: @(NSUTF8StringEncoding),
						   NSFilePathErrorKey: path}];
		}
		return NO;
	}
	
	return [self setData: data forKey: key atPath: path traverseLink: travLnk error: outError];
}


+(nullable NSData*) dataForKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk
{
	return [self dataForKey:key atPath:path traverseLink:travLnk error:NULL];
}


+(nullable NSData*) dataForKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
	NSAssert(key.length <= ULIMaxXAttrKeyLength, @"Key length limit exceeded.");
	
	size_t		dataSize = getxattr( [path fileSystemRepresentation], [key UTF8String],
									NULL, ULONG_MAX, 0, (travLnk ? 0 : XATTR_NOFOLLOW) );
	if( dataSize == ULONG_MAX ) {
		if (error) {
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSFilePathErrorKey: path}];
		}
		return nil;
	}
	NSMutableData*	data = [[NSMutableData alloc] initWithLength: dataSize];
	dataSize = getxattr( [path fileSystemRepresentation], [key UTF8String],
				[data mutableBytes], [data length], 0, (travLnk ? 0 : XATTR_NOFOLLOW) );
	
	if (dataSize == -1) {
		if (error) {
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSFilePathErrorKey: path}];
		}
		return nil;
	}
	
	return [data copy];
}


+(nullable id) objectForKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk
{
	NSAssert(key.length <= ULIMaxXAttrKeyLength, @"Key length limit exceeded.");
	
	NSError		*err = nil;
	id obj = [self plistForXMLInKey: key atPath: path traverseLink: travLnk error: &err];
	if (!obj) {
		[NSException raise:@"UKXattrMetastoreCantUnserialize" format: @"%@", err];
	}
	
	return obj;
}

+(nullable id) plistForXMLInKey: (NSString*)key atPath: (NSString*)path
			   traverseLink: (BOOL)travLnk error: (NSError * _Nullable __autoreleasing * _Nullable)outError
{
	NSAssert(key.length <= ULIMaxXAttrKeyLength, @"Key length limit exceeded.");
	
	NSData *data = [[self class] dataForKey: key atPath: path traverseLink: travLnk error: outError];
	if (!data) {
		//The dataForKey:... method should have filled out the error variable.
		return nil;
	}
	NSPropertyListFormat	outFormat = NSPropertyListXMLFormat_v1_0;

	id obj = [NSPropertyListSerialization propertyListWithData: data options: NSPropertyListImmutable format: &outFormat error: outError];
	if (!obj) {
		//The propertyListWithData:... method should have filled out the error variable.
		return nil;
	}
	
	return obj;
}


+(nullable NSString*) stringForKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk
{
	NSData *data = [[self class] dataForKey: key atPath: path traverseLink: travLnk error: nil];
	if (!data) {
		return nil;
	}
	
	return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}


+(nullable NSString*) stringForKey: (NSString*)key atPath: (NSString*)path traverseLink:(BOOL)travLnk error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
	NSAssert(key.length <= ULIMaxXAttrKeyLength, @"Key length limit exceeded.");
	
	NSData *data = [[self class] dataForKey: key atPath: path traverseLink: travLnk error: error];
	
	if (!data) {
		//The dataForKey:... method should have filled out the error variable.
		return nil;
	}
	
	NSString *toRet = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	if (!toRet) {
		if (error) {
			*error = [NSError errorWithDomain: NSCocoaErrorDomain
										 code: NSFileReadInapplicableStringEncodingError
									 userInfo:
					  @{NSStringEncodingErrorKey: @(NSUTF8StringEncoding),
						NSFilePathErrorKey: path}];
		}
	}
	
	return toRet;
}

@end
