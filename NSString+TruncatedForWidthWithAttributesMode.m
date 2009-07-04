//
//  NSString+TruncatedForWidthWithAttributesMode.m
//  xTableImage
//
//  Created by Uli Kusterer on 28.09.06.
//  Copyright 2006 M. Uli Kusterer. All rights reserved.
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
