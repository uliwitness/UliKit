//
//  URLHandlerCommand.m
//  UKLicenseMaker
//
//  Created by Uli Kusterer on 16.08.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import "URLHandlerCommand.h"


@implementation URLHandlerCommand

-(id)	performDefaultImplementation
{
    NSURL*	url = [NSURL URLWithString: [self directParameter]];
    
	[(NSObject*)[NSApp delegate] openCustomURL: url];
	
    return nil;
}

@end
