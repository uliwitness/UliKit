//
//  NSAttributedString+HTMLFromRange.m
//  PosterChild
//
//  Created by Uli Kusterer on 22.03.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "NSAttributedString+HTMLFromRange.h"
#import "NSString+HTMLEntities.h"


@implementation NSAttributedString (UKHTMLFromRange)

NSString* FontSizeToHTMLSize( NSFont* fnt )
{
    int     intSize = [fnt pointSize];
    
    if( intSize <= 9 )
        return @"-2";
    if( intSize <= 12 )
        return @"-1";
    if( intSize <= 14 )
        return @"4";
    if( intSize <= 16 )
        return @"+1";
    if( intSize > 16 )
        return @"+2";
    else
        return @"4";
}

NSString* ColorToHTMLColor( NSColor* tcol )
{
    NSColor*    rgbColor = [tcol colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    float       r, g, b, a;
    
    [rgbColor getRed: &r green: &g blue: &b alpha: &a];
    
    return [NSString stringWithFormat:@"#%2.2X%2.2X%2.2X", (int)(255 * r), (int)(255 * g), (int)(255 * b)];
}

-(NSString*)    HTMLFromRange: (NSRange)range
{
    unsigned int                location = 0;
    NSRange                     effRange;
    NSMutableString*            str = [NSMutableString string];
    NSMutableString*            endStr = [NSMutableString string];
    NSDictionary*               attrs = nil;
    NSDictionary*               oldAttrs = nil;
    
    unsigned int    finalLen = range.location +range.length;
    
    // TODO: Use oldAttrs, add NSForegroundColorAttributeName and 
    
    attrs = [self attributesAtIndex: location effectiveRange: &effRange];
    location = effRange.location +effRange.length;
    
    // Oblique changed?
    NSNumber* obliq = [attrs objectForKey: NSObliquenessAttributeName];
    if( obliq && obliq != [oldAttrs objectForKey: NSObliquenessAttributeName]
        && [obliq floatValue] > 0 )
    {
        [str appendString: @"<sup>"];
        [endStr insertString: @"</sup>" atIndex: 0];
    }
    // Font/color changed?
    NSFont* fnt = [attrs objectForKey: NSFontAttributeName];
    NSColor* tcol = [attrs objectForKey: NSForegroundColorAttributeName];
    if( fnt || tcol )
    {
        [str appendString: @"<font"];
        if( fnt )
        {
            [str appendFormat: @" face=\"%@\"", [fnt familyName]];
            [str appendFormat: @" size=\"%@\"", FontSizeToHTMLSize(fnt)];
        }
        if( tcol )
        {
            [str appendFormat: @" color=\"%@\"", ColorToHTMLColor(tcol)];
        }
        [str appendString: @">"];
        [endStr insertString: @"</font>" atIndex: 0];

        NSFontTraitMask trt = [[NSFontManager sharedFontManager] traitsOfFont: fnt];
        if( (trt & NSItalicFontMask) == NSItalicFontMask )
        {
            if( !obliq || [obliq floatValue] == 0 ) // Don't apply twice.
            {
                [str appendString: @"<i>"];
                [endStr insertString: @"</i>" atIndex: 0];
            }
        }
        if( (trt & NSBoldFontMask) == NSBoldFontMask
            || [[NSFontManager sharedFontManager] weightOfFont: fnt] >= 9 )
        {
            [str appendString: @"<b>"];
            [endStr insertString: @"</b>" atIndex: 0];
        }
        if( (trt & NSFixedPitchFontMask) == NSFixedPitchFontMask )
        {
            [str appendString: @"<tt>"];
            [endStr insertString: @"</tt>" atIndex: 0];
        }
    }
    // Superscript changed?
    NSNumber* supers = [attrs objectForKey: NSSuperscriptAttributeName];
    if( supers && supers != [oldAttrs objectForKey: NSSuperscriptAttributeName] )
    {
        [str appendString: @"<sup>"];
        [endStr insertString: @"</sup>" atIndex: 0];
    }
    
    // Actual text and closing tags:
    [str appendString: [[[self string] substringWithRange:effRange] stringByInsertingHTMLEntitiesAndLineBreaks: YES]];
    [str appendString: endStr];
    
    while( location < finalLen )
    {
        [endStr setString: @""];
        attrs = [self attributesAtIndex: location effectiveRange: &effRange];
        location = effRange.location +effRange.length;
        
        // Font/color changed?
        NSFont* fnt = [attrs objectForKey: NSFontAttributeName];
        NSColor* tcol = [attrs objectForKey: NSForegroundColorAttributeName];
        if( fnt || tcol )
        {
            [str appendString: @"<font"];
            if( fnt )
            {
                [str appendFormat: @" face=\"%@\"", [fnt familyName]];
                [str appendFormat: @" size=\"%@\"", FontSizeToHTMLSize(fnt)];
            }
            if( tcol )
            {
                [str appendFormat: @" color=\"%@\"", ColorToHTMLColor(tcol)];
            }
            [str appendString: @">"];
            [endStr insertString: @"</font>" atIndex: 0];

            NSFontTraitMask trt = [[NSFontManager sharedFontManager] traitsOfFont: fnt];
            if( (trt & NSItalicFontMask) == NSItalicFontMask )
            {
                if( !obliq || [obliq floatValue] == 0 ) // Don't apply twice.
                {
                    [str appendString: @"<i>"];
                    [endStr insertString: @"</i>" atIndex: 0];
                }
            }
            if( (trt & NSBoldFontMask) == NSBoldFontMask
                || [[NSFontManager sharedFontManager] weightOfFont: fnt] >= 9 )
            {
                [str appendString: @"<b>"];
                [endStr insertString: @"</b>" atIndex: 0];
            }
            if( (trt & NSFixedPitchFontMask) == NSFixedPitchFontMask )
            {
                [str appendString: @"<tt>"];
                [endStr insertString: @"</tt>" atIndex: 0];
            }
        }
        // Superscript changed?
        NSNumber* supers = [attrs objectForKey: NSSuperscriptAttributeName];
        if( supers && supers != [oldAttrs objectForKey: NSSuperscriptAttributeName] )
        {
            [str appendString: @"<sup>"];
            [endStr insertString: @"</sup>" atIndex: 0];
        }
        
        // Actual text and closing tags:
        [str appendString: [[[self string] substringWithRange:effRange] stringByInsertingHTMLEntitiesAndLineBreaks: YES]];
        [str appendString: endStr];
    }
    
    return str;
}

@end
