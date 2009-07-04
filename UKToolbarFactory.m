//
//  UKToolbarFactory.m
//  UKToolbarFactory
//
//  Created by Uli Kusterer on Sat Jan 17 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------
 
#import "UKToolbarFactory.h"
#import "UKFirstResponder.h"


@interface UKToolbarFactory (UKToolbarFactoryPrivateMethods)

-(void)		setupToolbar: (id)sender;
-(void)		itemClicked: (NSToolbarItem*)sender;
//-(BOOL)		tryToPerform: (SEL)itemAction with: (id)sender onObject: (NSResponder*)resp;

@end


@implementation UKToolbarFactory

// -----------------------------------------------------------------------------
//	* DESTRUCTOR:
//		Get rid of the objects we created.
//
//	REVISIONS:
//		2004-01-19	witness Documented.
// -----------------------------------------------------------------------------
 
-(void) dealloc
{
	[toolbarItems release];
	[toolbarIdentifier release];
	[super dealloc];
}


// -----------------------------------------------------------------------------
//	awakeFromNib:
//		We were created from a NIB file. Add the toolbar to our window.
//
//	REVISIONS:
//		2004-01-19	witness Documented.
// -----------------------------------------------------------------------------
 
-(void) awakeFromNib
{
	[self setupToolbar: self];  // Create toolbar.
}


// -----------------------------------------------------------------------------
//	setToolbarIdentifier:
//		Lets you change the toolbar identifier at runtime. This will recreate
//		the toolbar from the item definition .plist file for that identifier.
//
//	REVISIONS:
//		2004-01-19	witness Documented.
// -----------------------------------------------------------------------------
 
-(void)			setToolbarIdentifier: (NSString*)str
{
	[str retain];
	[toolbarIdentifier release];
	toolbarIdentifier = str;
	
	[self setupToolbar: nil];   // Recreate toolbar.
}


// -----------------------------------------------------------------------------
//	toolbarIdentifier:
//		Returns the toolbar identifier this object manages. Defaults to the
//		application's bundle identifier with the autosave name of the owning
//		window appended to it.
//
//	REVISIONS:
//		2004-01-19	witness Documented.
// -----------------------------------------------------------------------------
 
-(NSString*)	toolbarIdentifier
{
	if( !toolbarIdentifier )
		toolbarIdentifier = [[NSString stringWithFormat: @"%@.%@", [[NSBundle mainBundle] bundleIdentifier], [owner frameAutosaveName]] retain];
	
	return toolbarIdentifier;
}


// -----------------------------------------------------------------------------
//	toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:
//		Creates the appropriate toolbar item for the specified identifier.
//		This simply lets NSToolbarItem handle system-defined toolbar items,
//		while setting up all others according to the dictionaries from the
//		.plist file.
//
//	REVISIONS:
//		2004-01-19	witness Documented.
// -----------------------------------------------------------------------------
 
-(NSToolbarItem*)   toolbar: (NSToolbar*)toolbar itemForItemIdentifier: (NSString*)itemIdentifier
						willBeInsertedIntoToolbar: (BOOL)flag;
{
	NSDictionary*	allItems = [toolbarItems objectForKey: @"Items"];
	NSDictionary*   currItem;
	NSToolbarItem*  tbi = nil;
		
	// One of the system-provided items?
	if( [itemIdentifier isEqualToString: NSToolbarSeparatorItemIdentifier]
		|| [itemIdentifier isEqualToString: NSToolbarSpaceItemIdentifier]
		|| [itemIdentifier isEqualToString: NSToolbarFlexibleSpaceItemIdentifier]
		|| [itemIdentifier isEqualToString: NSToolbarShowColorsItemIdentifier]
		|| [itemIdentifier isEqualToString: NSToolbarShowFontsItemIdentifier]
		|| [itemIdentifier isEqualToString: NSToolbarPrintItemIdentifier]
		|| [itemIdentifier isEqualToString: NSToolbarCustomizeToolbarItemIdentifier] )
		return [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];
	
	// Otherwise, look it up in our list of custom items:
	currItem = [allItems objectForKey: itemIdentifier];
	if( currItem )
	{
		NSString*	theActionStr = [currItem objectForKey: @"Action"];
		NSString*   viewClassStr = [currItem objectForKey: @"ViewClass"];
		SEL			itemAction = @selector(itemClicked:);
		if( theActionStr && (viewClassStr || ![self isSelectable]) )
			itemAction = NSSelectorFromString(theActionStr);
		NSNumber*	maxw = [currItem objectForKey: @"MaxWidth"];
		NSNumber*	minw = [currItem objectForKey: @"MinWidth"];
		NSString*   itemLabel = [currItem objectForKey: @"Label"];
		NSString*   itemCustomLabel = [currItem objectForKey: @"CustomizationLabel"];
		NSString*   itemTooltip = [currItem objectForKey: @"ToolTip"];
		Class		viewClass = nil;
		if( viewClassStr )
			viewClass = NSClassFromString(viewClassStr);
		NSImage*	itemImage = [NSImage imageNamed: itemIdentifier];
		
		// ... and create an NSToolbarItem for it and set that up:
		tbi = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];
		[tbi setAction: itemAction];
		if( !viewClassStr && [self isSelectable] )
			[tbi setTarget: self];
		if( viewClassStr )	// This isn't a regular item? It's a view?
		{
			NSView*	theView = (NSView*) [[[viewClass alloc] init] autorelease];
			[tbi setView: theView];
			if( theActionStr && [theView respondsToSelector: @selector(setAction:)] )
				[(id)theView setAction: itemAction];
			if( itemLabel && [theView respondsToSelector: @selector(cell)] )
			{
				NSCell*	theCell = [(id)theView cell];
				if( [theCell respondsToSelector: @selector(setPlaceholderString:)] )
					[(id)theCell setPlaceholderString: itemLabel];
			}
		}
		if( minw )
			[tbi setMinSize: NSMakeSize([minw floatValue], 32)];
		if( maxw )
			[tbi setMaxSize: NSMakeSize([maxw floatValue], 32)];
		[tbi setLabel: itemLabel];
		[tbi setImage: itemImage];
		if( itemCustomLabel )
			[tbi setPaletteLabel: itemCustomLabel];
		else
			[tbi setPaletteLabel: itemLabel];
		if( itemTooltip )
			[tbi setToolTip: itemTooltip];
	}
	
	return tbi;
}
    

// -----------------------------------------------------------------------------
//	toolbarDefaultItemIdentifiers:
//		Returns the list of item identifiers we want to be in this toolbar by
//		default. The list is loaded from the .plist file's "DefaultItems" array.
//
//	REVISIONS:
//		2004-01-19	witness Documented.
// -----------------------------------------------------------------------------
 
-(NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar*)toolbar
{
	return [toolbarItems objectForKey: @"DefaultItems"];
}


// -----------------------------------------------------------------------------
//	toolbarAllowedItemIdentifiers:
//		Returns the list of item identifiers that may be in the toolbar. This
//		simply returns the identifiers of all the items in our "Items"
//		dictionary, plus a few sensible defaults like separators and spacer
//		items the user may want to add as well.
//
//		If this function doesn't return the item identifier, it *can't* be in
//		the toolbar. Though if this returns it, that doesn't mean it currently
//		is in the toolbar.
//
//	REVISIONS:
//		2004-01-19	witness Documented.
// -----------------------------------------------------------------------------
 
-(NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*)toolbar
{
	NSDictionary*	allItems = [toolbarItems objectForKey: @"Items"];
	int				icount = [allItems count];
	NSMutableArray*	allowedItems = [NSMutableArray arrayWithCapacity: icount +4];
	NSEnumerator*   allItemItty;
	NSString*		currItem;
	
	for( allItemItty = [allItems keyEnumerator]; currItem = [allItemItty nextObject]; )
		[allowedItems addObject: currItem];
	
	[allowedItems addObject: NSToolbarSeparatorItemIdentifier];
	[allowedItems addObject: NSToolbarSpaceItemIdentifier];
	[allowedItems addObject: NSToolbarFlexibleSpaceItemIdentifier];
	[allowedItems addObject: NSToolbarCustomizeToolbarItemIdentifier];
	
	return allowedItems;
}


-(NSArray*) toolbarSelectableItemIdentifiers: (NSToolbar*)toolbar
{
	if( [self isSelectable] )
	{
		NSDictionary*	allItems = [toolbarItems objectForKey: @"Items"];
		int				icount = [allItems count];
		NSMutableArray*	allowedItems = [NSMutableArray arrayWithCapacity: icount];
		NSEnumerator*   allItemItty;
		NSString*		currItem;
		
		for( allItemItty = [allItems keyEnumerator]; currItem = [allItemItty nextObject]; )
		{
			// View items aren't selectable, but make all others selectable:
			if( [[allItems objectForKey: currItem] objectForKey: @"ViewClass"] == nil )
				[allowedItems addObject: currItem];
		}
		
		return allowedItems;
	}
	else
		return [NSArray array];
}


-(BOOL)	isSelectable
{
	NSNumber*	n = [[toolbarItems objectForKey: @"Options"] objectForKey: @"Selectable"];
	return n && [n boolValue];
}


-(NSString*)	selectedItemIdentifier
{
	return [[owner toolbar] selectedItemIdentifier];
}

-(void)	setSelectedItemIdentifier: (NSString*)str
{
	[[owner toolbar] setSelectedItemIdentifier: str];
}

@end

@implementation UKToolbarFactory (UKToolbarFactoryPrivateMethods)

// -----------------------------------------------------------------------------
//	setupToolbar:
//		(Re)create our toolbar. This loads the .plist file whose name is the
//		toolbar identifier and loads it. Then it adds the toolbar to our
//		window.
//
//	REVISIONS:
//		2004-01-19	witness Documented.
// -----------------------------------------------------------------------------
 
-(void)			setupToolbar: (id)sender
{
	// Load list of items:
	NSString*   toolbarItemsPlistPath = [[NSBundle mainBundle] pathForResource: [self toolbarIdentifier] ofType: @"plist"];
	if( toolbarItems )
		[toolbarItems release];
	toolbarItems = [[NSDictionary dictionaryWithContentsOfFile: toolbarItemsPlistPath] retain];

	// (Re-) create toolbar:
	NSToolbar*  tb = [[[NSToolbar alloc] initWithIdentifier: [self toolbarIdentifier]] autorelease];
	[tb setDelegate: self];
	[tb setAllowsUserCustomization: YES];
	[tb setAutosavesConfiguration: YES];
	[owner setToolbar: tb];
	
	if( [self isSelectable] )
		[self setSelectedItemIdentifier: [[toolbarItems objectForKey: @"DefaultItems"] objectAtIndex: 0]];
}


// -----------------------------------------------------------------------------
//	itemClicked:
//		Toolbar action if we have selectable items. This selects the item, then
//		sends the actual action that the item has.
//
//	REVISIONS:
//		2004-10-03	witness Documented.
// -----------------------------------------------------------------------------
 
-(void)	itemClicked: (NSToolbarItem*)sender
{
	[self setSelectedItemIdentifier: [sender itemIdentifier]];
	
	NSDictionary*	dict = [[toolbarItems objectForKey: @"Items"] objectForKey: [sender itemIdentifier]];
	NSString*		theActionStr = [dict objectForKey: @"Action"];
	if( theActionStr )
	{
		SEL		itemAction = NSSelectorFromString(theActionStr);
		[[UKFirstResponder firstResponder] performSelector: itemAction withObject: sender];
	}
}


@end

