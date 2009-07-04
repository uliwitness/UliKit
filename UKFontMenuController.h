/* =============================================================================
	PROJECT:	UKFontMenu
	CLASS:		UKFontMenuController
	COPYRIGHT:  (c) 2004 by M. Uli Kusterer, all rights reserved.
   ========================================================================== */

/**	A class to hook up with your "format" menu that provides a list of fonts
	that can be selected to choose a font without waiting hours for the font
	panel to come up.
				
	Create an instance of this in your NIB file (you may have to drag this
	header into Interface Builder's window for the class to show up in the
	'Classes' tab) and connect its fontMenu outlet to the menu at the bottom of
	which you want the fonts to be listed (remember to put a separator at the
	bottom).
	
	At awakeFromNib time, this object will automatically list the fonts in the
	menu. It will always add "Favorites" and "Recently Used" submenus.
	Depending on various other factors, it will also generate additional menus
	and menu items:
	
	-   If you have a font collection named "Font Menu", it will list that
		collection's fonts after the "Recently Used" submenu.
	-   If you have a font collection with the application's name, it will list
		that collection instead.
	-   If you have set the UKFontMenuCollectionName entry in your
		NSUserDefaults, it will list a collection of that name instead.
	-   If neither of these are present, it will add a submenu for each font
		collection you've got in the font panel.
*/ 

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  UKFontMenuController:
// -----------------------------------------------------------------------------

@interface UKFontMenuController : NSObject
{
    IBOutlet NSMenu *fontMenu;		///< Menu we should add our items to. *hook this up in IB!*
	NSString		*newFontFamily; ///< Font last chosen.
	int				newFontSize;	///< Size last chosen (Favorites) or zero.
}

-(void) rebuildMenu: (id)sender;	///< Delete our items from the menu and re-add them.

-(NSMenu*)  fontMenu;							///< Accessor for fontMenu instance variable.
-(void)		setFontMenu: (NSMenu*)theFontMenu;  ///< Mutator for changing fontMenu instance variable.

// private:
-(void)		addFavoritesCollection: (NSString*)collectionID name:(NSString*)collectionName
				toMenu: (NSMenu*)mnu;
-(void)		addAllFontCollectionsToMenu: (NSMenu*)mnu;
-(void)		addFontCollection: (NSString*)collectionName toMenu: (NSMenu*)mnu;

-(void)		collectionsMayHaveChangedNotification: (NSNotification*)notif;

-(IBAction) menuChoiceChangeFont: (id)sender;
-(IBAction) menuChoiceChangeFavoriteFont: (id)sender;


@end
