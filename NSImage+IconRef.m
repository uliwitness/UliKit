//
//  NSImage+IconRef.m
//  testapp
//
//  Created by Uli Kusterer on 09.02.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "NSImage+IconRef.h"


// -----------------------------------------------------------------------------
//  Expatriates from Troy Stephens' IconFamily class:
// -----------------------------------------------------------------------------

@implementation NSImage (UKIconRef)

-(IconRef)     iconRefRepresentation
{
    static int          gIKitCounter = 0;
    IconRef             iconRef = NULL;
    IconFamilyHandle    fam = (IconFamilyHandle) NewHandle( sizeof(OSType) + sizeof(Size) );
    (**fam).resourceType = 'icns';
    (**fam).resourceSize = sizeof(OSType) + sizeof(Size);
    
    Handle myPict = [self get32BitDataAtPixelSize: 128];
    SetIconFamilyData( fam, kThumbnail32BitData, myPict );
    DisposeHandle( myPict );
    myPict = [self get8BitMaskAtPixelSize: 128];
    SetIconFamilyData( fam, kThumbnail8BitMask, myPict );
    DisposeHandle( myPict );
    
    RegisterIconRefFromIconFamily( 'IKit', ++gIKitCounter, fam, &iconRef );
    DisposeHandle( (Handle) fam );
    
    return iconRef;
}

-(Handle) get8BitMaskAtPixelSize: (int)requiredPixelSize
{
    NSBitmapImageRep*   bitmapImageRep = [NSBitmapImageRep imageRepWithData: [self TIFFRepresentation]];
    Handle hRawData;
    unsigned char* pRawData;
    Size rawDataSize;
    unsigned char* pSrc;
    unsigned char* pDest;
    int x, y;
    
    // Get information about the bitmapImageRep.
    int pixelsWide      = [bitmapImageRep pixelsWide];
    int pixelsHigh      = [bitmapImageRep pixelsHigh];
    int bitsPerSample   = [bitmapImageRep bitsPerSample];
    int samplesPerPixel = [bitmapImageRep samplesPerPixel];
    int bitsPerPixel    = [bitmapImageRep bitsPerPixel];
//    BOOL hasAlpha       = [bitmapImageRep hasAlpha];
    BOOL isPlanar       = [bitmapImageRep isPlanar];
//    int numberOfPlanes  = [bitmapImageRep numberOfPlanes];
    int bytesPerRow     = [bitmapImageRep bytesPerRow];
//    int bytesPerPlane   = [bitmapImageRep bytesPerPlane];
    unsigned char* bitmapData = [bitmapImageRep bitmapData];

    // Make sure bitmap has the required dimensions.
    if (pixelsWide != requiredPixelSize || pixelsHigh != requiredPixelSize)
		return NULL;
	
    // So far, this code only handles non-planar 32-bit RGBA, 24-bit RGB and 8-bit grayscale source bitmaps.
    // This could be made more flexible with some additional programming...
    if (isPlanar)
	{
		NSLog(@"get8BitMaskFromBitmapImageRep:requiredPixelSize: returning NULL due to isPlanar == YES");
		return NULL;
	}
    if (bitsPerSample != 8)
	{
		NSLog(@"get8BitMaskFromBitmapImageRep:requiredPixelSize: returning NULL due to bitsPerSample == %d", bitsPerSample);
		return NULL;
	}
	
	if (((samplesPerPixel == 1) && (bitsPerPixel == 8)) || ((samplesPerPixel == 3) && (bitsPerPixel == 24)) || ((samplesPerPixel == 4) && (bitsPerPixel == 32)))
	{
		rawDataSize = pixelsWide * pixelsHigh;
		hRawData = NewHandle( rawDataSize );
		if (hRawData == NULL)
			return NULL;
		pRawData = (unsigned char*) *hRawData;
	
		pSrc = bitmapData;
		pDest = pRawData;
		
		if (bitsPerPixel == 32) {
			for (y = 0; y < pixelsHigh; y++) {
				pSrc = bitmapData + y * bytesPerRow;
				for (x = 0; x < pixelsWide; x++) {
					pSrc += 3;
					*pDest++ = *pSrc++;
				}
			}
		}
		else if (bitsPerPixel == 24) {
			memset( pDest, 255, rawDataSize );
		}
		else if (bitsPerPixel == 8) {
			for (y = 0; y < pixelsHigh; y++) {
				memcpy( pDest, pSrc, pixelsWide );
				pSrc += bytesPerRow;
				pDest += pixelsWide;
			}
		}
	}
	else
	{
		NSLog(@"get8BitMaskFromBitmapImageRep:requiredPixelSize: returning NULL due to samplesPerPixel == %d, bitsPerPixel == %", samplesPerPixel, bitsPerPixel);
		return NULL;
	}

    return hRawData;
}

-(Handle) get32BitDataAtPixelSize:(int)requiredPixelSize
{
    Handle              hRawData;
    unsigned char*      pRawData;
    Size                rawDataSize;
    unsigned char*      pSrc;
    unsigned char*      pDest;
    int                 x, y;
    unsigned char       alphaByte;
    float               oneOverAlpha;
    NSBitmapImageRep*   bitmapImageRep = [NSBitmapImageRep imageRepWithData: [self TIFFRepresentation]];
    
    // Get information about the bitmapImageRep.
    int pixelsWide      = [bitmapImageRep pixelsWide];
    int pixelsHigh      = [bitmapImageRep pixelsHigh];
    int bitsPerSample   = [bitmapImageRep bitsPerSample];
    int samplesPerPixel = [bitmapImageRep samplesPerPixel];
    int bitsPerPixel    = [bitmapImageRep bitsPerPixel];
//    BOOL hasAlpha       = [bitmapImageRep hasAlpha];
    BOOL isPlanar       = [bitmapImageRep isPlanar];
//    int numberOfPlanes  = [bitmapImageRep numberOfPlanes];
    int bytesPerRow     = [bitmapImageRep bytesPerRow];
//    int bytesPerPlane   = [bitmapImageRep bytesPerPlane];
    unsigned char* bitmapData = [bitmapImageRep bitmapData];

    // Make sure bitmap has the required dimensions.
    if (pixelsWide != requiredPixelSize || pixelsHigh != requiredPixelSize)
	return NULL;
	
    // So far, this code only handles non-planar 32-bit RGBA and 24-bit RGB source bitmaps.
    // This could be made more flexible with some additional programming to accommodate other possible
    // formats...
    if (isPlanar)
	{
		NSLog(@"get32BitDataAtPixelSize: returning NULL due to isPlanar == YES");
		return NULL;
	}
    if (bitsPerSample != 8)
	{
		NSLog(@"get32BitDataAtPixelSize: returning NULL due to bitsPerSample == %d", bitsPerSample);
		return NULL;
	}

	if (((samplesPerPixel == 3) && (bitsPerPixel == 24)) || ((samplesPerPixel == 4) && (bitsPerPixel == 32)))
	{
		rawDataSize = pixelsWide * pixelsHigh * 4;
		hRawData = NewHandle( rawDataSize );
		if (hRawData == NULL)
			return NULL;
		pRawData = (unsigned char*)*hRawData;
	
		pSrc = bitmapData;
		pDest = pRawData;
		
		if (bitsPerPixel == 32) {
			for (y = 0; y < pixelsHigh; y++) {
				pSrc = bitmapData + y * bytesPerRow;
					for (x = 0; x < pixelsWide; x++) {
						// Each pixel is 3 bytes of RGB data, followed by 1 byte of
						// alpha.  The RGB values are premultiplied by the alpha (so
						// that Quartz can save time when compositing the bitmap to a
						// destination), and we undo this premultiplication (with some
						// lossiness unfortunately) when retrieving the bitmap data.
						*pDest++ = alphaByte = *(pSrc+3);
						if (alphaByte) {
							oneOverAlpha = 255.0f / (float)alphaByte;
							*pDest++ = *(pSrc+0) * oneOverAlpha;
							*pDest++ = *(pSrc+1) * oneOverAlpha;
							*pDest++ = *(pSrc+2) * oneOverAlpha;
						} else {
							*pDest++ = 0;
							*pDest++ = 0;
							*pDest++ = 0;
						}
						pSrc+=4;
				}
			}
		} else if (bitsPerPixel == 24) {
			for (y = 0; y < pixelsHigh; y++) {
				pSrc = bitmapData + y * bytesPerRow;
				for (x = 0; x < pixelsWide; x++) {
					*pDest++ = 0;
					*pDest++ = *pSrc++;
					*pDest++ = *pSrc++;
					*pDest++ = *pSrc++;
				}
			}
		}
	}
	else
	{
		NSLog(@"get32BitDataAtPixelSize: returning NULL due to samplesPerPixel == %d, bitsPerPixel == %", samplesPerPixel, bitsPerPixel);
		return NULL;
	}

    return hRawData;
}

@end
