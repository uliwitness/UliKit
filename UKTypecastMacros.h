//
//  UKTypecastMacros.h
//
//  Created by Uli Kusterer on 11.04.2010
//  Copyright 2010 Uli Kusterer.
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

/*
	This file contains inline functions that make typecasts between toll-free
	bridged types type-safe. This works by simply wrapping them in a function,
	which then performs type-checking, so when you give it an NSURL* instead
	of an NSString* it will complain, not silently cast it away.
*/


#import <Foundation/Foundation.h>



// NSNumber:
NS_INLINE CFNumberRef	UKNSToCFNumber( NSNumber* inNumber )
{
	return (CFNumberRef)inNumber;
}


NS_INLINE NSNumber*	UKCFToNSNumber( CFNumberRef inNumber )
{
	return (NSNumber*)inNumber;
}


// NSData:
NS_INLINE CFDataRef	UKNSToCFData( NSData* inData )
{
	return (CFDataRef)inData;
}


NS_INLINE NSData*	UKCFToNSData( CFDataRef inData )
{
	return (NSData*)inData;
}


// NSMutableData:
NS_INLINE CFMutableDataRef	UKNSToCFMutableData( NSMutableData* inMutableData )
{
	return (CFMutableDataRef)inMutableData;
}


NS_INLINE NSMutableData*	UKCFToNSMutableData( CFMutableDataRef inMutableData )
{
	return (NSMutableData*)inMutableData;
}


// NSString:
NS_INLINE CFStringRef	UKNSToCFString( NSString* inString )
{
	return (CFStringRef)inString;
}


NS_INLINE NSString*	UKCFToNSString( CFStringRef inString )
{
	return (NSString*)inString;
}


// NSMutableString:
NS_INLINE CFMutableStringRef	UKNSToCFMutableString( NSMutableString* inMutableString )
{
	return (CFMutableStringRef)inMutableString;
}


NS_INLINE NSMutableString*	UKCFToNSMutableString( CFMutableStringRef inMutableString )
{
	return (NSMutableString*)inMutableString;
}


// NSAttributedString:
NS_INLINE CFAttributedStringRef	UKNSToCFAttributedString( NSAttributedString* inAttributedString )
{
	return (CFAttributedStringRef)inAttributedString;
}


NS_INLINE NSAttributedString*	UKCFToNSAttributedString( CFAttributedStringRef inAttributedString )
{
	return (NSAttributedString*)inAttributedString;
}


// NSMutableAttributedString:
NS_INLINE CFMutableAttributedStringRef	UKNSToCFMutableAttributedString( NSMutableAttributedString* inMutableAttributedString )
{
	return (CFMutableAttributedStringRef)inMutableAttributedString;
}


NS_INLINE NSMutableAttributedString*	UKCFToNSMutableAttributedString( CFMutableAttributedStringRef inMutableAttributedString )
{
	return (NSMutableAttributedString*)inMutableAttributedString;
}


// NSURL:
NS_INLINE CFURLRef	UKNSToCFURL( NSURL* inURL )
{
	return (CFURLRef)inURL;
}


NS_INLINE NSURL*	UKCFToNSURL( CFURLRef inURL )
{
	return (NSURL*)inURL;
}


// NSDictionary:
NS_INLINE CFDictionaryRef	UKNSToCFDictionary( NSDictionary* inDictionary )
{
	return (CFDictionaryRef)inDictionary;
}


NS_INLINE NSDictionary*	UKCFToNSDictionary( CFDictionaryRef inDictionary )
{
	return (NSDictionary*)inDictionary;
}


// NSMutableDictionary:
NS_INLINE CFMutableDictionaryRef	UKNSToCFMutableDictionary( NSMutableDictionary* inMutableDictionary )
{
	return (CFMutableDictionaryRef)inMutableDictionary;
}


NS_INLINE NSMutableDictionary*	UKCFToNSMutableDictionary( CFMutableDictionaryRef inMutableDictionary )
{
	return (NSMutableDictionary*)inMutableDictionary;
}


// NSArray:
NS_INLINE CFArrayRef	UKNSToCFArray( NSArray* inArray )
{
	return (CFArrayRef)inArray;
}


NS_INLINE NSArray*	UKCFToNSArray( CFArrayRef inArray )
{
	return (NSArray*)inArray;
}


// NSMutableArray:
NS_INLINE CFMutableArrayRef	UKNSToCFMutableArray( NSMutableArray* inMutableArray )
{
	return (CFMutableArrayRef)inMutableArray;
}


NS_INLINE NSMutableArray*	UKCFToNSMutableArray( CFMutableArrayRef inMutableArray )
{
	return (NSMutableArray*)inMutableArray;
}


// NSSet:
NS_INLINE CFSetRef	UKNSToCFSet( NSSet* inSet )
{
	return (CFSetRef)inSet;
}


NS_INLINE NSSet*	UKCFToNSSet( CFSetRef inSet )
{
	return (NSSet*)inSet;
}


// NSMutableSet:
NS_INLINE CFMutableSetRef	UKNSToCFMutableSet( NSMutableSet* inMutableSet )
{
	return (CFMutableSetRef)inMutableSet;
}


NS_INLINE NSMutableSet*	UKCFToNSMutableSet( CFMutableSetRef inMutableSet )
{
	return (NSMutableSet*)inMutableSet;
}


