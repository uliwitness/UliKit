//
//  UKCustomWindowFrame.m
//  HoratioSings
//
//  Created by Uli Kusterer on 09.06.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "UKCustomWindowFrame.h"


NSColor*        gCustomWindowFrameColor = nil;
NSColor*        gCustomWindowFrameTextColor = nil;
NSImage*        gCustomWindowFrameImage = nil;


@implementation UKCustomWindowFrame

+(void) installCustomWindowFrame
{
    [UKCustomWindowFrame poseAsClass: [NSGrayFrame class]];
}

+(void) setCustomWindowColor: (NSColor*)col
{
    if( gCustomWindowFrameColor != col )
    {
        [gCustomWindowFrameColor release];
        gCustomWindowFrameColor = [col retain];
    }
}

+(void) setCustomWindowTextColor: (NSColor*)col
{
    if( gCustomWindowFrameTextColor != col )
    {
        [gCustomWindowFrameTextColor release];
        gCustomWindowFrameTextColor = [col retain];
    }
}

+(void) setCustomWindowImage: (NSImage*)img
{
    if( gCustomWindowFrameImage != img )
    {
        [gCustomWindowFrameImage release];
        gCustomWindowFrameImage = [img retain];
    }
}


- (void)drawThemeContentFill:(struct _NSRect)rect inView:fp24;
{
    [super drawThemeContentFill: rect inView: fp24];
    
    if( gCustomWindowFrameImage )
    {
        [NSBezierPath clipRect: rect];
        NSRect      srcBox = { { 0,0 }, { 0,0 } };
        NSRect      dstBox = [self bounds];
        srcBox.size = [gCustomWindowFrameImage size];
        [gCustomWindowFrameImage drawInRect: dstBox fromRect: srcBox operation: NSCompositeCopy fraction: 1.0];
    }
    else
    {
        if( gCustomWindowFrameColor == nil )
            gCustomWindowFrameColor = [[NSColor darkGrayColor] retain];
        
        [gCustomWindowFrameColor set];
        [NSBezierPath fillRect: rect];
    }
}

- (void)_drawTitleStringIn:(struct _NSRect)fp8 withColor:fp24
{
    if( gCustomWindowFrameTextColor == nil )
        gCustomWindowFrameTextColor = [[NSColor whiteColor] retain];
        
    [super _drawTitleStringIn: fp8 withColor: gCustomWindowFrameTextColor];
}

@end

@implementation NSColor (UKCustomWindowFrame)

/*+(NSArray*) controlAlternatingRowBackgroundColors
{
    return [NSArray arrayWithObjects:
        [NSColor colorWithCalibratedWhite: 0.4 alpha: 1.0],
        [NSColor colorWithCalibratedWhite: 0.5 alpha: 1.0],
        nil ];
}*/

/*+(NSColor*) controlTextColor
{
    return gCustomWindowFrameTextColor;
}

+(NSColor*) windowBackgroundColor
{
    return gCustomWindowFrameColor;
}*/

@end
