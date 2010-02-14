//
//  UKWidgetButton.h
//  UKBorderlessWidgetizedWindow
//
//  Created by Uli Kusterer on 27.10.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


@interface UKWidgetButton : NSView
{
	BOOL			mPressed;		// Draw highlighted?
	NSColor			*mColor;		// What base color to use for the aqua blob.
	id				mTarget;		// Target to send action to when clicked.
	SEL				mAction;		// Action to send to target when clicked.
	BOOL			mMouseOver;		// Mouse is one of the widgets' rect? Should we draw mouse-overed?
	NSTrackingArea	*mTrackingArea;	// Tracking area for mouse-overs.
	NSBezierPath	*mShape;		// Shape to draw overlaid on this button while mouse-overed.
}

@property (retain) NSColor*			color;
@property (retain) id				target;
@property (assign) SEL				action;
@property (retain) NSBezierPath*	shape;

+(NSColor*)			closeButtonColor;
+(NSColor*)			collapseButtonColor;
+(NSColor*)			zoomButtonColor;
+(NSColor*)			inactiveButtonColor;
+(NSColor*)			defaultButtonColor;

+(NSBezierPath*)	closeButtonShape;
+(NSBezierPath*)	collapseButtonShape;
+(NSBezierPath*)	zoomButtonShape;
+(NSBezierPath*)	defaultButtonShape;

+(SEL)				defaultAction;

@end

@interface UKCloseWidgetButton : UKWidgetButton
{
	
}

@end


@interface UKCollapseWidgetButton : UKWidgetButton
{
	
}

@end

@interface UKZoomWidgetButton : UKWidgetButton
{
	
}

@end


NSString*	UKWidgetsMouseEnteredNotification;
NSString*	UKWidgetsMouseLeaveNotification;