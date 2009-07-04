//
//  NSString+EscapeString.h
//  ValueConverter
//
//  Created by Uli Kusterer on 27.11.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

/*
    Escape any non-ASCII characters in a string for use in e.g. C source code.
    Some known characters get symbolic names like \n, all others are turned into
    Hex (\x0F). The uppercase/lowercase parts of the names refer to the hex
    strings generated, which can be \xAF or \xaf etc.
    
    Currently, only one-byte characters are encoded correctly. The high byte is
    stripped.
*/

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Categories:
// -----------------------------------------------------------------------------

@interface NSString (UKEscapeString)

-(NSString*)    escapedString;
-(NSString*)    uppercaseEscapedString;
-(NSString*)    escapedStringUppercase: (BOOL)uc;

-(NSString*)    unescapedString;    // Restores escaped string to normal.


@end


// -----------------------------------------------------------------------------
//  Prototypes:
// -----------------------------------------------------------------------------

int UKHexToDec( char n );