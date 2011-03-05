//
//  NSWindow+ULIZoomEffect.m
//  Stacksmith
//
//  Created by Uli Kusterer on 05.03.11.
//  Copyright 2011 Uli Kusterer. All rights reserved.
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

#import "NSWindow+ULIZoomEffect.h"


@interface ULIQuicklyAnimatingWindow : NSWindow
{

}

- (NSTimeInterval)animationResizeTime:(NSRect)newFrame;

@end


@implementation ULIQuicklyAnimatingWindow

- (NSTimeInterval)animationResizeTime:(NSRect)newFrame
{
	return ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) ? 2.0 : 0.2;
}

@end


@implementation NSWindow (ULIZoomEffect)

-(NSImage*)	uli_imageWithSnapshotForceActive: (BOOL)doForceActive
{
	NSDisableScreenUpdates();
	BOOL	wasVisible = [self isVisible];
	
	if( doForceActive )
		[self makeKeyAndOrderFront: nil];
	else
		[self orderFront: nil];
	
    // snag the image
	CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, [self windowNumber], kCGWindowImageBoundsIgnoreFraming);
    
	if( !wasVisible )
		[self orderOut: nil];
	NSEnableScreenUpdates();
	
    // little bit of error checking
    if(CGImageGetWidth(windowImage) <= 1)
	{
        CGImageRelease(windowImage);
        return nil;
    }
    
    // Create a bitmap rep from the window and convert to NSImage...
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage: windowImage];
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation: bitmapRep];
    [bitmapRep release];
    CGImageRelease(windowImage);
    
    return [image autorelease];
}


-(NSWindow*)	uli_animationWindowForZoomEffectWithImage: (NSImage*)snapshotImage
{
	NSRect			myFrame = [self frame];
	myFrame.size = [snapshotImage size];
	NSWindow	*	animationWindow = [[ULIQuicklyAnimatingWindow alloc] initWithContentRect: myFrame styleMask: NSBorderlessWindowMask backing: NSBackingStoreBuffered defer: NO];
	[animationWindow setOpaque: NO];
	
	NSImageView	*	imageView = [[NSImageView alloc] initWithFrame: NSMakeRect(0,0,myFrame.size.width,myFrame.size.height)];
	[imageView setImageScaling: NSImageScaleAxesIndependently];
	[imageView setImageFrameStyle: NSImageFrameNone];
	[imageView setImageAlignment: NSImageAlignCenter];
	[imageView setImage: snapshotImage];
	[imageView setAutoresizingMask: NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin | NSViewWidthSizable | NSViewHeightSizable];
	[[animationWindow contentView] addSubview: imageView];
	
	[imageView release];
	
	[animationWindow setHasShadow: YES];
	[animationWindow display];
	
	return animationWindow;
}


-(void)	makeKeyAndOrderFrontWithZoomEffectFromRect: (NSRect)globalStartPoint
{
	NSImage		*	snapshotImage = [self uli_imageWithSnapshotForceActive: YES];
	NSRect			myFrame = [self frame];
	myFrame.size = snapshotImage.size;
	NSWindow	*	animationWindow = [self uli_animationWindowForZoomEffectWithImage: snapshotImage];
	[animationWindow setFrame: globalStartPoint display: YES];
	[animationWindow orderFront: nil];
	[animationWindow setFrame: myFrame display: YES animate: YES];
	
	NSDisableScreenUpdates();
	[animationWindow close];
	
	[self makeKeyAndOrderFront: nil];
	NSEnableScreenUpdates();
}


-(void)	orderFrontWithZoomEffectFromRect: (NSRect)globalStartPoint
{
    NSImage		*	snapshotImage = [self uli_imageWithSnapshotForceActive: NO];
	NSRect			myFrame = [self frame];
	myFrame.size = snapshotImage.size;
	NSWindow	*	animationWindow = [self uli_animationWindowForZoomEffectWithImage: snapshotImage];
	[animationWindow setFrame: globalStartPoint display: YES];
	[animationWindow orderFront: nil];
	[animationWindow setFrame: myFrame display: YES animate: YES];
	
	NSDisableScreenUpdates();
	[animationWindow close];
	
	[self orderFront: nil];
	NSEnableScreenUpdates();
}


-(void)	orderOutWithZoomEffectToRect: (NSRect)globalEndPoint
{
    NSImage		*	snapshotImage = [self uli_imageWithSnapshotForceActive: NO];
	NSRect			myFrame = [self frame];
	myFrame.size = snapshotImage.size;
	NSWindow	*	animationWindow = [self uli_animationWindowForZoomEffectWithImage: snapshotImage];
	[animationWindow setFrame: myFrame display: YES];
	[animationWindow orderFront: nil];
	[animationWindow setFrame: globalEndPoint display: YES animate: YES];
	
	NSDisableScreenUpdates();
	[animationWindow close];
	
	[self orderFront: nil];
	NSEnableScreenUpdates();
}

@end
