//
//  NSDictionary+XMLPersistence.h
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

/*
	Category on NSDictionary that allows saving a dictionary to a very readable
	XML file, where the dictionary keys are the tags and the values the contents.
*/

#import <Foundation/Foundation.h>


@interface NSDictionary (UKXMLPersistence)

+(id)			dictionaryWithXML: (NSString*)str;
+(id)			dictionaryWithXML: (NSString*)str arrayKeys: (NSString**)arr;
+(id)			dictionaryWithXML: (NSString*)str flags: (unsigned int)flags;
+(id)			dictionaryWithXMLData: (NSData*)str;
+(id)			dictionaryWithXMLData: (NSData*)str arrayKeys: (NSString**)arr;
+(id)			dictionaryWithXMLData: (NSData*)str flags: (unsigned int)flags;

+(id)			dictionaryWithContentsOfXMLFile: (NSString*)path;
+(id)			dictionaryWithContentsOfXMLFile: (NSString*)path arrayKeys: (NSString**)arr;
+(id)			dictionaryWithContentsOfXMLFile: (NSString*)path flags: (unsigned int)flags;

-(NSString*)	xmlRepresentation;
-(NSString*)	xmlRepresentationWithFlags: (unsigned int)flags;
-(NSData*)		xmlData;
-(NSData*)		xmlDataWithFlags: (unsigned int)flags;

-(BOOL)			writeToXMLFile: (NSString*)path atomically: (BOOL)atm;
-(BOOL)			writeToXMLFile: (NSString*)path atomically: (BOOL)atm flags: (unsigned int)flags;

@end