//
//  ULIYAMLParser.m
//  Lanyon
//
//  Created by Uli Kusterer on 21/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This file requires ARC. Please add the -fobjc-arc compiler option for this file.
#endif


#import "ULIYAMLSerialization.h"



NSString*	ULIYAMLSerializationErrorDomain = @"ULIYAMLSerializationErrorDomain";


@implementation ULIYAMLSerialization

+(nullable NSData *)	dataWithYAMLObject: (id)obj options: (ULIYAMLWritingOptions)opt error: (NSError **)error
{
	NSOutputStream	*	ostr = [[NSOutputStream alloc] initToMemory];
	[ostr open];
	
	[self writeYAMLObject: obj toStream: ostr options: opt error: error];
	NSData			*	outData = [ostr propertyForKey: NSStreamDataWrittenToMemoryStreamKey];
	
	[ostr close];
	return outData;
}


+(nullable id)	YAMLObjectWithData: (NSData *)data options: (ULIYAMLReadingOptions)opt error: (NSError **)error
{
	NSInputStream	*	istr = [[NSInputStream alloc] initWithData: data];
	[istr open];
	
	__nullable id obj = [self YAMLObjectWithStream: istr options: opt error: error];
	
	[istr close];
	return obj;
}


+(NSInteger)	writeYAMLObject: (id)obj toStream: (NSOutputStream *)stream options: (ULIYAMLWritingOptions)opt error: (NSError **)error
{
	NSInteger		bytesWritten = 0;
	
	
	
	return bytesWritten;
}


+ (void)	addPropertiesFromString: (NSMutableString *)yamlString toDictionary: (NSMutableDictionary *)yamlSettings
{
	while (yamlString.length > 0)
	{
		NSRange range = {};
		while( YES )
		{
			range = [yamlString rangeOfCharacterFromSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];
			if (range.location != 0) { break; };
			[yamlString deleteCharactersInRange: range];
		}
		
		if ([yamlString hasPrefix:@"#"])
		{
			NSRange lineEnd = [yamlString rangeOfString:@"\n"];
			if (lineEnd.location == NSNotFound) { break; }
			
			[yamlString deleteCharactersInRange: NSMakeRange(0, NSMaxRange(lineEnd))];
		}
		else
		{
			NSRange labelEnd = [yamlString rangeOfString:@":"];
			if (labelEnd.location == NSNotFound) { break; }
			
			NSString *label = [yamlString substringToIndex:labelEnd.location];
			
			NSRange lineEnd = [yamlString rangeOfString:@"\n" options: 0 range: NSMakeRange(NSMaxRange(labelEnd), yamlString.length - NSMaxRange(labelEnd))];
			if (lineEnd.location == NSNotFound) { break; }
			
			NSString *value = [yamlString substringWithRange:NSMakeRange(NSMaxRange(labelEnd), lineEnd.location - NSMaxRange(labelEnd))];
			[yamlSettings setObject:value forKey:label];
			
			[yamlString deleteCharactersInRange:NSMakeRange(0, NSMaxRange(lineEnd))];
		}
	}
}


+ (nullable id)	YAMLObjectWithStream: (NSInputStream *)stream options: (ULIYAMLReadingOptions)opt error: (NSError **)error
{
	NSMutableDictionary *	yamlSettings = [NSMutableDictionary new];
	NSMutableString		*	yamlString = [NSMutableString string];
	
	while( stream.hasBytesAvailable )
	{
		uint8_t		buf[1024];
		NSUInteger	numBytes = [stream read: buf maxLength: sizeof(buf)];
		if( numBytes == 0 )
			break;
		
		NSString*	currStringFragment = [[NSString alloc] initWithBytes: buf length: numBytes encoding: NSUTF8StringEncoding];
		[yamlString appendString: currStringFragment];
		
		if( [currStringFragment containsString:@"\n"] )
		{
			[self addPropertiesFromString: yamlString toDictionary: yamlSettings];
		}
	}
	[yamlString appendString:@"\n"];
	[self addPropertiesFromString: yamlString toDictionary: yamlSettings];

	return yamlSettings;
}


@end
