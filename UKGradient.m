//
//  UKGradient.m
//  GradientDrawing
//
//  Created by Uli Kusterer on 24.10.04.
//  Copyright 2004 M. Uli Kusterer. All rights reserved.
//

#import "UKGradient.h"


@implementation UKGradient


-(id)	init
{
	self = [super init];
	if( !self )
		return nil;
	
	direction = UKGradientFromTopLeft;
	[self setStartColor: [NSColor darkGrayColor]];
	[self setEndColor: [NSColor lightGrayColor]];
	
	return self;
}


-(id)	initWithStartColor: (NSColor*)start endColor: (NSColor*)end direction: (UKGradientDirection)d
{
	self = [super init];
	if( !self )
		return nil;
	
	direction = d;
	[self setStartColor: [NSColor darkGrayColor]];
	[self setEndColor: [NSColor lightGrayColor]];
	
	return self;
}


-(id)	initWithStartColor: (NSColor*)start endColor: (NSColor*)end direction: (UKGradientDirection)d
			rect: (NSRect)box
{
	self = [self initWithStartColor: start endColor: end direction: d];
	if( !self )
		return nil;
	
	[self cacheForRect: box];
	
	return self;
}



// ---------------------------------------------------------- 
//  - dealloc:
// ---------------------------------------------------------- 
- (void) dealloc
{
    [startColor release];
    [endColor release];

    startColor = nil;
    endColor = nil;

    [super dealloc];
}


// ---------------------------------------------------------- 
// - startColor:
// ---------------------------------------------------------- 
- (NSColor *) startColor
{
    return startColor; 
}

// ---------------------------------------------------------- 
// - setStartColor:
// ---------------------------------------------------------- 
- (void) setStartColor: (NSColor *) theStartColor
{
    if (startColor != theStartColor)
	{
        [startColor release];
        startColor = [theStartColor retain];
		[self invalidateCache];
    }
}

// ---------------------------------------------------------- 
// - endColor:
// ---------------------------------------------------------- 
- (NSColor *) endColor
{
    return endColor; 
}

// ---------------------------------------------------------- 
// - setEndColor:
// ---------------------------------------------------------- 
- (void) setEndColor: (NSColor *) theEndColor
{
    if (endColor != theEndColor)
	{
        [endColor release];
        endColor = [theEndColor retain];
		[self invalidateCache];
    }
}


-(void)	setDirection: (UKGradientDirection)dir
{
	direction = dir;
	[self invalidateCache];
}


-(UKGradientDirection)	direction
{
	return direction;
}


-(BOOL)		dontCache
{
	return dontCache;
}


-(void)		setDontCache: (BOOL)n
{
	dontCache = n;
	[self invalidateCache];
}


-(void)		invalidateCache
{
	if( cachedImage )
	{
		free( cachedImage );
		cachedImage = NULL;
	}
}




#define UKTRansformYCoord(n)	((direction != UKGradientFromTopLeft) ? (box.size.height -n) : n)

/*unsigned int UKBlendedRGBA( unsigned int c1, unsigned int c2, float frac )
{
	int		r = ((c1 & 0xFF000000) >> 24) *(1-frac) +((c2 & 0xFF000000) >> 24) *frac,
			g = ((c1 & 0x00FF0000) >> 16) *(1-frac) +((c2 & 0x00FF0000) >> 16) *frac,
			b = ((c1 & 0x0000FF00) >> 8) *(1-frac) +((c2 & 0x0000FF00) >> 8) *frac,
			a = (c1 & 0x000000FF) *(1-frac) +(c2 & 0x000000FF) *frac;
	
	return( (r << 24) | (g << 16) | (b << 8) | a );
}*/

#define UKRed(c1)						((c1 & 0xFF000000) >> 24)
#define UKGreen(c1)						((c1 & 0x00FF0000) >> 16)
#define UKBlue(c1)						((c1 & 0x0000FF00) >> 8)
#define UKAlpha(c1)						(c1 & 0x000000FF)
#define UKUnRed(cm1)					((cm1 & 0xFF) << 24)
#define UKUnGreen(cm1)					((cm1 & 0xFF) << 16)
#define UKUnBlue(cm1)					((cm1 & 0xFF) << 8)
#define UKUnAlpha(cm1)					(cm1 & 0xFF)
#define UKBlend(cm1,cm2,frac)			((int)(cm1 *(1-frac) +cm2 * frac))
#define UKBlendedRGBA( c1, c2, frac )	(UKUnRed(UKBlend(UKRed(c1),UKRed(c2),frac)) \
										| UKUnGreen(UKBlend(UKGreen(c1),UKGreen(c2),frac)) \
										| UKUnBlue(UKBlend(UKBlue(c1),UKBlue(c2),frac)) \
										| UKUnAlpha(UKBlend(UKAlpha(c1),UKAlpha(c2),frac)))

-(void)	drawAtPoint: (NSPoint)pos
{
	NSRect		box;
	
	box.origin = pos;
	box.size = cacheSize;
	
	[self drawInRect: box];
}


-(void)	drawInRect: (NSRect)box
{
	int		x,
			y;
	NSRect	unitSquare = { {0, 0 }, { 1, 1 } };
	float	stepSize;
	
	switch( direction )
	{
		case UKGradientFromLeft:
			stepSize = 1 / box.size.width;
			unitSquare.size.height = box.size.height;
			for( x = 0; x < box.size.width; x++ )
			{
				float frac = stepSize * x;
				unitSquare.origin.x = x +box.origin.x;
				[[startColor blendedColorWithFraction: frac ofColor: endColor] set];
				NSRectFill( unitSquare );
			}
			break;
		
		case UKGradientFromTop:
			stepSize = 1 / box.size.height;
			unitSquare.size.width = box.size.width;
			for( y = 0; y < box.size.height; y++ )
			{
				float frac = stepSize * y;
				unitSquare.origin.y = y +box.origin.y;
				[[endColor blendedColorWithFraction: frac ofColor: startColor] set];	// Reversed since coords go from bottom to top.
				NSRectFill( unitSquare );
			}
			break;
		
		case UKGradientFromTopLeft:
		case UKGradientFromBotLeft:
		{
			if( !cachedImage
				|| ((cacheSize.height != box.size.height
				|| cacheSize.width != box.size.width) && dontCache) )
				[self cacheForRect: box];
			
			char**				buffers[5] = { (unsigned char*)cachedImage, NULL };
			NSDrawBitmap( box, cacheSize.width, cacheSize.height, 8, 4, 32, (cacheSize.width *sizeof(unsigned int)),
							NO, YES, NSDeviceRGBColorSpace, buffers );
			
			if( dontCache )
				[self invalidateCache];
		}
	}
}

-(void)	cacheForRect: (NSRect)box
{
	[self invalidateCache];
	
	unsigned int*	buf = malloc( (box.size.width *box.size.height) * sizeof(unsigned int) );
	unsigned int	startRGBA = [startColor rgbaIntValue],
					endRGBA = [endColor rgbaIntValue];
	float			stepSize = 1 / (box.size.width +box.size.height);
	int				x,
					y;
	
	for( x = 0; x < box.size.width; x++ )
	{
		for( y = 0; y < box.size.height; y++ )
		{
			float			frac = stepSize * (x+ UKTRansformYCoord(y));
			int				currOffs = (y *box.size.width) +x;
			unsigned int	colorVal = UKBlendedRGBA( startRGBA, endRGBA, frac );
			buf[currOffs] = colorVal;
		}
	}
	
	cacheSize = box.size;
	cachedImage = buf;
}

-(void)	swapColors
{
	NSColor*	t = endColor;
	endColor = startColor;
	startColor = t;
	
	[self invalidateCache];	// TODO: Just rotate cache 180 degrees instead!
}

@end


@implementation NSColor (UKRGBAIntValue)

-(unsigned int)	rgbaIntValue
{
	float		r, g, b, a;
	NSColor*	rgbaColor = [self colorUsingColorSpaceName: NSDeviceRGBColorSpace];
	
	[rgbaColor getRed: &r green: &g blue: &b alpha: &a];
	
	return( ((int)(r * 255) << 24) | ((int)(g * 255) << 16) | ((int)(b * 255) << 8) | (int)(a * 255) );
}

@end
