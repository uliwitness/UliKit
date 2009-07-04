/*
 *  NSTitledFrame.h
 *  HoratioSings
 *
 *  Created by Uli Kusterer on 10.06.05.
 *  Copyright 2005 M. Uli Kusterer. All rights reserved.
 *
 */

// Header for private Apple AppKit class.

#import <Cocoa/Cocoa.h>
#import "NSFrameView.h"


@interface NSTitledFrame:NSFrameView
{
    int resizeFlags;
    id fileButton;      /* NSDocumentDragButton* */
    struct _NSSize titleCellSize;
}

+ (float)_windowBorderThickness:(unsigned int)fp8;
+ (float)_minXWindowBorderWidth:(unsigned int)fp8;
+ (float)_maxXWindowBorderWidth:(unsigned int)fp8;
+ (float)_minYWindowBorderHeight:(unsigned int)fp8;
+ (char)_resizeFromEdge;
+ (struct _NSRect)frameRectForContentRect:(struct _NSRect)fp8 styleMask:(unsigned int)fp24;
+ (struct _NSRect)contentRectForFrameRect:(struct _NSRect)fp8 styleMask:(unsigned int)fp24;
+ (struct _NSSize)minFrameSizeForMinContentSize:(struct _NSSize)fp8 styleMask:(unsigned int)fp16;
+ (struct _NSSize)minContentSizeForMinFrameSize:(struct _NSSize)fp8 styleMask:(unsigned int)fp16;
+ (float)minFrameWidthWithTitle:fp8 styleMask:(unsigned int)fp12;
+ (struct _NSSize)_titleCellSizeForTitle:fp8 styleMask:(unsigned int)fp12;
+ (float)_titleCellHeight:(unsigned int)fp8;
+ (float)_windowTitlebarTitleMinHeight:(unsigned int)fp8;
+ (float)_titlebarHeight:(unsigned int)fp8;
+ (struct _NSSize)sizeOfTitlebarButtons:(unsigned int)fp8;
+ (float)windowTitlebarLinesSpacingWidth:(unsigned int)fp8;
+ (float)windowTitlebarTitleLinesSpacingWidth:(unsigned int)fp8;
+ (float)_contentToFrameMinXWidth:(unsigned int)fp8;
+ (float)_contentToFrameMaxXWidth:(unsigned int)fp8;
+ (float)_contentToFrameMinYHeight:(unsigned int)fp8;
+ (float)_contentToFrameMaxYHeight:(unsigned int)fp8;
- initWithFrame:(struct _NSRect)fp8 styleMask:(unsigned int)fp24 owner:fp28;
- (void)dealloc;
- (void)setIsClosable:(char)fp8;
- (void)setIsResizable:(char)fp8;
- (void)_resetTitleFont;
- (void)_setUtilityWindow:(char)fp8;
- (char)isOpaque;
- (char)worksWhenModal;
- (void)propagateFrameDirtyRects:(struct _NSRect)fp8;
- (void)_showDrawRect:(struct _NSRect)fp8;
- (void)_drawFrameInterior:(struct _NSRect *)fp8 clip:(struct _NSRect)fp12;
- (void)drawFrame:(struct _NSRect)fp8;
- (void)_drawFrameRects:(struct _NSRect)fp8;
- (void)_drawTitlebar:(struct _NSRect)fp8;
- (void)_drawTitlebarPattern:(int)fp8 inRect:(struct _NSRect)fp12 clippedByRect:(struct _NSRect)fp28 forKey:(char)fp44 alignment:(int)fp48;
- (void)_drawTitlebarLines:(int)fp8 inRect:(struct _NSRect)fp12 clippedByRect:(struct _NSRect)fp28;
- frameHighlightColor;
- frameShadowColor;
- (void)setFrameSize:(struct _NSSize)fp8;
- (void)setFrameOrigin:(struct _NSPoint)fp8;
- (void)tileAndSetWindowShape:(char)fp8;
- (void)tile;
- (void)_tileTitlebar;
- (void)setTitle:fp8;
- (char)_shouldRepresentFilename;
- (void)setRepresentedFilename:fp8;
- (void)_drawTitleStringIn:(struct _NSRect)fp8 withColor:fp24;
- titleFont;
- (void)_drawResizeIndicators:(struct _NSRect)fp8;
- titleButtonOfClass:(Class)fp8;
- initTitleButton:fp8;
- newCloseButton;
- newZoomButton;
- newMiniaturizeButton;
- newFileButton;
- fileButton;
- (void)_removeButtons;
- (void)_updateButtons;
- (char)_eventInTitlebar:fp8;
- (char)acceptsFirstMouse:fp8;
- (void)mouseDown:fp8;
- (void)mouseUp:fp8;
- (void)rightMouseDown:fp8;
- (void)rightMouseUp:fp8;
- (int)resizeEdgeForEvent:fp8;
- (struct _NSSize)_resizeDeltaFromPoint:(struct _NSPoint)fp8 toEvent:fp16;
- (struct _NSRect)_validFrameForResizeFrame:(struct _NSRect)fp8 fromResizeEdge:(int)fp24;
- (struct _NSRect)frame:(struct _NSRect)fp8 resizedFromEdge:(int)fp24 withDelta:(struct _NSSize)fp28;
- (char)constrainResizeEdge:(int *)fp8 withDelta:(struct _NSSize)fp12 elapsedTime:(float)fp20;
- (void)resizeWithEvent:fp8;
- (int)resizeFlags;
- (void)resetCursorRects;
- (void)setDocumentEdited:(char)fp8;
- (struct _NSSize)miniaturizedSize;
- (struct _NSSize)minFrameSize;
- (float)_windowBorderThickness;
- (float)_windowTitlebarXResizeBorderThickness;
- (float)_windowTitlebarYResizeBorderThickness;
- (float)_windowResizeBorderThickness;
- (float)_minXWindowBorderWidth;
- (float)_maxXWindowBorderWidth;
- (float)_minYWindowBorderHeight;
- (void)_invalidateTitleCellSize;
- (void)_invalidateTitleCellWidth;
- (float)_titleCellHeight;
- (struct _NSSize)_titleCellSize;
- (float)_titlebarHeight;
- (struct _NSRect)titlebarRect;
- (struct _NSRect)_maxTitlebarTitleRect;
- (struct _NSRect)_titlebarTitleRect;
- (float)_windowTitlebarTitleMinHeight;
- (struct _NSRect)dragRectForFrameRect:(struct _NSRect)fp8;
- (struct _NSSize)sizeOfTitlebarButtons;
- (struct _NSSize)_sizeOfTitlebarFileButton;
- (float)_windowTitlebarButtonSpacingWidth;
- (float)_minXTitlebarButtonsWidth;
- (float)_maxXTitlebarButtonsWidth;
- (int)_numberOfTitlebarLines;
- (float)windowTitlebarLinesSpacingWidth;
- (float)windowTitlebarTitleLinesSpacingWidth;
- (float)_minLinesWidthWithSpace;
- (struct _NSRect)_minXTitlebarLinesRectWithTitleCellRect:(struct _NSRect)fp8;
- (struct _NSRect)_maxXTitlebarLinesRectWithTitleCellRect:(struct _NSRect)fp8;
- (float)_minXTitlebarDecorationMinWidth;
- (float)_maxXTitlebarDecorationMinWidth;
- (struct _NSPoint)_closeButtonOrigin;
- (struct _NSPoint)_zoomButtonOrigin;
- (struct _NSPoint)_collapseButtonOrigin;
- (struct _NSPoint)_fileButtonOrigin;
- (float)_maxYTitlebarDragHeight;
- (float)_minXTitlebarDragWidth;
- (float)_maxXTitlebarDragWidth;
- (float)_contentToFrameMinXWidth;
- (float)_contentToFrameMaxXWidth;
- (float)_contentToFrameMinYHeight;
- (float)_contentToFrameMaxYHeight;
- (struct _NSRect)contentRect;
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

@end
