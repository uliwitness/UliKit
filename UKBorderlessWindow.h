//
//  UKBorderlessWindow.h
//  Filie
//
//  Created by Uli Kusterer on Fri Dec 19 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/*
	Set a window's "custom class" in IB to this to make it a borderless
	window, i.e. no title bar, no widgets, no grow box.
*/


@interface UKBorderlessWindow : NSPanel
{
	BOOL	constrainRect;			// If you want a full-screen window covering the menu bar, set this to NO. For splash screens and other "regular" windows, this should be YES.
	BOOL	canBeClosed;			// Use this to let the user close this window using the "Close" menu item.
	BOOL	canBeMinimized;			// Use this to let the user minimize this window using the "Minimize" menu item.
	BOOL	canBeZoomed;			// Use this to let the user zoom this window using the "Zoom" menu item.
	BOOL	canBecomeMainWindow;	// Can this become the main, highlighted window?
	BOOL	canBecomeKeyWindow;		// Can this become the window that has keyboard focus?
	BOOL	hideWhenNotKey;			// Hide this window when it loses key?
}

-(id)   initWithContentRect: (NSRect)box backing: (NSBackingStoreType)bs defer: (BOOL)def;

-(void) setConstrainRect: (BOOL)n;
-(BOOL) constrainRect;

-(void) setCanBeClosed: (BOOL)n;
-(BOOL) canBeClosed;

-(void) setCanBeMinimized: (BOOL)n;
-(BOOL) canBeMinimized;

-(void) setCanBeZoomed: (BOOL)n;
-(BOOL) canBeZoomed;

-(void) setCanBecomeMainWindow: (BOOL)n;
-(BOOL) canBecomeMainWindow;

-(void) setCanBecomeKeyWindow: (BOOL)n;
-(BOOL)	canBecomeKeyWindow;

-(void) setHideWhenNotKey: (BOOL)n;
-(BOOL)	hideWhenNotKey;

@end
