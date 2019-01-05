//
//  NSData+URLUserAgent.m
//  Shovel
//
//  Created by Uli Kusterer on 22.03.05.
//  Copyright 2005 M. Uli Kusterer.
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

#import "NSData+URLUserAgent.h"


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
		gUKNSDataDefaultDownloadUserAgent = [[NSString stringWithFormat: @"%@/%@ (UliKit/%@)",
															[mb objectForInfoDictionaryKey: @"CFBundleExecutable"],
															[mb objectForInfoDictionaryKey: @"CFBundleShortVersionString"], [mb objectForInfoDictionaryKey: @"CFBundleVersion"]] retain];
	}
	
	return gUKNSDataDefaultDownloadUserAgent;
}


@end
