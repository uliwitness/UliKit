//
//  UKBorderlessWindow.m
//  Filie
//
//  Created by Uli Kusterer on Fri Dec 19 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import "UKBorderlessWindow.h"
#import "NSScreen+ScreenAtPoint.h"


@implementation UKBorderlessWindow

// Designated Initializer:
-(id)   initWithContentRect: (NSRect)box styleMask: (NSUInteger)sty backing: (NSBackingStoreType)bs defer: (BOOL)def
{
	// Remove all "border" attributes. We don't touch the other attributes so we can still have this
	//	work on non-activating panels (NSNonactivatingPanelMask is a style, too).
	sty &= ~(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask);
	
	self = [super initWithContentRect:box styleMask: sty backing:bs defer: def];
	
	if( self != nil )
	{
		constrainRect = NO;
		canBeClosed = NO;
		canBeMinimized = NO;
		canBeZoomed = NO;
		canBecomeMainWindow = YES;
		canBecomeKeyWindow = YES;
	}
	
	return self;
}


// Convenience initializer:
-(id)   initWithContentRect: (NSRect)box backing: (NSBackingStoreType)bs defer: (BOOL)def
{
	return [self initWithContentRect: box styleMask: NSBorderlessWindowMask backing: bs defer: def];
}

-(void) setCanBecomeKeyWindow: (BOOL)n
{
	canBecomeKeyWindow = n;
}

-(BOOL) canBecomeKeyWindow
{
    return canBecomeKeyWindow;
}


-(void) setCanBecomeMainWindow: (BOOL)n
{
	canBecomeMainWindow = n;
}

-(BOOL) canBecomeMainWindow
{
    return canBecomeMainWindow;
}

// Make sure our borderless window may even cover the menu bar if we desire so.
-(NSRect)   constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen
{
	if( !constrainRect )
	{
		//UKLog(@"UKBorderlessWindow NOT constraining rect.");
		return frameRect;
	}
	else
	{
		if( !screen )
			screen = [self screen];
		if( !screen )
			screen = [NSScreen screenAtPoint: frameRect.origin];
		if( !screen )
			screen = [NSScreen mainScreen];
		
		NSRect		wdBox = frameRect;
		NSRect		scBox = [screen frame];
		NSRect		commonBox = NSIntersectionRect( wdBox, scBox );
		
		if( commonBox.size.width < wdBox.size.width )
		{
			float		hOffset = (scBox.origin.x +scBox.size.width) -(wdBox.origin.x +wdBox.size.width);
			
			if( commonBox.origin.x > wdBox.origin.x )
				wdBox.origin.x = commonBox.origin.x;
			else if( hOffset < 0 )
				wdBox.origin.x += hOffset;
		}
		
		if( commonBox.size.height < wdBox.size.height )
		{
			float		vOffset = (scBox.origin.y +scBox.size.height) -(wdBox.origin.y +wdBox.size.height);
			if( commonBox.origin.y > wdBox.origin.y )
				wdBox.origin.y = commonBox.origin.y;
			else if( vOffset < 0 )
				wdBox.origin.y += vOffset;
		}
		
		//UKLog(@"UKBorderlessWindow constraining rect %@ to %@ on screen %@ with rect %@.", NSStringFromRect(frameRect), NSStringFromRect(wdBox), screen, NSStringFromRect(scBox));
		
		return wdBox;
	}
}


-(BOOL)	constrainRect
{
    return constrainRect;
}

-(void)	setConstrainRect: (BOOL)newConstrainRect
{
	constrainRect = newConstrainRect;
}


-(BOOL)	canBeClosed
{
    return canBeClosed;
}

-(void)	setCanBeClosed: (BOOL)newCanBeClosed
{
	canBeClosed = newCanBeClosed;
}

-(BOOL)	canBeMinimized
{
    return canBeMinimized;
}

-(void)	setCanBeMinimized: (BOOL)newCanBeMinimized
{
	canBeMinimized = newCanBeMinimized;
}

-(BOOL)	canBeZoomed
{
    return canBeZoomed;
}

-(void)	setCanBeZoomed: (BOOL)newCanBeZoomed
{
	canBeZoomed = newCanBeZoomed;
}

-(void) setHideWhenNotKey: (BOOL)n
{
	hideWhenNotKey = n;
}

-(BOOL)	hideWhenNotKey
{
	return hideWhenNotKey;
}


-(BOOL)	validateMenuItem: (NSMenuItem*)sender
{
	if( [sender action] == @selector(performClose:) )
		return canBeClosed;
	else if( [sender action] == @selector(performMiniaturize:) )
		return canBeMinimized;
	else if( [sender action] == @selector(performZoom:) )
		return canBeZoomed;
	else
		return [super validateMenuItem: sender];
}


-(void)	performClose:(id)sender
{
	[[self windowController] close];
}


- (void)resignKeyWindow
{
	if( hideWhenNotKey )
	{
		hideWhenNotKey = NO;	// Prevent recursion from our orderOut call.
		[self orderOutIndependentOfParent: self];
		hideWhenNotKey = YES;
	}
}


-(IBAction)	orderOutIndependentOfParent: (id)sender
{
	NSWindow*	parentWin = [self parentWindow];
	if( parentWin )
		[parentWin removeChildWindow: self];	// Otherwise we'll hide the parent window along with us.
	[self orderOut: nil];
	if( parentWin )
		[parentWin makeKeyAndOrderFront: self];
}


@end
