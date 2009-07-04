//
//  NSString+PathCombiningExtensions.h
//  VerpackIt
//
//  Created by Uli Kusterer on 18.09.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (UKPartialPaths)

-(NSString*)	stringByCombiningWithPartialPath: (NSString*)inPartial;
-(NSString*)	stringBySubtractingBasePath: (NSString*)basePath;

-(int)			upwardsDepth;

@end

@interface NSArray (UKPartialPaths)

// If any entry in an array of paths contains "../" 'go-up entries', this returns how many there are.
// Use this to find out how many folders you have to create around this one not to run out of paths.
-(int)			maxUpwardsDepth;	// Calls upwardsDepth on each path and returns the maximum.

@end