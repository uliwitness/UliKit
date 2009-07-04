//
//  UKViewListView.h
//  UKViewListView
//
//  Created by Uli Kusterer on 14.10.06.
//  Copyright 2006 M. Uli Kusterer. All rights reserved.
//

/* This view automatically arranges its subviews so they are as wide as it
	is and one below the other. Optionally, you can force this view to
	be exactly the same height as the sum of the heights of the views inside
	it, and you can specify margins and spacing for between the views.

	This is very handy with bindings: You can set a view to auto-hide according
	to a specific binding, then call reLayoutViewListViews, and poof, all other
	views will move up accordingly.
*/

#import <Cocoa/Cocoa.h>


@interface UKViewListView : NSView
{
	float			leftMargin;				// Distance subviews have from left margin of this view.
	float			rightMargin;			// Distance subviews have from right margin of this view.
	float			topMargin;				// Distance top of first subview has from top of this view.
	float			bottomMargin;			// Minimum distance bottom of last subview has from bottom of this view. (only if forceToContentHeight == YES)
	float			interViewSpacing;		// Distance between bottom of one subview and top of the next.
	BOOL			forceToContentHeight;	// Change height of this view to fit all its subviews + margins.
	BOOL			isInReLayout;			// To avoid recursion when layouting views.
}

-(void)	setForceToContentHeight: (BOOL)doForce;
-(BOOL) forceToContentHeight;

- (float)leftMargin;
- (void)setLeftMargin:(float)value;

- (float)rightMargin;
- (void)setRightMargin:(float)value;

- (float)topMargin;
- (void)setTopMargin:(float)value;

- (float)bottomMargin;
- (void)setBottomMargin:(float)value;

- (float)interViewSpacing;
- (void)setInterViewSpacing:(float)value;

-(NSSize)	bestSize;

-(void)	reLayoutViewListViews;
-(void)	observeAllSubviewsVisibilityChanges: (id)sender;

@end
