/* =============================================================================
    PROJECT:	testapp
	FILE:       NSImage+IconRef.h
    
    COPYRIGHT:  (c) by Troy Stephens, all rights reserved.
    
    AUTHORS:    Troy Stephens, M. Uli Kusterer - UK
    
    LICENSES:   GNU GPL, Modified BSD
	
	PURPOSE:	Create an IconRef from an image.
    
    REVISIONS:
        2005-02-09  UK  Created.
   ========================================================================== */
 
// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------
 
#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Expatriates from Troy Stephens' IconFamily class:
// -----------------------------------------------------------------------------

@interface NSImage (UKIconRef)

-(IconRef)  iconRefRepresentation;

-(Handle)   get32BitDataAtPixelSize: (int)requiredPixelSize;
-(Handle)   get8BitMaskAtPixelSize: (int)requiredPixelSize;

@end
