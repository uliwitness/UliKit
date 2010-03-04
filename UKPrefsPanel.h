//
//	UKPrefsPanel.h
//	Shovel
//
//	Created by Uli Kusterer on 30.6.2003.
//	Copyright 2003 Uli Kusterer.
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

/*
		A class that creates a simple Safari-like Preferences window with a
		toolbar at the top.
		
		UKPrefsPanel is ridiculously easy to use: Create a tabless NSTabView,
		where the name of each tab is the name for the toolbar item, and the
		identifier of each tab is the identifier to be used for the toolbar
		item to represent it. Then create image files with the identifier as
		their names to be used as icons in the toolbar.
	
		Finally, drag UKPrefsPanel.h into the NIB with the NSTabView,
		instantiate a UKPrefsPanel and connect its tabView outlet to your
		NSTabView. When you open the window, the UKPrefsPanel will
		automatically add a toolbar to the window with all tabs represented by
		a toolbar item, and clicking an item will switch between the tab view's
		items.
*/	

/* -----------------------------------------------------------------------------
	Headers:
   -------------------------------------------------------------------------- */

#import <Foundation/Foundation.h>


/* -----------------------------------------------------------------------------
	Classes:
   -------------------------------------------------------------------------- */

@interface UKPrefsPanel : NSObject
{
	IBOutlet NSTabView*		tabView;			///< The tabless tab-view that we're a switcher for.
	NSMutableDictionary*	itemsList;			///< Auto-generated from tab view's items.
	NSString*				baseWindowName;		///< Auto-fetched at awakeFromNib time. We append a colon and the name of the current page to the actual window title.
	NSString*				autosaveName;		///< Identifier used for saving toolbar state and current selected page of prefs window.
}

/// Mutator for specifying the tab view: (you should just hook this up in IB)
-(void)			setTabView: (NSTabView*)tv;
-(NSTabView*)   tabView;							///< Accessor for tab view containing the different pref panes.

-(void)			setAutosaveName: (NSString*)name;
-(NSString*)	autosaveName;

// Action for hooking up this object and the menu item:
-(IBAction)		orderFrontPrefsPanel: (id)sender;

// You don't have to care about these:
-(void)			mapTabsToToolbar;
-(IBAction)		changePanes: (id)sender;

@end
