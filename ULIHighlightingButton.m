//
//  ULIHighlightingButton.m
//  Stacksmith
//
//  Created by Uli Kusterer on 15.07.11.
//  Copyright 2011 Uli Kusterer. All rights reserved.
//

#import "ULIHighlightingButton.h"

@implementation ULIHighlightingButton

-(void)	awakeFromNib
{
	NSImage		*	img = [self image];
	
	NSRect		iBox = NSZeroRect;
	iBox.size = [img size];
	NSImage*	hImg = [[[NSImage alloc] initWithSize: iBox.size] autorelease];
	[hImg lockFocus];
		CGContextRef    theCtx = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextSaveGState( theCtx );
		[img drawAtPoint: NSZeroPoint fromRect: NSZeroRect operation: NSCompositeCopy fraction: 1.0];

		// Make sure we only touch opaque pixels:
		CGContextClipToMask( theCtx, NSRectToCGRect(iBox), [img CGImageForProposedRect: nil context: [NSGraphicsContext currentContext] hints: nil] );

		// Now draw a rectangle over the icon that flips all the pixels:
		#if INVERT
		CGContextSetBlendMode( theCtx, kCGBlendModeDifference );
		CGContextSetRGBFillColor( theCtx, 1, 1, 1, 1.0 );
		CGContextFillRect( theCtx, NSRectToCGRect( iBox ) );
		CGContextSetBlendMode( theCtx, kCGBlendModeNormal );
		#else
		[[NSColor colorWithCalibratedWhite: 0.0 alpha: 0.4] set];
		NSRectFillUsingOperation( iBox, NSCompositeSourceAtop );
		#endif
		CGContextRestoreGState( theCtx );
	[hImg unlockFocus];
	
	[self setAlternateImage: hImg];
}

@end
