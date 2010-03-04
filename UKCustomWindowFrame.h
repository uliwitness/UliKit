//
//  UKCustomWindowFrame.h
//  HoratioSings
//
//  Created by Uli Kusterer on 09.06.05.
//  Copyright 2005 Uli Kusterer.
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
