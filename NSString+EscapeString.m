//
//  NSString+EscapeString.m
//  ValueConverter
//
//  Created by Uli Kusterer on 27.11.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
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


