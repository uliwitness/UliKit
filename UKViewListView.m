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
#import "UKHelperMacros.h"


#ifndef UKVIEWLISTVIEW_USE_CONSTRAINTS
#define UKVIEWLISTVIEW_USE_CONSTRAINTS		0
#endif // UKVIEWLISTVIEW_USE_CONSTRAINTS


@implementation UKViewListView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
	{
        // Initialization code here.
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(viewFrameDidChange:) name: NSViewFrameDidChangeNotification object: self];
		interViewSpacing = -1;
		forceToContentHeight = NO;
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
		forceToContentHeight = NO;
		doAnimateResizing = NO;
	}
    return self;
}


-(void)	dealloc
{
	DESTROY_DEALLOC(internalConstraints);
	
	[super dealloc];
}


-(void)	awakeFromNib
{
#if !UKVIEWLISTVIEW_USE_CONSTRAINTS
	[self reLayoutViewListViews];
#endif
}


-(void) drawRect: (NSRect)rect
{
#if 0
	NSDrawGrayBezel( [self bounds], [self bounds] );	// Debugging only.
#endif
}


-(void)	didAddSubview: (NSView*)subview
{
	[super didAddSubview: subview];

#if UKVIEWLISTVIEW_USE_CONSTRAINTS
	[self setNeedsUpdateConstraints: YES];
#else
	[self reLayoutViewListViews];
#endif
}


-(void)	viewDidMoveToWindow
{
#if UKVIEWLISTVIEW_USE_CONSTRAINTS
	[self setNeedsUpdateConstraints: YES];
#else
	[self reLayoutViewListViews];
#endif
}


-(void)	setResizeWindowAndView: (BOOL)resizeBoth
{
	resizeWindowAndView = resizeBoth;
}


-(void)	reLayoutViewListViewsAndAdjustFrame: (BOOL)adjustFrame
{
#if !UKVIEWLISTVIEW_USE_CONSTRAINTS
	if( !isInReLayout )
	{
		isInReLayout = YES;
		[self setHidden: YES];
		
		if( forceToContentHeight && adjustFrame && [self window] )
		{
			BOOL	isContentView = [[self window] contentView] == self;
			if( isContentView || resizeWindowAndView )
			{
				NSWindow*	wd = [self window];
				NSRect		oldBox = [wd contentRectForFrameRect: [wd frame]];
				NSRect		newBox = oldBox;
				NSSize		newSize = [self bestSize];
				NSSize		oldSize = [self frame].size;
				
				// If we're not the content view or not the only view in the window, account for our distance to edges:
				if( !isContentView )
				{
					newSize.width += oldBox.size.width -oldSize.width;
					newSize.height += oldBox.size.height -oldSize.height;
				}
				
				// Calculate new rect, upper-left-relative:
				newBox.size.width = newSize.width;
				newBox.origin.y += newBox.size.height -newSize.height;
				newBox.size.height = newSize.height;
				newBox = [wd frameRectForContentRect: newBox];
				
				// Actually change frame:
				[wd setFrame: newBox display: YES animate: doAnimateResizing];
			}
			
			if( !isContentView || resizeWindowAndView )
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
		[self setHidden: NO];
		isInReLayout = NO;
	}
#endif
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


#if UKVIEWLISTVIEW_USE_CONSTRAINTS
-(void)	updateConstraints
{
	if( YES )
	{
		[self removeConstraints: self.constraints];
		if( !internalConstraints )
			internalConstraints = [[NSMutableArray alloc] init];
		
//		NSArray	*myHConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"|[self]|" options: NSLayoutFormatDirectionLeadingToTrailing metrics: [NSDictionary dictionary] views: NSDictionaryOfVariableBindings(self)];
//		[self addConstraints: myHConstraints];
//		NSArray	*myVConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[self]|" options: NSLayoutFormatDirectionLeadingToTrailing metrics: [NSDictionary dictionary] views: NSDictionaryOfVariableBindings(self)];
//		[self addConstraints: myVConstraints];
		
		NSView	*	prevView = nil;
		NSView	*	lastView = nil;
		for( NSView* currSubview in self.subviews )
		{
			if( currSubview.isHidden )
				continue;
			
			NSArray	*	hConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"|[currSubview]|" options: NSLayoutFormatDirectionLeadingToTrailing metrics: [NSDictionary dictionary] views: NSDictionaryOfVariableBindings(currSubview)];
			NSArray	*	vConstraints = nil;
			if( prevView )
			{
				vConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[prevView][currSubview]" options: NSLayoutFormatDirectionLeadingToTrailing metrics: [NSDictionary dictionary] views: NSDictionaryOfVariableBindings(currSubview,prevView)];
			}
			else
			{
				vConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[currSubview]" options: NSLayoutFormatDirectionLeadingToTrailing metrics: [NSDictionary dictionary] views: NSDictionaryOfVariableBindings(currSubview)];
			}
			[internalConstraints addObjectsFromArray: hConstraints];
			[internalConstraints addObjectsFromArray: vConstraints];
			lastView = prevView = currSubview;
		}
		
		if( lastView )
		{
			NSArray	*	vConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[lastView]|" options: NSLayoutFormatDirectionLeadingToTrailing metrics: [NSDictionary dictionary] views: NSDictionaryOfVariableBindings(lastView)];
			[internalConstraints addObjectsFromArray: vConstraints];
		}
		
		[self addConstraints: internalConstraints];
	}
	
	[super updateConstraints];
}
#endif // UKVIEWLISTVIEW_USE_CONSTRAINTS


+(BOOL)	requiresConstraintBasedLayout
{
	return YES;
}

@end
