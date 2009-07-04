/* =============================================================================
    PROJECT:    Filie
    FILE:       NSImage+NiceScaling.h
    
    COPYRIGHT:  (c) 2003-2007 by M. Uli Kusterer, all rights reserved.
    
    AUTHORS:    M. Uli Kusterer - UK
    
    LICENSES:   GNU GPL, Modified BSD
    
    REVISIONS:
        2003-12-19  UK  Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <AppKit/AppKit.h>


// -----------------------------------------------------------------------------
//  Categories:
// -----------------------------------------------------------------------------

/*
	All these calls return a version of this image that is scaled proportionally
	to the best size. There are two ways the best size can be determined:
	
	a)  "fit" - The image is resized so it completely fits into a rect of the
		specified size. Nothing of the image will come to lie outside, but there
		may be empty areas in the destination rectangle not covered by the image.
	b)  "cover" - The image is scaled so drawing it into the specified rectangle
		will cause the image to leave no empty spots in the rectangle. For this
		to look right, some parts of the image may be cut off.
	
	Defaults:
		withInterpolation - NSImageInterpolationHigh
		andBox -			NO
		align -				NSImageAlignCenter
*/

@interface NSImage (NiceScaling)

// NSImage -> NSImage (fit):
-(NSImage*) scaledImageToFitSize: (NSSize)fitIn;
-(NSImage*) scaledImageToFitSize: (NSSize)fitIn withInterpolation: (NSImageInterpolation)inter;
-(NSImage*) scaledImageToFitSize: (NSSize)fitIn withInterpolation: (NSImageInterpolation)inter andBox: (BOOL)doBox;

// NSImage -> NSImage (cover):
-(NSImage*) scaledImageToCoverSize: (NSSize)fitIn;
-(NSImage*) scaledImageToCoverSize: (NSSize)fitIn withInterpolation: (NSImageInterpolation)inter;
-(NSImage*) scaledImageToCoverSize: (NSSize)fitIn withInterpolation: (NSImageInterpolation)inter andBox: (BOOL)doBox;
-(NSImage*) scaledImageToCoverSize: (NSSize)fitIn withInterpolation: (NSImageInterpolation)inter
						andBox: (BOOL)doBox align: (NSImageAlignment)align;

// [NSImage size] -> NSSize:
-(NSSize)   scaledSizeToFitSize: (NSSize)size;
-(NSSize)   scaledSizeToCoverSize: (NSSize)size;

// NSSize -> NSSize:
+(NSSize)   scaledSize: (NSSize)imgSize toFitSize: (NSSize)size;
+(NSSize)   scaledSize: (NSSize)imgSize toCoverSize: (NSSize)size;

@end
