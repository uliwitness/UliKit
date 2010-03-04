//
//  NSString+EscapedStringForCommandLine.m
//  MayaFTP
//
//  Created by Uli Kusterer on Fri Aug 27 2004.
//  Copyright (c) 2004 M. Uli Kusterer.
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

#import "NSString+EscapedStringForCommandLine.h"


void	EscapeCharInNSString( char pattern, NSMutableString* outstr );


@implementation NSString (UKEscapedStringForCommandLine)

/* -----------------------------------------------------------------------------
    escapedStringForCommandline:
        Generates a new copy of the string that has all characters that are
		not safe for the command line escaped using a backslash.
    
    REVISIONS:
		2004-08-27  UK  Converted from CocoaTADS function and extracted into
						NSString and NSMutableString categories.
        2002-10-03	UK	Created.
   -------------------------------------------------------------------------- */

-(NSString*)	escapedStringForCommandline
{
	NSMutableString*	outstr = [self mutableCopy];
	
	[outstr escapeForCommandline];
	
	return outstr;
}

@end


@implementation NSMutableString (UKEscapeForCommandLine)


/* -----------------------------------------------------------------------------
    escapeForCommandline:
        Escape all critical characters in this string so we can use it unquoted
		on the command line.
    
    REVISIONS:
		2004-08-27  UK  Extracted from escapedStringForCommandline.
        2002-10-03	UK	Created.
   -------------------------------------------------------------------------- */

-(void)	escapeForCommandline;
{
	EscapeCharInNSString( '\\', self );
	EscapeCharInNSString( ' ', self );
	EscapeCharInNSString( '\t', self );
	EscapeCharInNSString( '\n', self );
	EscapeCharInNSString( '\r', self );
	EscapeCharInNSString( '|', self );
}

@end


/* -----------------------------------------------------------------------------
    EscapeCharInNSString:
        Find all occurences of the specified character in a string and prefix
		them with a backslash each.
    
    REVISIONS:
        2002-10-03	UK	Created.
   -------------------------------------------------------------------------- */

void	EscapeCharInNSString( char pattern, NSMutableString* outstr )
{
	NSRange		vFoundChunk,
				vSearchArea = { 0, [outstr length] };
	
	while( true )
	{
		vFoundChunk = [outstr rangeOfString:[NSString stringWithCString:&pattern length:1] options:0 range:vSearchArea];
		if( (vFoundChunk.location == NSNotFound) && (vFoundChunk.length == 0) )
			break;
		[outstr insertString:@"\\" atIndex: vFoundChunk.location];
		vSearchArea.location = vFoundChunk.location +vFoundChunk.length +1;
		vSearchArea.length = [outstr length] -vSearchArea.location;
	}
}


