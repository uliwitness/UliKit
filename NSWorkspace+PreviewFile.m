/* =============================================================================
    PROJECT:    Filie
    FILE:       NSWorkspace+PreviewFile.m
    
    COPYRIGHT:  (c) 2004 by M. Uli Kusterer, all rights reserved.
    
    AUTHORS:    M. Uli Kusterer - UK
    
    LICENSES:   GNU GPL, Modified BSD
    
    REVISIONS:
        2004-12-05  UK  Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import "NSWorkspace+PreviewFile.h"
#import "NSImage+Epeg.h"
#import "NSString+CarbonUtilities.h"


// -----------------------------------------------------------------------------
//  Data Structures:
// -----------------------------------------------------------------------------

// 'pnot' resource's data structure used by QuickTime for its previews:

#pragma options align=mac68k

typedef struct PnotResItem {
    unsigned long   modDate;/* last modification date of item */
    OSType          useType; /* what type of data */
    OSType          resType;/* resource type containing item */
    short           resID;  /* resource ID containing this item */
    short           rgnCode;/* region code */
    long            reserved;/* set to 0 */
} PnotResItem;

typedef struct PnotResource {
    unsigned long       modDate;        /* modification date */
    short               version;/* version number of preview resource */
    OSType              resType;/* type of resource used as preview cache */
    short               resID;  /* resource identification number of resource used as preview cache */
    signed short        numResItems;/* number of additional file descriptions */
    PnotResItem         resItem[0]; /* array of file descriptions */
} PnotResource;
typedef PnotResource **PnotResHandle;

#pragma options align=reset


@implementation NSWorkspace (UKPreviewFile)

// -----------------------------------------------------------------------------
//  previewImageForFile:size:
//      Generates a preview image for an image file and gives it the specified
//      dimensions.
//      Uses libepeg for JPEG files, otherwise attempts to load a QuickTime
//      preview if there is one. Returns NIL if both of these fail.
//
//  REVISIONS:
//      2004-12-05  UK  Created.
// -----------------------------------------------------------------------------

-(NSImage*) previewImageForFile: (NSString*)fpath size: (NSSize)neededSize
{
    FSRef       fileRef;
    NSImage*    img = nil;
    NSString*   suf = [[fpath pathExtension] lowercaseString];
    
    // Amazingly, this is faster than loading QuickTime's preview:
    if( [suf isEqualToString: @"jpg"] || [suf isEqualToString: @"jpeg"] )
        img = [NSImage previewImageWithContentsOfFile: fpath boundingBox: neededSize];
    
    // If it's not a JPEG, we can't quick-preview, so try the QuickTime Preview:
    if( !img && [fpath getFSRef: &fileRef] )
    {
        short   refNum = FSOpenResFile( &fileRef, fsRdPerm );
        
        if( refNum > 0 && ResError() == noErr )
        {
            OSType      resType = 0;
            short       resID = 0;
            
            UseResFile( refNum );   // In case it was already open.
            
            PnotResHandle  theRes = (PnotResHandle) Get1Resource( 'pnot', 0 );
            if( theRes != NULL && ResError() == noErr && MemError() == noErr )
            {
                int         x;
                
                resType = (**theRes).resType;
                resID = (**theRes).resID;
                
                if( (**theRes).numResItems < 16384 )    // 16384 == -1.
                {
                    for( x = 0; x < (**theRes).numResItems; x++ )
                    {
                        if( (**theRes).resItem[x].useType == 'Prev' )
                        {
                            resType = (**theRes).resItem[x].resType;
                            resID = (**theRes).resItem[x].resID;
                        }
                    }
                }
            }
            
            // Now, if we've found a preview we know how to handle, generate an image from it:
            if( resType == 'PICT' )
            {
                Handle  thePic = Get1Resource( 'PICT', resID );
                NSData* data = [NSData dataWithBytes: *thePic length: GetHandleSize(thePic)];
                img = [[[NSImage alloc] initWithData: data] autorelease];
            }
            
            CloseResFile( refNum );
        }
    }
    
    return img;
}

@end
