/*
 *  NSThemeFrame.h
 *  HoratioSings
 *
 *  Created by Uli Kusterer on 10.06.05.
 *  Copyright 2005 M. Uli Kusterer. All rights reserved.
 *
 */

// Header for private Apple AppKit class.

#import <Cocoa/Cocoa.h>
#import "NSTitledFrame.h"

@interface NSThemeFrame:NSTitledFrame
{
    NSButton *toolbarButton;
    int toolbarVisibleStatus;
    NSImage *showToolbarTransitionImage;
    struct _NSSize showToolbarPreWindowSize;
    NSButton *modeButton;
    int leftGroupTrackingTagNum;
    int rightGroupTrackingTagNum;
    char mouseInsideLeftGroup;
    char mouseInsideRightGroup;
    int widgetState;
    NSString *displayName;
}

+ (void)initialize;
+ (float)_windowBorderThickness:(unsigned int)fp8;
+ (float)_minXWindowBorderWidth:(unsigned int)fp8;
+ (float)_maxXWindowBorderWidth:(unsigned int)fp8;
+ (float)_minYWindowBorderHeight:(unsigned int)fp8;
+ (float)_windowTitlebarButtonSpacingWidth:(unsigned int)fp8;
+ (float)_windowFileButtonSpacingWidth:(unsigned int)fp8;
+ (float)_minXTitlebarWidgetInset:(unsigned int)fp8;
+ (float)_maxXTitlebarWidgetInset:(unsigned int)fp8;
+ (float)minFrameWidthWithTitle:fp8 styleMask:(unsigned int)fp12;
+ (float)_windowSideTitlebarTitleMinWidth:(unsigned int)fp8;
+ (float)_windowTitlebarTitleMinHeight:(unsigned int)fp8;
+ (float)_sideTitlebarWidth:(unsigned int)fp8;
+ (float)_titlebarHeight:(unsigned int)fp8;
+ (float)_resizeHeight:(unsigned int)fp8;
+ (char)_resizeFromEdge;
+ (struct _NSSize)sizeOfTitlebarButtons:(unsigned int)fp8;
+ (float)_contentToFrameMinXWidth:(unsigned int)fp8;
+ (float)_contentToFrameMaxXWidth:(unsigned int)fp8;
+ (float)_contentToFrameMinYHeight:(unsigned int)fp8;
+ (float)_contentToFrameMaxYHeight:(unsigned int)fp8;
+ (unsigned int)_validateStyleMask:(unsigned int)fp8;
- (struct _NSSize)_topCornerSize;
- (struct _NSSize)_bottomCornerSize;
- (void *)_createWindowOpaqueShape;
- (void)shapeWindow;
- (void)_recursiveDisplayRectIfNeededIgnoringOpacity:(struct _NSRect)fp8 isVisibleRect:(char)fp24 rectIsVisibleRectForView:fp28 topView:(char)fp32;
- (void *)_regionForOpaqueDescendants:(struct _NSRect)fp8 forMove:(char)fp24;
- (void)_drawFrameInterior:(struct _NSRect *)fp8 clip:(struct _NSRect)fp12;
- (void)_setTextShadow:(char)fp8;
- (void)_drawTitleBar:(struct _NSRect)fp8;
- (void)_drawResizeIndicators:(struct _NSRect)fp8;
- (void)_drawFrameRects:(struct _NSRect)fp8;
- (void)drawFrame:(struct _NSRect)fp8;
- contentFill;
- (void)viewDidEndLiveResize;
- (float)contentAlpha;
- (void)setThemeFrameWidgetState:(int)fp8;
- (char)constrainResizeEdge:(int *)fp8 withDelta:(struct _NSSize)fp12 elapsedTime:(float)fp20;
- (void)addFileButton:fp8;
- (void)_updateButtons;
- (void)_updateButtonState;
- newCloseButton;
- newZoomButton;
- newMiniaturizeButton;
- newToolbarButton;
- newFileButton;
- (void)_resetTitleBarButtons;
- (void)setDocumentEdited:(char)fp8;
- toolbarButton;
- modeButton;
- initWithFrame:(struct _NSRect)fp8 styleMask:(unsigned int)fp24 owner:fp28;
- (void)dealloc;
- (void)setFrameSize:(struct _NSSize)fp8;
- (char)_canHaveToolbar;
- (char)_toolbarIsInTransition;
- (char)_toolbarIsShown;
- (char)_toolbarIsHidden;
- _toolbarView;
- _toolbar;
- (float)_distanceFromToolbarBaseToTitlebar;
- (unsigned int)_shadowFlags;
- (struct _NSRect)frameRectForContentRect:(struct _NSRect)fp8 styleMask:(unsigned int)fp24;
- (struct _NSRect)contentRectForFrameRect:(struct _NSRect)fp8 styleMask:(unsigned int)fp24;
- (struct _NSSize)minFrameSizeForMinContentSize:(struct _NSSize)fp8 styleMask:(unsigned int)fp16;
- (struct _NSRect)contentRect;
- (struct _NSRect)_contentRectExcludingToolbar;
- (struct _NSRect)_contentRectIncludingToolbarAtHome;
- (void)_setToolbarShowHideResizeWeightingOptimizationOn:(char)fp8;
- (char)_usingToolbarShowHideWeightingOptimization;
- (void)handleSetFrameCommonRedisplay;
- (void)_startLiveResizeAsTopLevel;
- (void)_endLiveResizeAsTopLevel;
- (void)_growContentReshapeContentAndToolbarView:(int)fp8 animate:(char)fp12;
- (char)_growWindowReshapeContentAndToolbarView:(int)fp8 animate:(char)fp12;
- (void)_reshapeContentAndToolbarView:(int)fp8 resizeWindow:(char)fp12 animate:(char)fp16;
- (void)_toolbarFrameSizeChanged:fp8 oldSize:(struct _NSSize)fp12;
- (void)_syncToolbarPosition;
- (void)_showHideToolbar:(int)fp8 resizeWindow:(char)fp12 animate:(char)fp16;
- (void)_showToolbarWithAnimation:(char)fp8;
- (void)_hideToolbarWithAnimation:(char)fp8;
- (void)_drawToolbarTransitionIfNecessary;
- (void)drawRect:(struct _NSRect)fp8;
- (void)resetCursorRects;
- (char)shouldBeTreatedAsInkEvent:fp8;
- (char)_shouldBeTreatedAsInkEventInInactiveWindow:fp8;
- hitTest:(struct _NSPoint)fp8;
- (struct _NSRect)_leftGroupRect;
- (struct _NSRect)_rightGroupRect;
- (void)_updateWidgets;
- (void)_updateMouseTracking;
- (void)mouseEntered:fp8;
- (void)mouseExited:fp8;
- (void)_setMouseEnteredGroup:(char)fp8 entered:(char)fp12;
- (char)_mouseInGroup:fp8;
- (struct _NSSize)miniaturizedSize;
- (float)_minXTitlebarDecorationMinWidth;
- (float)_maxXTitlebarDecorationMinWidth;
- (struct _NSSize)minFrameSize;
- (float)_windowBorderThickness;
- (float)_windowTitlebarXResizeBorderThickness;
- (float)_windowTitlebarYResizeBorderThickness;
- (float)_windowResizeBorderThickness;
- (float)_minXWindowBorderWidth;
- (float)_maxXWindowBorderWidth;
- (float)_minYWindowBorderHeight;
- (float)_maxYWindowBorderHeight;
- (float)_minYTitlebarButtonsOffset;
- (float)_minYTitlebarTitleOffset;
- (float)_sideTitlebarWidth;
- (float)_titlebarHeight;
- (struct _NSRect)_titlebarTitleRect;
- (struct _NSRect)titlebarRect;
- (float)_windowTitlebarTitleMinHeight;
- (struct _NSSize)_sizeOfTitlebarFileButton;
- (struct _NSSize)sizeOfTitlebarToolbarButton;
- (float)_windowTitlebarButtonSpacingWidth;
- (float)_windowFileButtonSpacingWidth;
- (float)_minXTitlebarWidgetInset;
- (float)_maxXTitlebarWidgetInset;
- (float)_minXTitlebarButtonsWidth;
- (float)_maxXTitlebarButtonsWidth;
- (struct _NSPoint)_closeButtonOrigin;
- (struct _NSPoint)_zoomButtonOrigin;
- (struct _NSPoint)_collapseButtonOrigin;
- (struct _NSPoint)_toolbarButtonOrigin;
- (struct _NSPoint)_fileButtonOrigin;
- (void)_tileTitlebar;
- (struct _NSRect)_commandPopupRect;
- (void)_resetDragMargins;
- (float)_maxYTitlebarDragHeight;
- (float)_minXTitlebarDragWidth;
- (float)_maxXTitlebarDragWidth;
- (float)_contentToFrameMinXWidth;
- (float)_contentToFrameMaxXWidth;
- (float)_contentToFrameMinYHeight;
- (float)_contentToFrameMaxYHeight;
- (float)_windowResizeCornerThickness;
- (struct _NSRect)_minYResizeRect;
- (struct _NSRect)_minYminXResizeRect;
- (struct _NSRect)_minYmaxXResizeRect;
- (struct _NSRect)_minXResizeRect;
- (struct _NSRect)_minXminYResizeRect;
- (struct _NSRect)_minXmaxYResizeRect;
- (struct _NSRect)_maxYResizeRect;
- (struct _NSRect)_maxYminXResizeRect;
- (struct _NSRect)_maxYmaxXResizeRect;
- (struct _NSRect)_maxXResizeRect;
- (struct _NSRect)_maxXminYResizeRect;
- (struct _NSRect)_maxXmaxYResizeRect;
- (struct _NSRect)_minXTitlebarResizeRect;
- (struct _NSRect)_maxXTitlebarResizeRect;
- (struct _NSRect)_minXBorderRect;
- (struct _NSRect)_maxXBorderRect;
- (struct _NSRect)_maxYBorderRect;
- (struct _NSRect)_minYBorderRect;
- (void)_setUtilityWindow:(char)fp8;
- (char)_isUtility;
- (float)_sheetHeightAdjustment;
- (void)_setSheet:(char)fp8;
- (char)_isSheet;
- (char)_isResizable;
- (char)_isClosable;
- (char)_isMiniaturizable;
- (char)_hasToolbar;
- (struct _NSRect)_growBoxRect;
- (void)_drawGrowBoxWithClip:(struct _NSRect)fp8;
- (char)_inactiveButtonsNeedMask;
- (void)mouseDown:fp8;
- _displayName;
- (void)_setDisplayName:fp8;

@end
