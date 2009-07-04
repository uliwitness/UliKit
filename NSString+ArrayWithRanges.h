//
//  NSString+ArrayWithRanges.h
//  SVNBrowser
//
//  Created by Uli Kusterer on 14.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (UKArrayWithRanges)

-(NSArray*)	arrayWithRanges: (int)firstEnd, ...;

@end
