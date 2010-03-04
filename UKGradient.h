//
//  UKGradient.h
//  GradientDrawing
//
//  Created by Uli Kusterer on 24.10.04.
//  Copyright 2004 Uli Kusterer.
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

/*
	UKGradient is a class that encapsulates a linear gradient between two colors.
	It supports horizontal, vertical and diagonal gradients. Since diagonal gradients
	are rather complex, it also supports cacheing a gradient (on by default).
	
	Cached gradients are drawn once at a certain size and then scaled to fit any
	other rects you may draw them in. This is a lot faster, but may cause "steps"
	between colors to appear when a gradient is scaled up.
*/

#import <Cocoa/Cocoa.h>


typedef enum UKGradientDirection
{
	UKGradientFromTop		= 0,	// Vertical gradient.
	UKGradientFromLeft		= 1,	// Horizontal gradient.
	UKGradientFromTopLeft	= 2,	// Diagonal gradient from top left to bottom right.
	UKGradientFromBotLeft	= 3		// Diagonal gradient from bottom left to top right.
} UKGradientDirection;


@interface UKGradient : NSObject
{
	NSColor*			startColor;		// Color to start gradient at.
	NSColor*			endColor;		// Color to end gradient at.
	UKGradientDirection	direction;		// Gradient orientation.
	NSSize				cacheSize;		// Size of cached image data.
	unsigned char*		cachedImage;	// Cached image data.
	BOOL				dontCache;		// Don't cache an image of the gradient at its initial size for faster drawing, recreate the gradient each time we draw.
}

-(id)	init;
-(id)	initWithStartColor: (NSColor*)start endColor: (NSColor*)end direction: (UKGradientDirection)d;
-(id)	initWithStartColor: (NSColor*)start endColor: (NSColor*)end direction: (UKGradientDirection)d
			rect: (NSRect)box;	// Same as initWithStartColor:endColor:direction: followed by cacheForRect:.

// Set colors of gradient:
-(NSColor*)	startColor;
-(void)		setStartColor: (NSColor*)theStartColor;		// Recaches image.

-(NSColor*) endColor;
-(void)		setEndColor: (NSColor*)theEndColor;			// Recaches image.

-(void)		swapColors;									// Swaps endColor and startColor. May recache, may rotate image.

// Set orientation of gradient:
-(void)		setDirection: (UKGradientDirection)dir;		// Recaches image.
-(UKGradientDirection)	direction;

// Draw the gradient:
-(void)		drawInRect: (NSRect)box;
-(void)		drawAtPoint: (NSPoint)pos;					// Uses last cached size.

// Don't optimize performance at cost of looks by caching image when first drawing (off by default):
-(BOOL)		dontCache;
-(void)		setDontCache: (BOOL)n;						// Clears cache.

-(void)		cacheForRect: (NSRect)box;
-(void)		invalidateCache;

@end


@interface NSColor (UKRGBAIntValue)

-(unsigned int)	rgbaIntValue;

@end
