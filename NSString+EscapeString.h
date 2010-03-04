//
//  NSString+EscapeString.h
//  ValueConverter
//
//  Created by Uli Kusterer on 27.11.04.
//  Copyright 2004 Uli Kusterer.
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