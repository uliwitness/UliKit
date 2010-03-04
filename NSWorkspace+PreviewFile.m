//
//	NSWorkspace+PreviewFile.m
//	Filie
//
//	Created by Uli Kusterer on 5.12.2004
//	Copyright 2004 by Uli Kusterer.
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
