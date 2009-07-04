//
//  NSNumber+BytesString.m
//  Filie
//
//  Created by Uli Kusterer on 03.07.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "NSNumber+BytesString.h"


@implementation NSNumber (UKBytesString)

+(NSString*)    bytesStringForInt: (int)bytes
{
    float       finalSize = (float)bytes;
    NSString*   unit = @"bytes";
    
    if( finalSize >= 1024 )
    {
        finalSize /= 1024;
        unit = @"kb";
        if( finalSize >= 1024 )
        {
            finalSize /= 1024;
            unit = @"MB";
        }
    }

    return [NSString stringWithFormat: @"%.2f %@", finalSize, unit];
}

-(NSString*)    bytesString
{
    return [NSNumber bytesStringForInt: [self intValue]];
}

@end
