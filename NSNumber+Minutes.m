//
//  NSNumber+Minutes.m
//  MovieTheatre
//
//  Created by Uli Kusterer on 25.06.05.
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
