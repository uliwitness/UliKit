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
	CGFloat		mAnimationResizeTime;
}

@property (assign) CGFloat		animationResizeTime;

- (NSTimeInterval)animationResizeTime:(NSRect)newFrame;

@end


@implementation ULIQuicklyAnimatingWindow

@synthesize animationResizeTime = mAnimationResizeTime;

-(id)	initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
	if(( self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen: screen] ))
	{
		mAnimationResizeTime = 0.2;
	}
	
	return self;
}


-(id)	initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	if(( self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag] ))
	{
		mAnimationResizeTime = 0.2;
	}
	
	return self;
}


- (NSTimeInterval)animationResizeTime:(NSRect)newFrame
{
#if 0 && DEBUG
	return ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) ? (mAnimationResizeTime * 10.0) : mAnimationResizeTime;
#else
	return mAnimationResizeTime;
#endif
}

@end


@implementation NSWindow (ULIZoomEffect)

-(NSRect)	uli_startRectForScreen: (NSScreen*)theScreen
{
	NSRect			screenBox = NSZeroRect;
	NSScreen	*	menuBarScreen = [[NSScreen screens] objectAtIndex: 0];
	if( theScreen == nil || menuBarScreen == theScreen )
	{
		// Use menu bar screen:
		screenBox = [menuBarScreen frame];
		
		// Take a rect in the upper left, which should be the menu bar:
		//	(Like Finder in ye olde days)
		screenBox.origin.y += screenBox.size.height -16;
		screenBox.size.height = 16;
		screenBox.size.width = 16;
	}
	else
	{
		// On all other screens, pick a box in the center:
		screenBox = [theScreen frame];
		screenBox.origin.y += truncf(screenBox.size.height /2) -8;
		screenBox.origin.x += truncf(screenBox.size.width /2) -8;
		screenBox.size.height = 16;
		screenBox.size.width = 16;
	}
	
	return screenBox;
}


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
    NSImage *image = [[NSImage alloc] initWithSize: NSMakeSize(CGImageGetWidth(windowImage),CGImageGetHeight(windowImage))];
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


-(void)	makeKeyAndOrderFrontWithPopEffect
{
	NSImage		*	snapshotImage = [self uli_imageWithSnapshotForceActive: YES];
	NSRect			myFrame = [self frame];
	NSRect			poppedFrame = NSInsetRect(myFrame, -20, -20);
	myFrame.size = snapshotImage.size;
	NSWindow	*	animationWindow = [self uli_animationWindowForZoomEffectWithImage: snapshotImage];
	[animationWindow setAnimationResizeTime: 0.025];
	[animationWindow setFrame: myFrame display: YES];
	[animationWindow orderFront: nil];
	[animationWindow setFrame: poppedFrame display: YES animate: YES];
	[animationWindow setFrame: myFrame display: YES animate: YES];
	
	NSDisableScreenUpdates();
	[animationWindow close];
	
	[self makeKeyAndOrderFront: nil];
	NSEnableScreenUpdates();
}


-(void)	makeKeyAndOrderFrontWithZoomEffectFromRect: (NSRect)globalStartPoint
{
	if( globalStartPoint.size.width < 1 || globalStartPoint.size.height < 1 )
		globalStartPoint = [self uli_startRectForScreen: [self screen]];
	
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
	if( globalStartPoint.size.width < 1 || globalStartPoint.size.height < 1 )
		globalStartPoint = [self uli_startRectForScreen: [self screen]];
	
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
	if( globalEndPoint.size.width < 1 || globalEndPoint.size.height < 1 )
		globalEndPoint = [self uli_startRectForScreen: [self screen]];
	
    NSImage		*	snapshotImage = [self uli_imageWithSnapshotForceActive: NO];
	NSRect			myFrame = [self frame];
	myFrame.size = snapshotImage.size;
	NSWindow	*	animationWindow = [self uli_animationWindowForZoomEffectWithImage: snapshotImage];
	[animationWindow setFrame: myFrame display: YES];
	
	NSDisableScreenUpdates();
	[animationWindow orderFront: nil];
	[self orderOut: nil];
	NSEnableScreenUpdates();
	
	[animationWindow setFrame: globalEndPoint display: YES animate: YES];
	
	[animationWindow close];
}

@end
