//
//	NSImage+NiceScaling.h
//	Filie
//
//	Created by Uli Kusterer on 19.12.2003
//	Copyright 2003 by Uli Kusterer, with contributions by Sergey Shapovalov.
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
