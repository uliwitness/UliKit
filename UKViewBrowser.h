//
//  UKViewBrowser.h
//  HoratioSings
//
//  Created by Uli Kusterer on 10.06.05.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
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
