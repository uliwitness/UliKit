//
//  NSNumber+Minutes.m
//  MovieTheatre
//
//  Created by Uli Kusterer on 25.06.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "NSNumber+Minutes.h"


@implementation NSNumber (UKMinutes)

-(NSString*)    secondsString
{
    return [NSNumber secondsStringForInt: [self intValue]];
}


+(NSString*)    secondsStringForInt: (int)secs
{
    NSString*   signStr = @"";
    if( secs < 0 )
    {
        secs *= -1;
        signStr = @"-";
    }
    
    int     mins, hours, remSecs;
    
    remSecs = secs % 60;
    mins = secs / 60;
    hours = mins / 60;
    mins = mins % 60;
    
    if( hours > 0 )
        return [NSString stringWithFormat: @"%@%d:%02d:%02d hours", signStr, hours, mins, remSecs];
    else if( mins > 0 )
        return [NSString stringWithFormat: @"%@%d:%02d minutes", signStr, mins, remSecs];
    else
        return [NSString stringWithFormat: @"%@%d seconds", signStr, remSecs];
}


@end
