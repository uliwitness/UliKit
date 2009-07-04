//
//  NSURLConnection+PostDictionary.m
//  PosterChild
//
//  Created by Uli Kusterer on 22.03.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import "NSURLConnection+PostDictionary.h"
#import "svn_version.h"


@implementation NSURLConnection (UKPostDictionary)

// -----------------------------------------------------------------------------
//  connectionPostingDictionary:toURL:delegate:
//      Posts the key-value pairs in the specified dictionary as multipart-form
//      data to the specified URL and returns the NSURLConnection object used
//      for that.
//
//      They keys in the dictionary are used as the field names, the values as
//      the field contents. If a field value is an NSURL, the contents of the
//      file at that URL will be posted as if a file upload form had been used.
//
//      To get at any data returned by the form, use the
//      connection:didReceiveData: delegate method.
//
//  REVISIONS:
//      2005-03-22  UK  Created.
// -----------------------------------------------------------------------------

+(id) connectionPostingDictionary: (NSDictionary*)dict toURL: (NSURL*)url delegate: (id)dele
{
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL: url];
    NSString            *boundary = @"0xKhTmLbOuNdArY";	// TODO: Might look for this and generate one that's guaranteed not to be in our data.
    NSString            *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    NSString            *userAgent = [NSString stringWithFormat: @"%@/%@ (UliKit/%s)", [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleExecutable"], [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"], SVN_VERSION];

    // setting the headers:
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue: contentType forHTTPHeaderField: @"Content-Type"];
    [postRequest setValue: userAgent forHTTPHeaderField: @"User-Agent"];

    // adding the body:
    NSMutableData   *postBody = [NSMutableData data];
    NSEnumerator    *keyEnny = [dict keyEnumerator];
    NSString        *key = nil;
    
    while( (key = [keyEnny nextObject]) )
    {
        NSString*      obj = [dict objectForKey: key];
        
        [postBody appendData: [[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        if( [obj isKindOfClass: [NSURL class]] )
        {
            NSString*   fname = [[(NSURL*)obj path] lastPathComponent];
            [postBody appendData: [[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", key, fname] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData: [NSData dataWithContentsOfURL: (NSURL*)obj]];
        }
        else
        {
            [postBody appendData: [[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData: [obj dataUsingEncoding: NSUTF8StringEncoding]];
        }
        [postBody appendData: [@"\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
    }

    [postRequest setHTTPBody:postBody];

    return [NSURLConnection connectionWithRequest: postRequest delegate: dele];
}

@end
