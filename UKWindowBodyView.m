//
//  UKWindowBodyView.m
//  ValueConverter
//
//  Created by Uli Kusterer on 26.04.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import "UKWindowBodyView.h"
#import <Carbon/Carbon.h>


@implementation UKWindowBodyView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        // Initialization code here.
    }
    return self;
}

-(void)	changeGradientsOfWindow: (NSWindow*)eswin
{
	if( [eswin respondsToSelector: @selector(setContentBorderThickness:forEdge:)] )
	{
		if( [eswin styleMask] & NSTexturedBackgroundWindowMask )	// Can't set top edge of non-textured windows as of 10.5.2.
		{
			[eswin setAutorecalculatesContentBorderThickness: NO forEdge:NSMaxYEdge];
			float	desiredTopBorderHeight = [[eswin contentView] bounds].size.height -NSMaxY([self frame]);
			[eswin setContentBorderThickness: desiredTopBorderHeight forEdge: NSMaxYEdge];
		}
		
		[eswin setAutorecalculatesContentBorderThickness: NO forEdge: NSMinYEdge];
		float	desiredBottomBorderHeight = NSMinY([self frame]);
		[eswin setContentBorderThickness: desiredBottomBorderHeight forEdge: NSMinYEdge];
    }
}

-(void)	viewWillMoveToSuperview: (NSView *)newSuperview
{
	[self changeGradientsOfWindow: [newSuperview window]];
}

-(void)	viewWillMoveToWindow: (NSWindow *)newWindow
{
	[self changeGradientsOfWindow: newWindow];
}

-(void)	awakeFromNib
{
	[self changeGradientsOfWindow: [self window]];
}

-(void)	drawRect: (NSRect)rect
{
	BOOL	isActive = [[self window] isMainWindow];
	NSRect	box = [self bounds];
	
	HIThemeSetFill( isActive ? kThemeBrushModelessDialogBackgroundActive : kThemeBrushModelessDialogBackgroundInactive,
					NULL, [[NSGraphicsContext currentContext] graphicsPort], kHIThemeOrientationInverted );
	NSRectFill( box );
	
	box.origin.y += 1; box.size.height -= 1;
	[[NSColor colorWithCalibratedWhite: isActive? 0.3 : 0.5 alpha: 1.0] set];
	NSFrameRectWithWidth( box, 1 );
	
	[[NSColor colorWithCalibratedWhite: 0.9 alpha: 0.8] set];
	[NSBezierPath strokeLineFromPoint: NSMakePoint(box.origin.x,box.origin.y -1) toPoint: NSMakePoint(NSMaxX(box),box.origin.y -1)];
}

@end
