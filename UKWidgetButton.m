//
//  UKWidgetButton.m
//  UKBorderlessWidgetizedWindow
//
//  Created by Uli Kusterer on 27.10.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "UKWidgetButton.h"
#import "NSColor+UKBrightenDarken.h"


// -----------------------------------------------------------------------------
//	Constants:
// -----------------------------------------------------------------------------

#define WIDGET_SIZE						12.5f

NSString*	UKWidgetsMouseEnteredNotification = @"UKWidgetsMouseEnteredNotification";
NSString*	UKWidgetsMouseLeaveNotification = @"UKWidgetsMouseLeaveNotification";


@implementation UKWidgetButton

@synthesize color = mColor;
@synthesize target = mTarget;
@synthesize action = mAction;
@synthesize shape = mShape;


+(NSColor*)	closeButtonColor
{
	return [NSColor colorWithCalibratedRed: 0.901 green: 0.348 blue: 0.090 alpha: 1.000];
}


+(NSColor*)	collapseButtonColor
{
	return [NSColor colorWithCalibratedRed: 0.983 green: 0.861 blue: 0.153 alpha: 1.000];
}


+(NSColor*)	zoomButtonColor
{
	return [NSColor colorWithCalibratedRed: 0.584 green: 0.962 blue: 0.152 alpha: 1.000];
}


+(NSColor*)	inactiveButtonColor
{
	return [NSColor colorWithCalibratedWhite: 0.9 alpha: 1.0];
}


+(NSColor*)	defaultButtonColor
{
	return [[NSColor colorWithCalibratedRed: 0.054 green: 0.317 blue: 0.979 alpha: 1.000] retain];
}


+(NSBezierPath*)	closeButtonShape
{
	NSBezierPath	*thePath = [NSBezierPath bezierPath];
	NSRect			theBox = NSMakeRect( 2, 8, 10, 2 );
	NSRect			theBox2 = NSMakeRect( 6, 4, 2, 10 );
	
	[thePath appendBezierPathWithRect: theBox];
	[thePath appendBezierPathWithRect: theBox2];
	NSAffineTransform	*trans1 = [NSAffineTransform transform];
	[trans1 translateXBy: -8.0 yBy: -8.0];	// Center over 0,0 ...
	NSAffineTransform	*trans2 = [NSAffineTransform transform];
	[trans2 rotateByDegrees: 45.0];		// ... rotate around 0,0 ...
	NSAffineTransform	*trans3 = [NSAffineTransform transform];
	[trans3 translateXBy: 9.0 yBy: 8.0];	// ... move it back to old position.
	[thePath transformUsingAffineTransform: trans1];
	[thePath transformUsingAffineTransform: trans2];
	[thePath transformUsingAffineTransform: trans3];
	
	return thePath;
}


+(NSBezierPath*)	collapseButtonShape
{
	NSBezierPath	*thePath = [NSBezierPath bezierPath];
	NSRect			theBox = NSMakeRect( 3, 8, 8, 2 );
	
	[thePath appendBezierPathWithRect: theBox];
	
	return thePath;
}


+(NSBezierPath*)	zoomButtonShape
{
	NSBezierPath	*thePath = [NSBezierPath bezierPath];
	NSRect			theBox = NSMakeRect( 3, 8, 8, 2 );
	NSRect			theBox2 = NSMakeRect( 6, 5, 2, 8 );
	
	[thePath appendBezierPathWithRect: theBox];
	[thePath appendBezierPathWithRect: theBox2];
	
	return thePath;
}


+(NSBezierPath*)	defaultButtonShape
{
	NSBezierPath	*thePath = [NSBezierPath bezierPath];
	NSRect			theBox = NSMakeRect( 3, 4, 9, 9 );
	
	[thePath appendBezierPathWithOvalInRect: theBox];
	[thePath appendBezierPathWithOvalInRect: NSInsetRect(theBox,2,2)];
	[thePath setWindingRule: NSEvenOddWindingRule];
	
	return thePath;
}


+(SEL)		defaultAction
{
	return Nil;
}


-(id)	initWithFrame: (NSRect)frame
{
    if(( self = [super initWithFrame: frame] ))
	{
        mColor = [[[self class] defaultButtonColor] retain];	// Fallback is blue, just cuz it's not yet used anywhere.
        mShape = [[[self class] defaultButtonShape] retain];
		mAction = [[self class] defaultAction];
    }
	
    return self;
}


-(void)	dealloc
{
	[mColor release];
	mColor = nil;

	[mTarget release];
	mTarget = nil;

	if( mTrackingArea )
	{
		[self removeTrackingArea: mTrackingArea];
		[mTrackingArea release];
		mTrackingArea = nil;
	}
	
	[mShape release];
	mShape = nil;
	
	[super dealloc];
}


-(void)	viewWillMoveToWindow: (NSWindow *)newWindow
{
	NSWindow*		theWindow = [self window];
	if( theWindow )
	{
		[[NSNotificationCenter defaultCenter] removeObserver: self name: UKWidgetsMouseLeaveNotification object: theWindow];
		[[NSNotificationCenter defaultCenter] removeObserver: self name: UKWidgetsMouseEnteredNotification object: theWindow];
		[[NSNotificationCenter defaultCenter] removeObserver: self name: NSWindowDidBecomeMainNotification object: nil];
		[[NSNotificationCenter defaultCenter] removeObserver: self name: NSWindowDidResignMainNotification object: nil];
	}
	
	[super viewWillMoveToWindow: newWindow];
}


-(void)	viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	
	NSWindow*		theWindow = [self window];
	if( theWindow )
	{
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(mouseEnterInOtherWidget:) name: UKWidgetsMouseEnteredNotification object: theWindow];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(mouseLeaveInOtherWidget:) name: UKWidgetsMouseLeaveNotification object: theWindow];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(owningWindowMainnessChanged:) name: NSWindowDidBecomeMainNotification object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(owningWindowMainnessChanged:) name: NSWindowDidResignMainNotification object: nil];
	}
}


-(void)	mouseEnterInOtherWidget: (NSNotification*)notif
{
	mMouseOver = YES;
	[self setNeedsDisplay: YES];
}


-(void)	mouseLeaveInOtherWidget: (NSNotification*)notif
{
	mMouseOver = NO;
	[self setNeedsDisplay: YES];
}


-(void)	owningWindowMainnessChanged: (NSNotification*)notif
{
	[self setNeedsDisplay: YES];
}


-(void)	drawWidgetWithLightColor: (NSColor*)lightBlue
			darkColor: (NSColor*)darkBlue borderColor: (NSColor*)borderBlue
			mainWindow: (BOOL)areMain
{
	NSColor			*whitenedBlue = [lightBlue blendedColorWithFraction: 0.6f ofColor: [NSColor whiteColor]];
	NSColor			*midBlue = [darkBlue blendedColorWithFraction: 0.5 ofColor: lightBlue];
	NSColor			*shadowBlue = [borderBlue darkenColorBy: 0.1];
	NSRect			oneWidgetBox = NSMakeRect( 1, 2, WIDGET_SIZE, WIDGET_SIZE );
	NSBezierPath	*widgetPath = [NSBezierPath bezierPathWithOvalInRect: oneWidgetBox];
	[widgetPath setLineWidth: 1.0f];
	NSGradient		*widgetBaseGradient = [[[NSGradient alloc] initWithColorsAndLocations:
											whitenedBlue, 0.0, lightBlue, 0.5, midBlue, 0.7, darkBlue, 1.0, nil] autorelease];
	NSGradient		*widgetHighlightGradient = [[[NSGradient alloc] initWithColorsAndLocations:
												[NSColor whiteColor], 0.0f, midBlue, 1.0f, nil] autorelease];
	
	// Draw outer shadows and highlights:
	[NSGraphicsContext saveGraphicsState];
	NSShadow*	edgeHighlight = [[[NSShadow alloc] init] autorelease];
	[edgeHighlight setShadowOffset: NSMakeSize( 0.0f, -1.0f )];
	[edgeHighlight setShadowBlurRadius: 1.5f];
	[edgeHighlight setShadowColor: [NSColor whiteColor]];
	[edgeHighlight set];
	[widgetPath stroke];
	[NSGraphicsContext restoreGraphicsState];

	// Draw main sphere gradient:
	[widgetBaseGradient drawInBezierPath: widgetPath relativeCenterPosition: NSMakePoint( 0, -0.6 )];
	
	// Draw outline:
	[borderBlue set];
	[widgetPath setLineWidth: 0.5f];
	[widgetPath stroke];
	[widgetPath setLineWidth: 1.0f];
	
	// Draw little reflection at top of sphere:
	NSRect	widgetHighlightBox = oneWidgetBox;
	widgetHighlightBox.size.width /= 3;
	widgetHighlightBox.size.height /= 3;
	
	widgetHighlightBox.origin.x += (oneWidgetBox.size.width -widgetHighlightBox.size.width) /2;
	widgetHighlightBox.origin.y += (oneWidgetBox.size.height /2) +(oneWidgetBox.size.height /2 -widgetHighlightBox.size.height) /2;
	widgetHighlightBox.origin.y += widgetHighlightBox.size.height / 2;
	[NSGraphicsContext saveGraphicsState];
	[widgetPath addClip];
	
	NSBezierPath*	widgetHighlightPath = [NSBezierPath bezierPathWithOvalInRect: widgetHighlightBox];
	[widgetHighlightGradient drawInBezierPath: widgetHighlightPath relativeCenterPosition: NSMakePoint( 0, 0.5 )];
	[NSGraphicsContext restoreGraphicsState];
	
	// Draw shadow at top edge:
	NSRect				widgetTopHalfBox = oneWidgetBox;
	widgetTopHalfBox.size.height /= 2;
	widgetTopHalfBox.origin.y += widgetTopHalfBox.size.height;
	widgetTopHalfBox = NSOffsetRect( widgetTopHalfBox, 0.0f, 2.0f );
	NSRect			edgeShadowBox = NSInsetRect( oneWidgetBox, -0.0, -0.5f );
	NSBezierPath*	edgeShadowPath = [NSBezierPath bezierPathWithOvalInRect: edgeShadowBox];
	[NSGraphicsContext saveGraphicsState];
	[NSBezierPath clipRect: NSInsetRect( widgetTopHalfBox, -1.0f, -2.0f )];
	[shadowBlue set];
	[edgeShadowPath stroke];
	[NSGraphicsContext restoreGraphicsState];
	
	// Draw glyph if we're mouse-overed:
	if( mMouseOver )
	{
		[NSGraphicsContext saveGraphicsState];
		NSShadow		*theShadow = [[[NSShadow alloc] init] autorelease];
		[theShadow setShadowOffset: NSMakeSize( 0, -1 )];
		[theShadow setShadowBlurRadius: 0];
		[theShadow setShadowColor: [darkBlue colorWithAlphaComponent: 0.6]];
		[theShadow set];
		[[shadowBlue colorWithAlphaComponent: 0.9] set];
		[mShape fill];
		[NSGraphicsContext restoreGraphicsState];
	}
}


-(void)	drawWidgetWithColor: (NSColor*)theColor mainWindow: (BOOL)areMain
			pressed: (BOOL)pressed
{
	if( !areMain )
		theColor = [[self class] inactiveButtonColor];
	if( pressed )
		theColor = [theColor darkenColorBy: 0.4];
	
	NSColor*		lightColor = [theColor brightenColorBy: 0.6f];
	NSColor*		darkColor = [theColor darkenColorBy: areMain ? 0.5 : 0.3];
	NSColor*		borderColor = [theColor darkenColorBy: areMain ? 0.5 : 0.3];
	
	[self drawWidgetWithLightColor: lightColor darkColor: darkColor borderColor: borderColor
				mainWindow: areMain];
}


-(void) drawRect: (NSRect)dirtyRect
{
	BOOL			areMain = [[self window] isMainWindow] || mMouseOver;

	[self drawWidgetWithColor: mColor mainWindow: areMain pressed: mPressed];
}


- (BOOL)mouseDownCanMoveWindow
{
	return NO;
}

- (void)updateTrackingAreas
{
	if( mTrackingArea )
	{
		[self removeTrackingArea: mTrackingArea];
		[mTrackingArea release];
		mTrackingArea = nil;
	}
	mTrackingArea = [[NSTrackingArea alloc] initWithRect: [self bounds] options: NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited | NSTrackingInVisibleRect
												owner: self userInfo: nil];
	[self addTrackingArea: mTrackingArea];
}


-(void)	mouseDown: (NSEvent*)evt
{
	mPressed = YES;
	[self setNeedsDisplay: YES];
}

-(void)	mouseUp: (NSEvent*)evt
{
	if( mTarget && mAction )
		[mTarget performSelector: mAction withObject: self];
	else if( mTarget )
		[self tryToPerform: mAction with: self];
	
	mPressed = NO;
	[self setNeedsDisplay: YES];
}


-(void)	mouseEntered: (NSEvent*)evt
{
	mMouseOver = YES;
	[self setNeedsDisplay: YES];

	[[NSNotificationCenter defaultCenter] postNotificationName: UKWidgetsMouseEnteredNotification object: [self window]];
}


-(void)	mouseExited: (NSEvent*)evt
{
	mMouseOver = NO;
	[self setNeedsDisplay: YES];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: UKWidgetsMouseLeaveNotification object: [self window]];
}


@end


@implementation UKCloseWidgetButton

+(NSColor*)	defaultButtonColor
{
	return [[self class] closeButtonColor];
}

+(NSBezierPath*)	defaultButtonShape
{
	return [[self class] closeButtonShape];
}

+(SEL)		defaultAction
{
	return @selector(performClose:);
}

@end


@implementation UKCollapseWidgetButton

+(NSColor*)	defaultButtonColor
{
	return [[self class] collapseButtonColor];
}

+(NSBezierPath*)	defaultButtonShape
{
	return [[self class] collapseButtonShape];
}

+(SEL)		defaultAction
{
	return @selector(performMiniaturize:);
}

@end


@implementation UKZoomWidgetButton

+(NSColor*)	defaultButtonColor
{
	return [[self class] zoomButtonColor];
}

+(NSBezierPath*)	defaultButtonShape
{
	return [[self class] zoomButtonShape];
}

+(SEL)		defaultAction
{
	return @selector(performZoom:);
}

@end



