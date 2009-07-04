/* =============================================================================
    PROJECT:    Filie
    FILE:       NSWorkspace+PreviewFile.h
    
    COPYRIGHT:  (c) 2004 by M. Uli Kusterer, all rights reserved.
    
    AUTHORS:    M. Uli Kusterer - UK
    
    LICENSES:   GNU GPL, Modified BSD
    
    REVISIONS:
        2004-12-05  UK  Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Categories:
// -----------------------------------------------------------------------------

@interface NSWorkspace (UKPreviewFile)

-(NSImage*) previewImageForFile: (NSString*)fpath size: (NSSize)neededSize;

@end
