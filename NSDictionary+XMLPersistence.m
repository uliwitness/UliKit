//
//  NSDictionary+XMLPersistence.m
//  TestPadDataReader
//
//	Created by Uli Kusterer on 07.10.04.
//  Copyright (c) 2004 M. Uli Kusterer.
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

#import "NSDictionary+XMLPersistence.h"
#import "UKXMLPersistence.h"


@implementation NSDictionary (UKXMLPersistence)

+(id)			dictionaryWithXML: (NSString*)str arrayKeys: (NSString**)arr
{
	return [(id) UKCreateDictionaryFromXML( (CFStringRef) str, (CFStringRef*)arr, kUKXMLCreateDictionaryDefaultFlags ) autorelease];
}


+(id)			dictionaryWithXML: (NSString*)str
{
	return [(id) UKCreateDictionaryFromXML( (CFStringRef) str, NULL, kUKXMLCreateDictionaryDefaultFlags ) autorelease];
}


+(id)			dictionaryWithXML: (NSString*)str flags: (unsigned int)flags
{
	return [(id) UKCreateDictionaryFromXML( (CFStringRef) str, NULL, flags ) autorelease];
}



+(id)			dictionaryWithXMLData: (NSData*)data
{
	NSString*	xml = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	return [self dictionaryWithXML: xml];
}


+(id)			dictionaryWithXMLData: (NSData*)data arrayKeys: (NSString**)arr
{
	NSString*	xml = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	return [self dictionaryWithXML: xml arrayKeys: arr];
}


+(id)			dictionaryWithXMLData: (NSData*)data flags: (unsigned int)flags
{
	NSString*	xml = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	return [self dictionaryWithXML: xml flags: flags];
}



+(id)			dictionaryWithContentsOfXMLFile: (NSString*)path
{
	NSString*	str = [NSString stringWithContentsOfFile: path];
	
	return [self dictionaryWithXML: str];
}


+(id)			dictionaryWithContentsOfXMLFile: (NSString*)path arrayKeys: (NSString**)arr
{
	NSString*	str = [NSString stringWithContentsOfFile: path];
	
	return [self dictionaryWithXML: str arrayKeys: arr];
}


+(id)			dictionaryWithContentsOfXMLFile: (NSString*)path flags: (unsigned int)flags
{
	NSString*	str = [NSString stringWithContentsOfFile: path];
	
	return [self dictionaryWithXML: str flags: flags];
}


-(NSString*)	xmlRepresentation
{
	return [(NSString*) UKCreateXMLFromDictionary( (CFDictionaryRef) self, kUKXMLCreateXMLDefaultFlags ) autorelease];
}


-(NSString*)	xmlRepresentationWithFlags: (unsigned int)flags
{
	return [(NSString*) UKCreateXMLFromDictionary( (CFDictionaryRef) self, flags ) autorelease];
}


-(NSData*)	xmlData
{
	NSString* str = [(NSString*) UKCreateXMLFromDictionary( (CFDictionaryRef) self, kUKXMLCreateXMLDefaultFlags ) autorelease];
	return [str dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES];
}


-(NSData*)	xmlDataWithFlags: (unsigned int)flags
{
	NSString* str = [(NSString*) UKCreateXMLFromDictionary( (CFDictionaryRef) self, flags ) autorelease];
	return [str dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES];
}




-(BOOL)			writeToXMLFile: (NSString*)path atomically: (BOOL)atm
{
	NSString*	str = [self xmlRepresentation];
	
	return [str writeToFile: path atomically: atm];
}


-(BOOL)			writeToXMLFile: (NSString*)path atomically: (BOOL)atm flags: (unsigned int)flags
{
	NSString*	str = [self xmlRepresentationWithFlags: flags];
	
	return [str writeToFile: path atomically: atm];
}


@end