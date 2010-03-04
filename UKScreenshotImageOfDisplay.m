//
//  UKScreenshotImageOfDisplay.m
//  TimeSaver
//
//  Created by Uli Kusterer on 09.12.06.
//  Copyright 2006 Uli Kusterer.
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
//	Headers:
// -----------------------------------------------------------------------------

#import "UKScreenshotImageOfDisplay.h"


// -----------------------------------------------------------------------------
//	ReturnBytesPtrCallback:
// -----------------------------------------------------------------------------

static const void*	ReturnBytesPtrCallback( void* info )
{
	return info;
}


// -----------------------------------------------------------------------------
//	UKScreenshotImageOfDisplay:
// -----------------------------------------------------------------------------

NSImage*	UKScreenshotImageOfDisplay( CGDirectDisplayID displayID )
{
	NSImage*							screenShot = nil;
	unsigned char*						addr = CGDisplayBaseAddress(displayID);
	CGSize								dpSize;
	CGDataProviderDirectAccessCallbacks	providerCallbacks = { ReturnBytesPtrCallback, NULL, NULL, NULL };
	CGImageRef							tempScreenshot;
	CGRect								box = { { 0, 0 }, { 0, 0 } };
	
	dpSize.width = CGDisplayPixelsWide(displayID);
	dpSize.height = CGDisplayPixelsHigh(displayID);
	
	box.size = dpSize;

	// Do our little flag dance to ensure CGImage gets the right byte order:
	CGBitmapInfo		flags = 0;
	#if TARGET_RT_LITTLE_ENDIAN
	flags |= kCGImageAlphaPremultipliedFirst;
	switch( CGDisplayBitsPerPixel(displayID) )
	{
		case 16:
			flags |= kCGBitmapByteOrder16Little;
			break;
		case 32:
			flags |= kCGBitmapByteOrder32Little;
			break;
		default:
			flags |= kCGBitmapByteOrderDefault;	// This will probably look wrong with anything but 8 bits, but at least it'll run.
			break;
	}
	#else
	flags |= kCGImageAlphaPremultipliedFirst;
	flags |= kCGBitmapByteOrderDefault;
	#endif
	
	// Create a CGImage pointing directly at the screen's buffer:
	//	CGImages can take any byte order, while NSImage will mix up the
	//	screen buffer's B and R components.
	CGColorSpaceRef		colorSpace = CGColorSpaceCreateDeviceRGB();
	CGDataProviderRef	provider = CGDataProviderCreateDirectAccess(
											addr,
											CGDisplayBytesPerRow(displayID) * CGDisplayPixelsHigh(displayID),
											&providerCallbacks );
	tempScreenshot = CGImageCreate( dpSize.width, dpSize.height,
								CGDisplayBitsPerSample(displayID), CGDisplayBitsPerPixel(displayID),
								CGDisplayBytesPerRow(displayID), colorSpace,
								flags, provider, NULL, false, kCGRenderingIntentDefault);
	CGDataProviderRelease( provider );
	CGColorSpaceRelease( colorSpace );
	
	// Now, draw the CGImage into an NSImage, giving us a snapshot of the current screen image:
	screenShot = [[[NSImage alloc] initWithSize: (*(NSSize*) &dpSize)] autorelease];
	[screenShot lockFocus];
	CGContextDrawImage( [[NSGraphicsContext currentContext] graphicsPort], box, tempScreenshot );
	[screenShot unlockFocus];
	CGImageRelease( tempScreenshot );
	
	return screenShot;
}
