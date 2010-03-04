//
//  UKViewBrowser.h
//  HoratioSings
//
//  Created by Uli Kusterer on 10.06.05.
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


// Class that implements a view hierarchy browser. Instantiate one of these in
//  your MainMenu.nib and hook it up to an NSOutlineView in an NSPanel
//  (utility, non-activating), and it will always display the main window's
//  view hierarchy, including window border views etc.

@interface UKViewBrowser : NSObject
{
    IBOutlet NSOutlineView* listView;           // Hook this up in IB to an outline view with column identifiers "class", "name", "frame", "hidden", "flipped" and "opaque".
    NSWindow*               currentWindow;
}

@end
