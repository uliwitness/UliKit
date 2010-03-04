//
//  UKTextUtilities.m
//  AngelTemplate
//
//  Created by Uli Kusterer on 17.01.05.
//  Copyright 2005 Uli Kusterer.
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

#import "UKTextUtilities.h"


NSStringEncoding    StringEncodingFromName( NSString* encName )
{
    // No encoding? Assume UTF8:
    if( !encName )
        return NSUTF8StringEncoding;
    
    // Build lookup table lazily, but then keep it around so we don't re-build it each time:
    static NSDictionary*       encs = nil;
    if( !encs )
        encs = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInt: NSASCIIStringEncoding], @"ASCII",
                                    [NSNumber numberWithInt: NSNEXTSTEPStringEncoding], @"NEXTSTEP",
                                    [NSNumber numberWithInt: NSNEXTSTEPStringEncoding], @"NEXTSTEP",
                                    [NSNumber numberWithInt: NSJapaneseEUCStringEncoding], @"JapaneseEUC",
                                    [NSNumber numberWithInt: NSUTF8StringEncoding], @"UTF8",
                                    [NSNumber numberWithInt: NSISOLatin1StringEncoding], @"ISOLatin1",
                                    [NSNumber numberWithInt: NSSymbolStringEncoding], @"Symbol",
                                    [NSNumber numberWithInt: NSNonLossyASCIIStringEncoding], @"NonLossyASCII",
                                    [NSNumber numberWithInt: NSShiftJISStringEncoding], @"ShiftJIS",
                                    [NSNumber numberWithInt: NSISOLatin2StringEncoding], @"ISOLatin2",
                                    [NSNumber numberWithInt: NSUnicodeStringEncoding], @"Unicode",
                                    [NSNumber numberWithInt: NSWindowsCP1251StringEncoding], @"WindowsCP1251",
                                    [NSNumber numberWithInt: NSWindowsCP1251StringEncoding], @"Cyrillic",
                                    [NSNumber numberWithInt: NSWindowsCP1251StringEncoding], @"AdobeStandardCyrillic",
                                    [NSNumber numberWithInt: NSWindowsCP1252StringEncoding], @"CP1252",
                                    [NSNumber numberWithInt: NSWindowsCP1252StringEncoding], @"WindowsLatin1",
                                    [NSNumber numberWithInt: NSWindowsCP1252StringEncoding], @"WinLatin1",
                                    [NSNumber numberWithInt: NSWindowsCP1253StringEncoding], @"CP1253",
                                    [NSNumber numberWithInt: NSWindowsCP1253StringEncoding], @"Greek",
                                    [NSNumber numberWithInt: NSWindowsCP1254StringEncoding], @"CP1254",
                                    [NSNumber numberWithInt: NSWindowsCP1254StringEncoding], @"Turkish",
                                    [NSNumber numberWithInt: NSWindowsCP1250StringEncoding], @"CP1250",
                                    [NSNumber numberWithInt: NSWindowsCP1250StringEncoding], @"WindowsLatin2",
                                    [NSNumber numberWithInt: NSWindowsCP1250StringEncoding], @"WinLatin2",
                                    [NSNumber numberWithInt: NSISO2022JPStringEncoding], @"ISO2022JP",
                                    [NSNumber numberWithInt: NSMacOSRomanStringEncoding], @"MacOSRoman",
                                    [NSNumber numberWithInt: NSMacOSRomanStringEncoding], @"MacRoman",
                                    nil ];
    
    // Get NSStringEncoding for this string:
    NSNumber*           enc = [encs objectForKey: encName];
    if( enc )
        return [enc intValue];
    else
        return NSUTF8StringEncoding;    // Unknown? Use UTF8.
}
