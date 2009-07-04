//
//  NSNumber+Minutes.h
//  MovieTheatre
//
//  Created by Uli Kusterer on 25.06.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSNumber (UKMinutes)

+(NSString*)    secondsStringForInt: (int)secs;
-(NSString*)    secondsString;      // Turns a number of seconds into [HH:[MM:]]SS.

@end
