//
//  UKGraphics.h
//  Shovel
//
//  Created by Uli Kusterer on Thu Mar 25 2004.
//  Copyright (c) 2004 Uli Kusterer.
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