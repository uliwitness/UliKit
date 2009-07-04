//
//  NSData+percentageOfSimilarityTo.h
//  Doublette
//
//  Created by Uli Kusterer on 30.04.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSData (UKpercentageOfSimilarityTo)

// Compares this object to another one of same length and returns how similar
//  they are (0.0 not at all, 1.0 the same). If they have different lengths,
//  this returns 0.0.

-(float)    percentageOfSimilarityTo: (NSData*)otherData;

@end
