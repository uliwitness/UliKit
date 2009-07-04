//
//  UKTextUtilities.h
//  AngelTemplate
//
//  Created by Uli Kusterer on 17.01.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// Turns an encoding name (name of one of the NSStringEncoding constants without
//  the NS... and ...StringEncoding parts) into an NSStringEncoding value. If
//  the string isn't known, returns NSUTF8StringEncoding.
NSStringEncoding    StringEncodingFromName( NSString* encName );
