//
//  UKFadedDrawing.m
//  UKFadedDrawing
//
//  Created by Uli Kusterer on 08.05.08.
//  Copyright 2008 Uli Kusterer.
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

#import "UKFadedDrawing.h"



void	UKSetUpOpposingFades( NSRect box, float startFadeDistance, float endFadeDistance, BOOL horzNotVert )
{
	float			distanceToGo = horzNotVert ? box.size.width : box.size.height;
	NSMutableData*	maskData = [NSMutableData dataWithLength: distanceToGo	* sizeof(float)];
	float*			currPixel = (float*) [maskData mutableBytes];
	if( distanceToGo < (startFadeDistance + endFadeDistance) )
		startFadeDistance = endFadeDistance = distanceToGo / 2;
	
	int x = 0;
	for( ; x < startFadeDistance; x++ )
		currPixel[x] = ((float)x) / startFadeDistance;
	
	int		startOfEndFade = distanceToGo -endFadeDistance;
	for( ; (x < startOfEndFade) && (x < distanceToGo); x++ )
		currPixel[x] = 1.0;
	
	for( ; x < distanceToGo; x++ )
		currPixel[x] = ((float) endFadeDistance -(x -startOfEndFade)) / endFadeDistance;
	
	CGContextRef		ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState( ctx );
	CGColorSpaceRef		colorSpace = CGColorSpaceCreateDeviceGray();
	CGDataProviderRef	dataProvider = CGDataProviderCreateWithCFData( (CFDataRef) maskData );
	
	float		width = horzNotVert ? distanceToGo : 1,
				height = horzNotVert ? 1 : distanceToGo;
	
	CGImageRef			maskImage = CGImageCreate( width, height, sizeof(float) * 8, sizeof(float) * 8,
													width * sizeof(float), colorSpace,
													kCGBitmapFloatComponents | kCGBitmapByteOrder32Host, dataProvider, NULL, true,
													kCGRenderingIntentDefault );
	CGContextClipToMask( ctx, *((CGRect*)&box), maskImage );
	
	CGDataProviderRelease( dataProvider );
	CGColorSpaceRelease( colorSpace );
	CGImageRelease( maskImage );
}


void	UKTearDownFades()
{
	CGContextRef		ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextRestoreGState( ctx );
}

