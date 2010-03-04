//
//  NSString+EscapeString.m
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

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "NSString+EscapeString.h"


@implementation NSString (UKEscapeString)

-(NSString*)    escapedString
{
    return [self escapedStringUppercase: NO];
}

-(NSString*)    uppercaseEscapedString
{
    return [self escapedStringUppercase: YES];
}

-(NSString*)    escapedStringUppercase: (BOOL)uc
{
    NSMutableString*    outStr = [NSMutableString string];
    int                 x, count = [self length];
    
    for( x = 0; x < count; x++ )
    {
        unichar ch = [self characterAtIndex: x];
        if( ch >= 0x20 && ch != '\\' )
            [outStr appendString: [NSString stringWithCharacters: &ch length: 1]];
        else
        {
            switch( ch )
            {
                case 0:
                    [outStr appendString: @"\\0"];
                    break;
                
                case '\n':
                    [outStr appendString: @"\\n"];
                    break;
                
                case '\r':
                    [outStr appendString: @"\\r"];
                    break;
                
                case '\t':
                    [outStr appendString: @"\\t"];
                    break;
                
                case '\\':
                    [outStr appendString: @"\\\\"];
                    break;
                
                default:
                    [outStr appendString: [NSString stringWithFormat: (uc ? @"\\x%02X" : @"\\x%02x"), (int)ch]];
            }
        }
    }
    
    return outStr;
}


-(NSString*)    unescapedString
{
    NSMutableString*    outStr = [NSMutableString string];
    int                 x, count = [self length];
    
    for( x = 0; x < count; x++ )
    {
        unichar ch = [self characterAtIndex: x];
        if( ch != '\\' )
            [outStr appendString: [NSString stringWithCharacters: &ch length: 1]];
        else
        {
            x++;
            if( x > count )
                break;
            ch = [self characterAtIndex: x];
            if( ch == 'x' ) // Hex.
            {
                x++;
                if( x <= (count -2) )
                {
                    ch = [self characterAtIndex: x++];
                    unichar ch2 = [self characterAtIndex: x];
                    ch = (UKHexToDec(ch) *16) +UKHexToDec(ch2);
                    [outStr appendString: [NSString stringWithCharacters: &ch length: 1]];
                }
            }
            else
            {
                switch( ch )
                {
                    case '0':
                        ch = 0;
                        break;
                    case 'n':
                        ch = '\n';
                        break;
                    case 'r':
                        ch = '\r';
                        break;
                    case 't':
                        ch = '\t';
                        break;
                }
                [outStr appendString: [NSString stringWithCharacters: &ch length: 1]];
            }
        }
    }
    
    return outStr;
}

@end


// Turn a hex-digit character into the corresponding decimal number:
int UKHexToDec( char n )
{
    if( n >= '0' && n <= '9' )
        return n - '0';
    else if( n >= 'A' && n <= 'F' ) // Allow uppercase...
        return 10 +(n -'A');
    else if( n >= 'a' && n <= 'f' ) // ... and lowercase.
        return 10 +(n -'a');
    else
        return 0;
}


