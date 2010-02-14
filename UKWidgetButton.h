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
	BOOL			mPressed;
	NSColor			*mColor;
	id				mTarget;
	SEL				mAction;
	BOOL			mMouseOver;
	NSTrackingArea	*mTrackingArea;
}

@property (retain) NSColor*		color;
@property (retain) id			target;
@property (assign) SEL			action;

+(NSColor*)	closeButtonColor;
+(NSColor*)	collapseButtonColor;
+(NSColor*)	zoomButtonColor;
+(NSColor*)	inactiveButtonColor;
+(NSColor*)	defaultButtonColor;

+(SEL)		defaultAction;

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