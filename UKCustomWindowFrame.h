//
//  UKCustomWindowFrame.h
//  HoratioSings
//
//  Created by Uli Kusterer on 09.06.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSGrayFrame.h" // Private Apple header! Dangerous!


// To turn all brushed metal windows into windows with a custom pattern,
// use a call like the following early before any such windows are created:
//  [UKCustomWindowFrame installCustomWindowFrame];
//
// By default the windows will be dark gray. You can fill with a tiled image with a call like:
//  [UKCustomWindowFrame setCustomWindowColor: [NSColor colorWithPatternImage: [NSImage imageNamed: @"wood125"]] ];
//
// Or alternately have an image scaled to the window's size with:
//  [UKCustomWindowFrame setCustomWindowImage: [NSImage imageNamed: @"wood125"] ];



@interface UKCustomWindowFrame : NSGrayFrame
{
    // *** Can't have ivars if we're to still be able to pose as NSGrayFrame!
}

+(void) installCustomWindowFrame;

+(void) setCustomWindowColor: (NSColor*)col;    // Color / pattern to fill window with.
+(void) setCustomWindowImage: (NSImage*)img;    // Image to scale over complete window. Overrides color.

+(void) setCustomWindowTextColor: (NSColor*)col;

@end
