//
//	UKFontMenuController.m
//	UKFontMenuController
//
//	
//	Copyright 2004 Uli Kusterer.
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

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import "UKFontMenuController.h"


// -----------------------------------------------------------------------------
//  UKFontMenuController:
// -----------------------------------------------------------------------------

@implementation UKFontMenuController

// -----------------------------------------------------------------------------
//  awakeFromNib:
///		NIB has been loaded, set up font menu.
//
//  REVISIONS:
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(void) awakeFromNib
{
	[self rebuildMenu: self];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(collectionsMayHaveChangedNotification:) name: NSWindowWillCloseNotification object: [NSFontPanel sharedFontPanel]];
}


// -----------------------------------------------------------------------------
//  dealloc:
//		Clean up by getting rid of ssociated objects.
//
//  REVISIONS:
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(void) dealloc
{
	[newFontFamily release];
	
	[super dealloc];
}


// -----------------------------------------------------------------------------
//  rebuildMenu:
///		Remove any old items we added to the menu and append new, updated and
///		more current ones.
//
//  REVISIONS:
//		2004-09-02  UK  Fixed bug in deleting items that would miss submenus.
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(void) rebuildMenu: (id)sender
{
	// Remove any old items:
	id<NSMenuItem>  item = [fontMenu itemAtIndex: [fontMenu numberOfItems] -1];
	while( [item target] == self )  // All items we create have us as the target, even separator lines.
	{
		[fontMenu removeItemAtIndex: [fontMenu numberOfItems] -1];
		item = [fontMenu itemAtIndex: [fontMenu numberOfItems] -1];
	}
	
	// Look for UKFontMenuCollectionName in user defaults:
	NSString*   collectionName = [[NSUserDefaults standardUserDefaults] objectForKey: @"UKFontMenuCollectionName"];
	
	if( collectionName == nil ) // No user defaults? Maybe a collection with app's name?
	{
		NSArray*	colls = [[NSFontManager sharedFontManager] collectionNames];
		NSString*   appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey: @"CFBundleName"];
		if( [colls containsObject: appName] )
			collectionName = appName;
		if( !collectionName && [colls containsObject: NSLocalizedString(@"Font Menu",@"")] )
			collectionName = NSLocalizedString(@"Font Menu",@"");
	}
	
	id<NSMenuItem> sep = nil;
	
	// Add a separator item if there is none yet:
	if( [fontMenu numberOfItems] > 0 && ![item isSeparatorItem] )
	{
		sep = [NSMenuItem separatorItem];
		[fontMenu addItem: sep];
		[sep setTarget: self]; // Put a separator in there to put it apart from the "Favorites".
	}
	
	[self addFavoritesCollection: @"com.apple.Favorites" name: NSLocalizedString(@"Favorites",@"")
				toMenu: fontMenu];  // Add 'Favorites' submenu.
	[self addFavoritesCollection: @"com.apple.Recents" name: NSLocalizedString(@"Recently Used",@"")
				toMenu: fontMenu];  // Add 'Recently used' submenu.
	//[fontMenu setDelegate: self];
	
	if( collectionName )	// Have UKFontMenuCollectionName or app-specific collection? List it!
	{
		sep = [NSMenuItem separatorItem];
		[fontMenu addItem: sep]; // Put a separator in there to put it apart from the "Favorites".
		[sep setTarget: self];
		[self addFontCollection: collectionName toMenu: fontMenu];
	}
	else	// Otherwise, create submenus for *all* collections:
		[self addAllFontCollectionsToMenu: fontMenu];
}


// -----------------------------------------------------------------------------
//  collectionsMayHaveChangedNotification:
///		We got one of the notifications that *may* indicate the collections
///		have changed. Rebuild the menu to make sure it's halfway current.
//
//  REVISIONS:
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(void) collectionsMayHaveChangedNotification: (NSNotification*)notif
{
	[self rebuildMenu: self];
}


// -----------------------------------------------------------------------------
//  addFavoritesCollectionToMenu:
///		Build the "Favorites" menu.
///		Favorites need to be handled specially, as they include a size, and
///		don't preview their font.
//
//  REVISIONS:
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(void) addFavoritesCollection: (NSString*)collectionID name:(NSString*)collectionName toMenu: (NSMenu*)mnu
{
	id <NSMenuItem>		mainItem = [mnu addItemWithTitle: collectionName action: 0 keyEquivalent: @""];
	NSMenu*				submenu = [[[NSMenu alloc] initWithTitle: collectionName] autorelease];
	[mainItem setSubmenu: submenu];
	[mainItem setTarget: self];
	
	NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	NSFontManager*		fm = [NSFontManager sharedFontManager];
	NSArray*			fontDescs = [fm fontDescriptorsInCollection: collectionID];
	NSEnumerator*		descEnny = [fontDescs objectEnumerator];
	NSFontDescriptor*   fdesc;
	int					x = 0;
	
	while( (fdesc = [descEnny nextObject]) )
	{
		NSString*   currFName = [[fdesc fontAttributes] objectForKey: NSFontVisibleNameAttribute];
		if( currFName )  // Somehow we can get invalid names.
		{
			id <NSMenuItem> subitem = [submenu addItemWithTitle: currFName action:@selector(menuChoiceChangeFavoriteFont:) keyEquivalent: @""];
			[subitem setTag: x++];
			[subitem setTarget: self];
		}
	}
	[pool release];

}


// -----------------------------------------------------------------------------
//  addAllFontCollectionsToMenu:
///		Loop over all available font collections (except favorites and recently
///		used), create submenus and call addFontCollection:toMenu: for them.
//
//  REVISIONS:
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(void) addAllFontCollectionsToMenu: (NSMenu*)mnu
{
	NSFontManager*  fm = [NSFontManager sharedFontManager];
	NSArray*		collections = [fm collectionNames];
	NSEnumerator*   enny = [collections objectEnumerator];
	NSString*		collectionName;
	
	while( (collectionName = [enny nextObject]) )
	{
		if( [collectionName isEqualToString: @"com.apple.Favorites"] )  // Skip favorites.
			continue;
		
		if( [collectionName isEqualToString: @"com.apple.Recents"] )	// Skip recents.
			continue;
		
		id <NSMenuItem>		mainItem = [mnu addItemWithTitle: collectionName action: 0 keyEquivalent: @""];
		NSMenu*				submenu = [[[NSMenu alloc] initWithTitle: collectionName] autorelease];
		[mainItem setSubmenu: submenu];
		[mainItem setTarget: self];
		
		[self addFontCollection: collectionName toMenu: submenu];
	}
}


// -----------------------------------------------------------------------------
//  addFontCollection:toMenu:
///		Add a list of the font families in the specified collection to a menu.
///		This will make each item display in its own font, if the charset for
///		name and font don't differ (they usually only do for dingbat-style
///		fonts).
//
//  REVISIONS:
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(void) addFontCollection: (NSString*)collectionName toMenu: (NSMenu*)mnu
{
	NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	NSFontManager*		fm = [NSFontManager sharedFontManager];
	NSArray*			fontDescs = [fm fontDescriptorsInCollection: collectionName];
	NSEnumerator*		descEnny = [fontDescs objectEnumerator];
	NSFontDescriptor*   fdesc;
	NSMutableArray*		foundFonts = [NSMutableArray array];	// Here we keep track of families so we don't list them twice (the different styles show up in the collection as well).
	
	while( (fdesc = [descEnny nextObject]) )
	{
		NSString*   currFName = [[fdesc fontAttributes] objectForKey: NSFontFamilyAttribute];
		if( currFName && ![foundFonts containsObject: currFName] )  // Don't already have that family name?
		{
			// Add menu item for it:
			id<NSMenuItem>  item = [mnu addItemWithTitle: currFName action:@selector(menuChoiceChangeFont:) keyEquivalent: @""];
			[item setTarget: self];
			
			// Now make the title a live preview of the font:
			NSFont*				theFont = [[NSFontManager sharedFontManager] convertFont: [NSFont systemFontOfSize: [NSFont systemFontSize]] toFamily: currFName];
			NSAttributedString*	astr = [[[NSAttributedString alloc] initWithString: currFName attributes: [NSDictionary dictionaryWithObjectsAndKeys: theFont, NSFontAttributeName, nil]] autorelease];
			[item setAttributedTitle: astr];

			[foundFonts addObject: currFName];  // Remember font family so we don't add another item for it.
		}
	}
	[pool release];
}


// -----------------------------------------------------------------------------
//  menuChoiceChangeFont:
///		Menu action for regular font menu items.
//
//  REVISIONS:
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(IBAction) menuChoiceChangeFont: (id)sender
{
	// Keep new font family name in our member variable so convertAttributes can access it:
	[newFontFamily autorelease];
	newFontFamily = nil;	// just being paranoid...
	newFontFamily = [[sender title] retain];
	newFontSize = 0;	// 0 = don't change size.
	
	// Send change message:
	NSResponder*	firstRep = [[NSApp keyWindow] firstResponder];
	
	if( [firstRep respondsToSelector: @selector(changeAttributes:)] )
		[(NSTextView*)firstRep changeAttributes: self];	// Causes call to changeAttributes.
}


// -----------------------------------------------------------------------------
//  menuChoiceChangeFavoriteFont:
///		Menu action for 'favorites' menu items.
//
//  REVISIONS:
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(IBAction) menuChoiceChangeFavoriteFont: (id)sender
{
	[newFontFamily autorelease];
	newFontFamily = nil;	// just being paranoid...

	NSFontManager*		fm = [NSFontManager sharedFontManager];
	NSArray*			fontDescs = [fm fontDescriptorsInCollection: @"com.apple.Favorites"];
	NSFontDescriptor*   fdesc = [fontDescs objectAtIndex: [sender tag]];
	newFontFamily = [[[fdesc fontAttributes] objectForKey: NSFontFamilyAttribute] retain];
	newFontSize = [[[fdesc fontAttributes] objectForKey: NSFontSizeAttribute] intValue];
	
	// Send change message:
	NSResponder*	firstRep = [[NSApp keyWindow] firstResponder];
	
	if( [firstRep respondsToSelector: @selector(changeAttributes:)] )
		[(NSTextView*)firstRep changeAttributes: self];	// Causes call to changeAttributes.
}


// -----------------------------------------------------------------------------
//  convertAttributes:
///		Called for each style run affected by the changeAttributes call we make
///		in our menu item actions.
//
//  REVISIONS:
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(NSDictionary*)	convertAttributes: (NSDictionary*)attributes
{
	NSMutableDictionary*	muDic = [[attributes mutableCopy] autorelease];
	NSFont*					newFont = [[[attributes objectForKey: NSFontAttributeName] retain] autorelease];
	
	if( newFontFamily )
		newFont = [[NSFontManager sharedFontManager] convertFont: newFont toFamily: newFontFamily];
	if( newFontSize > 0 )
		newFont = [[NSFontManager sharedFontManager] convertFont: newFont toSize: newFontSize];
	
	[muDic setObject: newFont forKey: NSFontAttributeName];
	
	return muDic;
}


/*-(int)  numberOfItemsInMenu: (NSMenu*)menu
{
	return [menu numberOfItems];
}


-(BOOL) menu:(NSMenu*)menu updateItem:(NSMenuItem*)item atIndex:(int)index shouldCancel:(BOOL)shouldCancel
{
	if( [item action] == @selector(menuChoiceChangeFont:) )
	{
		if( [item attributedTitle] == nil )
		{
			NSString*			nme = [item title];
			NSFont*				theFont = [[NSFontManager sharedFontManager] convertFont: [NSFont systemFontOfSize: [NSFont systemFontSize]] toFamily: nme];
			NSAttributedString*	astr = [[[NSAttributedString alloc] initWithString: nme attributes: [NSDictionary dictionaryWithObjectsAndKeys: theFont, NSFontAttributeName, nil]] autorelease];
			[item setAttributedTitle: astr];
		}
	}
	
	return !shouldCancel;
}*/



// -----------------------------------------------------------------------------
//  validateMenuItem:
//		Enable/disable menu items we created and checkmark current font in
//		menu.
//
//  REVISIONS:
//		2004-09-01  UK  Created.
// -----------------------------------------------------------------------------

-(BOOL) validateMenuItem: (id<NSMenuItem>)itm
{
	if( ([itm action] == @selector(menuChoiceChangeFont:)
		|| [itm action] == @selector(menuChoiceChangeFavoriteFont:)) )
	{
		// create a fake "Bigger" menu item and ask the responder whether we can enable it:
		NSMenuItem* tempItem = [[[NSMenuItem alloc] initWithTitle: @"Bigger (Fake)" action:@selector(modifyFont:) keyEquivalent:@""] autorelease];
		[tempItem setTag: NSSizeUpFontAction];
		BOOL doEnable = [[[NSApp keyWindow] firstResponder] validateMenuItem: tempItem];
		if( doEnable )
		{
			NSResponder*	firstRep = [[NSApp keyWindow] firstResponder];
			BOOL			editable = [firstRep respondsToSelector: @selector(isEditable)];
			if( editable )
				doEnable = [(NSTextView*)firstRep isEditable];
			
			editable = [firstRep respondsToSelector: @selector(isRichText)];
			if( editable )
				doEnable = [(NSTextView*)firstRep isRichText];
			
			if( doEnable )
				doEnable = [(NSTextView*)firstRep respondsToSelector: @selector(changeAttributes:)];
		}
		if( doEnable && ([itm action] != @selector(menuChoiceChangeFavoriteFont:)) )
		{
			NSString*   currFont = [[[NSFontManager sharedFontManager] selectedFont] familyName];
			[itm setState: [[itm title] isEqualToString: currFont] ];
		}
		
		return doEnable;
	}
	else
		return NO;
}


// ----------------------------------------------------------
// - fontMenu:
// ----------------------------------------------------------

-(NSMenu*)  fontMenu
{
    return fontMenu; 
}

// ----------------------------------------------------------
// - setFontMenu:
// ----------------------------------------------------------
-(void) setFontMenu: (NSMenu*)theFontMenu
{
   fontMenu = theFontMenu;
}


@end
