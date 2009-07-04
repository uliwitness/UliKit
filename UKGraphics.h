//
//  UKGraphics.h
//  Shovel
//
//  Created by Uli Kusterer on Thu Mar 25 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <AppKit/AppKit.h>


// Set this to 0 (using the -D flag in xCode's compiler settings) to remove
//  any possible dependencies on Carbon.framework from this code.
//  If this is 1 and you're running 10.3 or later, this will use the Carbon
//  HITheme APIs to draw its stuff, where possible.
#ifndef UK_GRAPHICS_USE_HITHEME
#define UK_GRAPHICS_USE_HITHEME     1
#endif


// Version of NSDrawWhiteBezel() that looks Aqua-ish:
//	This is modeled after NSTextView, not any other bezels.
void	UKDrawWhiteBezel( NSRect box, NSRect clipBox );

// Version of UKDrawWhiteBezel that optionally draws a "accepting drop" highlight for drag'n drop:
void	UKDrawDropHighlightedWhiteBezel( BOOL doHighlight, NSRect box, NSRect clipBox );

// Version of UKDrawDropHighlightedWhiteBezel that optionally draws the bezel "deeper", like NSTextFields are:
void	UKDrawDropHighlightedEditableWhiteBezel( BOOL doHighlight, BOOL isEditable, NSRect box, NSRect clipBox );

// Draw an image well:
void	UKDrawGenericWell( NSRect box, NSRect clipBox );

// Draw an aqua glossy 'fill' in a given rect:
void	UKDrawGlossGradientOfColorInRect( NSColor *color, NSRect inRect );