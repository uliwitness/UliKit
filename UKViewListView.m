//
//  UKViewListView.m
//  UKViewListView
//
//  Created by Uli Kusterer on 14.10.06.
//  Copyright 2006 Uli Kusterer.
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

#import "UKViewListView.h"
#import "NSView+SetFrameSizePinnedToTopLeft.h"


@implementation UKViewListView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
	{
        // Initialization code here.
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(viewFrameDidChange:) name: NSViewFrameDidChangeNotification object: self];
		interViewSpacing = -1;
		forceToContentHeight = YES;
		doAnimateResizing = NO;
	}
    return self;
}


- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder: coder];
    if( self )
	{
        // Initialization code here.
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(viewFrameDidChange:) name: NSViewFrameDidChangeNotification object: self];
		interViewSpacing = -1;
		forceToContentHeight = YES;
		doAnimateResizing = NO;
	}
    return self;
}



-(void)	awakeFromNib
{
	[self reLayoutViewListViews];
}


-(void) drawRect: (NSRect)rect
{
	//NSDrawGrayBezel( [self bounds], [self bounds] );	// Debugging only.
}


-(void)	didAddSubview: (NSView*)subview
{
	[super didAddSubview: subview];
	
	[self reLayoutViewListViews];	// Invalidates new box.
}


-(void)	viewDidMoveToWindow
{
	[self reLayoutViewListViews];
}


-(void)	reLayoutViewListViewsAndAdjustFrame: (BOOL)adjustFrame
{
	if( !isInReLayout )
	{
		isInReLayout = YES;
		if( forceToContentHeight && adjustFrame )
		{
			if( [[self window] contentView] == self )
			{
				NSWindow*	wd = [self window];
				NSRect		newBox = [wd contentRectForFrameRect: [wd frame]];
				NSSize		newSize = [self bestSize];
				newBox.size.width = newSize.width;
				newBox.origin.y += newBox.size.height -newSize.height;
				newBox.size.height = newSize.height;
				newBox = [wd frameRectForContentRect: newBox];
				[wd setFrame: newBox display: YES animate: doAnimateResizing];
			}
			else
				[self setFrameSizePinnedToTopLeft: [self bestSize]];
		}

		NSRect			myBounds = [self bounds];
		NSPoint			viewPos = NSMakePoint( leftMargin, isFlipped ? topMargin : (NSMaxY( myBounds ) -topMargin) );
		NSArray*		subs = [[[self subviews] copy] autorelease];
		NSEnumerator*	enny = [subs objectEnumerator];
		NSView*			currSubview = nil;
		
		while( (currSubview = [enny nextObject]) )
		{
			if( ![currSubview isHidden] )
			{
				NSRect	currViewBox = [currSubview bounds];
				if( !isFlipped )
					viewPos.y -= currViewBox.size.height;
				currViewBox.origin = viewPos;
				currViewBox.size.width = myBounds.size.width -leftMargin -rightMargin;
				[currSubview setFrame: currViewBox];
				if( !isFlipped )
					viewPos.y -= interViewSpacing;
				else
					viewPos.y += currViewBox.size.height +interViewSpacing;
			}
		}
		
		[self setNeedsDisplay: YES];
		isInReLayout = NO;
	}
}


-(void)	reLayoutViewListViews
{
	[self reLayoutViewListViewsAndAdjustFrame: YES];
}

-(BOOL) isFlipped
{
	return isFlipped;
}


-(void)	setIsFlipped: (BOOL)state
{
	isFlipped = state;
}

-(NSSize)	bestSize
{
	NSSize		bSiz = NSZeroSize;
	
	bSiz.width = [self bounds].size.width;
	bSiz.height = topMargin +bottomMargin;
	
	NSEnumerator*	enny = [[self subviews] objectEnumerator];
	NSView*			currSubview = nil;
	BOOL			isFirst = YES;

	while( (currSubview = [enny nextObject]) )
	{
		if( ![currSubview isHidden] )
		{
			NSRect	currViewBox = [currSubview bounds];
			
			if( isFirst )
				isFirst = NO;
			else
				bSiz.height += interViewSpacing;
			
			bSiz.height += currViewBox.size.height;
		}
	}
	
	return bSiz;
}


-(void)	viewFrameDidChange:	(NSNotification*)notif
{
	[self reLayoutViewListViewsAndAdjustFrame: NO];
}


-(void)	setForceToContentHeight: (BOOL)doForce
{
	forceToContentHeight = doForce;
	if( doForce )
		[self reLayoutViewListViews];
}


-(BOOL) forceToContentHeight
{
	return forceToContentHeight;
}


- (float)leftMargin
{
    return leftMargin;
}

- (void)setLeftMargin:(float)value
{
    if (leftMargin != value)
	{
        leftMargin = value;
    }
}

- (float)rightMargin
{
    return rightMargin;
}

- (void)setRightMargin:(float)value
{
    if (rightMargin != value)
	{
        rightMargin = value;
    }
}

- (float)topMargin
{
    return topMargin;
}

- (void)setTopMargin:(float)value
{
    if (topMargin != value)
	{
        topMargin = value;
    }
}

- (float)bottomMargin
{
    return bottomMargin;
}

- (void)setBottomMargin:(float)value
{
    if (bottomMargin != value)
	{
        bottomMargin = value;
    }
}

- (float)interViewSpacing
{
    return interViewSpacing;
}

- (void)setInterViewSpacing:(float)value
{
    if (interViewSpacing != value)
	{
        interViewSpacing = value;
    }
}

-(void)	setAnimateResizing: (BOOL)animateResizing
{
	doAnimateResizing = animateResizing;
}

@end
