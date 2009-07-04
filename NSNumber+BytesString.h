/* =============================================================================
    PROJECT:	Filie
	FILE:       NSNumber+BytesString.h
    
    COPYRIGHT:  (c) 2005-2008 by M. Uli Kusterer, all rights reserved.
    
    AUTHORS:    M. Uli Kusterer - UK
    
    LICENSES:   GNU GPL, Modified BSD
	
	PURPOSE:	Take a number of bytes and format it for display as a string
				in a sensible way, picking an appropriate unit like bytes, kb,
				etc. and appending that unit to the string along with the
				number.
    
    REVISIONS:
        2005-07-03  UK  Created.
   ========================================================================== */
 
// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------
 
#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Extend NSNumber:
// -----------------------------------------------------------------------------
 
@interface NSNumber (UKBytesString)

+(NSString*)    bytesStringForInt: (int)bytes;

-(NSString*)    bytesString;

@end
