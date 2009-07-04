//
//  NSStringHTMLEntities.m
//  HTMLTranslator
//
//  Created by Uli Kusterer on Thu Aug 12 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSString+HTMLEntities.h"


@implementation NSString (UKHTMLEntities)

-(NSString*) stringByInsertingHTMLEntities
{
    return [self stringByInsertingHTMLEntitiesAndLineBreaks: YES];
}

-(NSString*) stringByInsertingHTMLEntitiesAndLineBreaks: (BOOL)br
{
	unsigned				count = [self length];
	NSMutableString*		actualText = [NSMutableString stringWithCapacity: count];
	unsigned				x = 0;
	static NSDictionary*	entitiesTable = nil;
	
	if( !entitiesTable )
	{
		NSString*		dictPath = [[NSBundle mainBundle] pathForResource: @"HTMLEntities" ofType: @"plist"];
		entitiesTable = [[NSDictionary dictionaryWithContentsOfFile: dictPath] retain];
	}
	
	for( x = 0; x < count; x++ )
	{
		unichar			theCh = [self characterAtIndex: x];
		NSString*		theChStr = [NSString stringWithCharacters: &theCh length: 1];
		
		if( theCh < 128 && theCh != '&' && theCh != '<'    // Valid ASCII range, and none of the specially escaped ones? Just take it along:
			&& theCh != '>' && theCh != '"' )
        {
            if( br && (theCh == '\r' || theCh == '\n') )
                [actualText appendString: @"<br>\n"];
            else
                [actualText appendString: theChStr];
        }
		else
		{
			NSString*		finalChStr = [entitiesTable objectForKey: theChStr];
			if( !finalChStr )
				[actualText appendString: [NSString stringWithFormat: @"&#%d;", theCh]];
			else
				[actualText appendString: finalChStr];
		}
	}
	
	return actualText;
}

@end
