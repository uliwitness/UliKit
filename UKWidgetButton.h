//
//  UKWidgetButton.h
//  UKBorderlessWidgetizedWindow
//
//  Created by Uli Kusterer on 27.10.09.
//  Copyright 2009 Uli Kusterer.
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