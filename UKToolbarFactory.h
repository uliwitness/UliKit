//
//  UKToolbarFactory.h
//  UKToolbarFactory
//
//  Created by Uli Kusterer on Sat Jan 17 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

/*
	PURPOSE:
	Easily add toolbars to windows in your application.
	
	DIRECTIONS:
	To use UKToolbarFactory, drag this header file into your NIB file's window.
	Now you'll be able to instantiate a UKToolbarFactory object in your NIB.
	Hook up the UKToolbarFactory's "owner" outlet with the NSWindow on which you
	want a toolbar. Make sure you have specified an "Autosave name" for the
	NSWindow (e.g. "MainWindow").
	
	Now create a file that is named with your application's bundle identifier
	(e.g. "com.mycompany.myapplication"), followed by a period, the autosave
	name of the NSWindow and ".plist"
	(e.g. "com.mycompany.myapplication.MainWindow.plist").
	
	In this file you can now define the toolbar items that will be available in
	your window's toolbar. The file must contain a dictionary of item
	definition dictionaries under the key "Items". These item definition
	dictionaries are stored under the item identifier as the key. The actual
	item definition dictionary contains the following keys (all strings):
	
	Action  -   The selector to call on the first responder when this item is
				clicked, e.g. "close:" or "print:" or "myCustomIBAction:".
	Label   -   The label to display under the toolbar item in the toolbar.
	CustomizationLabel -
				An alternate label to be displayed in the "Customize toolbar"
				window for this item. This can be more detailed. If this isn't
				present, the "Label" will be used here as well.
	ToolTip -   The tool tip to display when the mouse is over this item in the
				toolbar. If this isn't specified, no tooltip is shown.
    ViewClass - If specified, this is the name of an NSView subclass from which
                an object will be created and shown instead of an icon. If the
                view is an NSSearchField or similar class, this will also set
                its placeholder string to the label of the item.
    MaxWidth -  The maximum width for a view-based item. Must be provided if
                ViewClass is specified.
    MinWidth -  The minimum width for a view-based item. Must be provided if
                ViewClass is specified.
	
	The image to be used for the toolbar item must have the item identifier as
	its name (plus any filename extension needed to indicate the image file's
	type, e.g. ".tiff").
	
	The file must also contain an array under the key "DefaultItems", which
	contains the list of item identifiers to be displayed in this toolbar by
	default. Apart from the identifiers in this file, you can also specify
	the identifiers defined by Apple, i.e. NSToolbarSeparatorItem,
	NSToolbarSpaceItem, NSToolbarFlexibleSpaceItem, or NSToolbarCustomizeToolbarItem,
	which are automatically added to the list of allowed items.
	
	If you want to allow NSToolbarShowColorsItem, NSToolbarShowFontsItem, or
	NSToolbarPrintItem, you have to explicitly add them to the "Items" dictionary
	or they won't show up in the customization sheet. You needn't specify any
	actions, labels or tool tips for them, though.
	
    To support selectable items, you have to provide an "Options" dictionary and
    provide a "Selectable" entry, which should be an NSBoolean set to YES. This
    will make all non-view items in the toolbar selectable, and will make sure
    the last one clicked is selected.
    
	To enable/disable toolbar items as needed, implement
		-(BOOL) validateToolbarItem: (NSToolbarItem*)item;
	on the target of the toolbar item's action, just as you'd do for -validateMenuItem:.
*/

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <AppKit/AppKit.h>


// -----------------------------------------------------------------------------
//  UKToolbarFactory:
// -----------------------------------------------------------------------------

@interface UKToolbarFactory : NSObject
{
	IBOutlet NSWindow*		owner;				// Window to put the toolbar on.
	NSDictionary*			toolbarItems;		// List of possible items in the toolbar.
	NSString*				toolbarIdentifier;  // The toolbar identifier and base file name.
	NSString*				selectedItem;		// The currently selected item, if this allows selections.
}

-(void)			setToolbarIdentifier: (NSString*)str;
-(NSString*)	toolbarIdentifier;  // Defaults to the application's bundle identifier with a period and the autosave name of the owning window.

-(NSString*)	selectedItemIdentifier;
-(void)			setSelectedItemIdentifier: (NSString*)str;

-(BOOL)			isSelectable;

@end
