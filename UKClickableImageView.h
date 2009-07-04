//
//  UKClickableImageView.h
//  CocoaMoose
//
//  Created by Uli Kusterer on Wed Apr 14 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface UKClickableImageView : NSImageView
{
	NSCursor*		cursor;		// Cursor to show while mouse is over this view.
}

-(void)			setCursor: (NSCursor*)theCursor;
-(NSCursor*)	cursor;

@end
