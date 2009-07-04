//
//  UKScreenshotImageOfDisplay.m
//  TimeSaver
//
//  Created by Uli Kusterer on 09.12.06.
//  Copyright 2006 M. Uli Kusterer. All rights reserved.
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
