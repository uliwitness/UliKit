//
//  NSString+TruncatedForWidthWithAttributesMode.m
//  xTableImage
//
//  Created by Uli Kusterer on 28.09.06.
//  Copyright 2006 Uli Kusterer.
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

#import "NSString+TruncatedForWidthWithAttributesMode.h"


@implementation NSString (UKTruncatedForWidthWithAttributesMode)

// -----------------------------------------------------------------------------
//  Returns a truncated version of the specified string that fits a width:
//		Appends/Inserts three periods as an "ellipsis" to/in the string to
//      indicate when and where it was truncated.
// -----------------------------------------------------------------------------

-(NSString*)	truncatedForWidth: (int)wid withAttributes: (NSDictionary*)attrs
					mode: (NSLineBreakMode)truncateMode
{
	NSSize				txSize = [self sizeWithAttributes: attrs];
    
    if( txSize.width <= wid )   // Don't do anything if it fits.
        return self;
    
	NSMutableString*	currString = [NSMutableString string];
	NSRange             rangeToCut = { 0, 0 };
    
    if( truncateMode == NSLineBreakByTruncatingTail )
    {
        rangeToCut.location = [self length] -1;
        rangeToCut.length = 1;
    }
    else if( truncateMode == NSLineBreakByTruncatingHead )
    {
        rangeToCut.location = 0;
        rangeToCut.length = 1;
    }
    else    // NSLineBreakByTruncatingMiddle
    {
        rangeToCut.location = [self length] / 2;
        rangeToCut.length = 1;
    }
    
	while( txSize.width > wid )
	{
		if( truncateMode != NSLineBreakByTruncatingHead && rangeToCut.location <= 1 )
			return @"...";
        
        [currString setString: self];
        [currString replaceCharactersInRange: rangeToCut withString: @"..."];
		txSize = [currString sizeWithAttributes: attrs];
        rangeToCut.length++;
        if( truncateMode == NSLineBreakByTruncatingHead )
            ;   // No need to fix location, stays at start.
        else if( truncateMode == NSLineBreakByTruncatingTail )
            rangeToCut.location--;  // Fix location so range that's one longer still lies inside our string at end.
        else if( (rangeToCut.length & 1) != 1 )     // even? NSLineBreakByTruncatingMiddle
            rangeToCut.location--;  // Move location left every other time, so it grows to right and left and stays centered.
        
        if( rangeToCut.location < 0 || (rangeToCut.location +rangeToCut.length) > [self length] )
            return @"...";
	}
	
	return currString;
}

@end
