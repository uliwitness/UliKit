//
//  UKViewListView.h
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

/* This view automatically arranges its subviews so they are as wide as it
	is and one below the other. Optionally, you can force this view to
	be exactly the same height as the sum of the heights of the views inside
	it, and you can specify margins and spacing for between the views.

	This is very handy with bindings: You can set a view to auto-hide according
	to a specific binding, then call reLayoutViewListViews, and poof, all other
	views will move up accordingly.
 
	The autosizing option in the NIB file should be correctly set (upper-left)
	if the BOOL doAnimateResizing is set to TRUE. Otherwise you might see a
	bad resizing effect during the resizing of the window.
 
	Also be sure to call reLayoutViewListViews after hidding/showing some views,
	so that the window will be updated.
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
	BOOL			doAnimateResizing;		// To have an animation when resizing the window.
	BOOL			isFlipped;				// Use flipped-Y-axis coordinates to avoid problems with NSAnimation during combined fading and resizing.
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

-(void)	setAnimateResizing: (BOOL)animateResizing;

-(NSSize)	bestSize;

-(void)	reLayoutViewListViews;

-(BOOL) isFlipped;
-(void)	setIsFlipped: (BOOL)state;

@end
