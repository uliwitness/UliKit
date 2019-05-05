//
//  ULIYAMLParser.h
//  Lanyon
//
//  Created by Uli Kusterer on 21/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NSUInteger	ULIYAMLWritingOptions;	// Set to 0 for now.
typedef NSUInteger	ULIYAMLReadingOptions;	// Set to 0 for now.


NS_ASSUME_NONNULL_BEGIN


@interface ULIYAMLSerialization : NSObject

+ (nullable NSData *)dataWithYAMLObject:(id)obj options:(ULIYAMLWritingOptions)opt error:(NSError **)error;

+ (nullable id)YAMLObjectWithData:(NSData *)data options:(ULIYAMLReadingOptions)opt error:(NSError **)error;

+(NSInteger)	writeYAMLObject: (id)obj toStream: (NSOutputStream *)stream options: (ULIYAMLWritingOptions)opt error: (NSError **)error;	// Returns bytes written.

+(nullable id)	YAMLObjectWithStream: (NSInputStream *)stream options: (ULIYAMLReadingOptions)opt error: (NSError **)error;

@end


extern NSString	*	ULIYAMLSerializationErrorDomain;
enum
{
	ULIYAMLSerializationUnsupportedStreamError = 0
};


NS_ASSUME_NONNULL_END