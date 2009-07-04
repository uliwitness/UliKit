//
//  NSData+URLUserAgent.m
//  Shovel
//
//  Created by Uli Kusterer on 22.03.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "NSData+URLUserAgent.h"
#ifndef SVN_VERSION     // C string with version number.
#import "svn_version.h"
#endif


static NSString*	gUKNSDataDefaultDownloadUserAgent = nil;


@implementation NSData (UKURLUserAgent)

+(id)   dataWithContentsOfURL: (NSURL*)url userAgent: (NSString*)agent
{
    return [[[self alloc] initWithContentsOfURL: url userAgent: agent] autorelease];
}

+(id)   dataWithContentsOfURL: (NSURL*)url userAgent: (NSString*)agent timeout: (NSTimeInterval)timeout
{
    return [[[self alloc] initWithContentsOfURL: url userAgent: agent timeout: timeout] autorelease];
}



-(id)   initWithContentsOfURL: (NSURL*)url userAgent: (NSString*)agent
{
    return [self initWithContentsOfURL: url userAgent: agent timeout: 0];
}


-(id)   initWithContentsOfURL: (NSURL*)url userAgent: (NSString*)agent timeout: (NSTimeInterval)timeout
{
    [self autorelease];	// We'll get a new NSData object from NSURLConnection, so release self.
    
    NSAutoreleasePool   *pool = [[NSAutoreleasePool alloc] init];
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL: url];
    NSString            *boundary = @"0xKhTmLbOuNdArY";
    NSURLResponse       *response = nil;
    NSError             *error = nil;
    NSString            *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    if( !agent )
        agent = [NSData defaultDownloadUserAgent];
	
    // setting the headers:
    [postRequest setHTTPMethod: @"GET"];
    [postRequest setValue: contentType forHTTPHeaderField: @"Content-Type"];
    [postRequest setValue: agent forHTTPHeaderField: @"User-Agent"];
    if( timeout != 0 )
        [postRequest setTimeoutInterval: timeout];
    
    NSData* dt = [[NSURLConnection sendSynchronousRequest: postRequest returningResponse: &response error: &error] retain];
    [pool release];
    
    return dt;
}


+(void)	setDefaultDownloadUserAgent: (NSString*)uaStr
{
	if( uaStr != gUKNSDataDefaultDownloadUserAgent )
	{
		[gUKNSDataDefaultDownloadUserAgent autorelease];
		gUKNSDataDefaultDownloadUserAgent = [uaStr retain];
	}
}

+(NSString*)	defaultDownloadUserAgent
{
	if( !gUKNSDataDefaultDownloadUserAgent )
	{
		NSBundle* mb = [NSBundle mainBundle];
		gUKNSDataDefaultDownloadUserAgent = [[NSString stringWithFormat: @"%@/%@ (UliKit/%s)",
															[mb objectForInfoDictionaryKey: @"CFBundleExecutable"],
															[mb objectForInfoDictionaryKey: @"CFBundleVersion"], SVN_VERSION] retain];
	}
	
	return gUKNSDataDefaultDownloadUserAgent;
}


@end
