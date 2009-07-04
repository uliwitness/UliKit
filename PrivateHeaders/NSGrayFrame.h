/*
 *  NSGrayFrame.h
 *  HoratioSings
 *
 *  Created by Uli Kusterer on 10.06.05.
 *  Copyright 2005 M. Uli Kusterer. All rights reserved.
 *
 */

// Header for private Apple AppKit class.

#import <Cocoa/Cocoa.h>
#import "NSThemeFrame.h"

@interface NSGrayFrame:NSThemeFrame
{
    char _bottomCornerRounded;
}

+ (void)initialize;
+ (void)drawBevel:(struct _NSRect)fp8 inFrame:(struct _NSRect)fp24 topCornerRounded:(char)fp40 bottomCornerRounded:(char)fp44;
+ (struct _NSSize)sizeOfTitlebarButtons:(unsigned int)fp8;
+ (float)_minXTitlebarWidgetInset:(unsigned int)fp8;
+ (float)_maxXTitlebarWidgetInset:(unsigned int)fp8;
- initWithFrame:(struct _NSRect)fp8 styleMask:(unsigned int)fp24 owner:fp28;
- (void)_setUtilityWindow:(char)fp8;
- (void)setBottomCornerRounded:(char)fp8;
- (char)bottomCornerRounded;
- (struct _NSSize)_topCornerSize;
- (struct _NSSize)_bottomCornerSize;
- (void)drawRect:(struct _NSRect)fp8;
- (void)_setFrameNeedsDisplay:(char)fp8;
- (void)_drawTitleBar:(struct _NSRect)fp8;
- (void)drawWindowBackgroundRect:(struct _NSRect)fp8 level:(int)fp24;
- (void)drawWindowBackgroundRect:(struct _NSRect)fp8;
- (void)drawWindowBackgroundRegion:(void *)fp8 level:(int)fp12;
- (void)drawWindowBackgroundRegion:(void *)fp8;
- (unsigned int)_shadowFlags;
- contentFill;
- (float)_minYTitlebarButtonsOffset;
- (float)_minYTitlebarTitleOffset;
- (struct _NSRect)_maxXminYResizeRect;
- (struct _NSRect)_growBoxRect;
- (void)_drawGrowBoxWithClip:(struct _NSRect)fp8;
- (char)_inactiveButtonsNeedMask;
- (float)_minXTitlebarWidgetInset;
- (float)_maxXTitlebarWidgetInset;
- (struct _NSPoint)_toolbarButtonOrigin;
- (float)_windowTitlebarButtonSpacingWidth;
- (struct _NSSize)sizeOfTitlebarToolbarButton;

@end
