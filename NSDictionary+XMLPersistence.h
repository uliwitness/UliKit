//
//  NSDictionary+XMLPersistence.h
//  TestPadDataReader
//
//	Created by Uli Kusterer on 07.10.04.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
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