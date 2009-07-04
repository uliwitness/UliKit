//
//  NSData+URLUserAgent.h
//  Shovel
//
//  Created by Uli Kusterer on 22.03.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSData (UKURLUserAgent)

+(id)   dataWithContentsOfURL: (NSURL*)url userAgent: (NSString*)agent; // agent may be NIL to build a default agent string.
+(id)   dataWithContentsOfURL: (NSURL*)url userAgent: (NSString*)agent timeout: (NSTimeInterval)timeout;

-(id)   initWithContentsOfURL: (NSURL*)url userAgent: (NSString*)agent; // agent may be NIL to build a default agent string.
-(id)   initWithContentsOfURL: (NSURL*)url userAgent: (NSString*)agent timeout: (NSTimeInterval)timeout;

// Default user agent used when userAgent: parameter is NIL:
+(void)			setDefaultDownloadUserAgent: (NSString*)uaStr;
+(NSString*)	defaultDownloadUserAgent;

@end
