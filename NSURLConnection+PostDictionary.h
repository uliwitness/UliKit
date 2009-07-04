//
//  NSURLConnection+PostDictionary.h
//  PosterChild
//
//  Created by Uli Kusterer on 22.03.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSURLConnection (UKPostDictionary)

+(id) connectionPostingDictionary: (NSDictionary*)dict toURL: (NSURL*)url delegate: (id)dele;

@end
