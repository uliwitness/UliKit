//
//  NSData+percentageOfSimilarityTo.m
//  Doublette
//
//  Created by Uli Kusterer on 30.04.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "NSData+percentageOfSimilarityTo.h"


@implementation NSData (UKpercentageOfSimilarityTo)

-(float)    percentageOfSimilarityTo: (NSData*)otherData
{
    if( [self length] != [otherData length] )
        return 0;
    
    int                 numBytes = [self length], x;
    unsigned char   *   myByte = [self bytes],
                    *   otherByte = [otherData bytes];
    float               difference = 0;
    
    for( x = 0; x < numBytes; x++ )
    {
        difference += fabs((*myByte) -(*otherByte)) / (float)numBytes;
        myByte++; otherByte++;
    }
    
    return 1 -difference;
}

@end
