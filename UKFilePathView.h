//
//  UKFilePathView.h
//  Shovel
//
//  Created by Uli Kusterer on Thu Mar 25 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <AppKit/AppKit.h>


/*
	An NSView that displays a file path. This looks kind of like how Sherlock
	displays the location of a file. Basically you get each folder's display
	name with its icon in front of it, and little grey triangles between
	them, and you get the icon of the file or folder at the end and its display
    name.
	
	If the path is too long, this takes items out of the middle and displays
	an ellipsis character (...) instead.
	
	You can also right-click or control-click on this to get a contextual menu
	that contains "Reveal in Finder" and "Show Real Names" menu choices. Real
	names displays the actual path, starting with "/", and using the actual
	file names instead of their display names. As a shortcut, double-clicking
	this view is the same as "Reveal in Finder".
	
	This needs:
		- UKGraphics.h/.m (for drawing the bezel around the view)
*/

@class UKFilePathEntry;	// Private, internal class.


@interface UKFilePathView : NSView
{
	NSString*		filePath;			// The path to be displayed.
	BOOL			noDisplayNames;		// Show actual names, not display names.
	BOOL			canChooseFiles;						// Handed on directly to the open panel.
	BOOL			canChooseDirectories;				// Handed on directly to the open panel.
	BOOL			treatsFilePackagesAsDirectories;	// Handed on directly to the open/save panels.
	NSArray*		types;								// Handed on directly to the open panel.
	SEL				action;
	id				target;
	BOOL			drawDropHighlight;
	NSString*		placeholderString;	// A placeholder to show when path is NIL. Defaults to "none".
	NSBorderType	borderType;
	BOOL			acceptDrops;
	BOOL			allowContextMenu;
	NSMutableArray*	pathEntries;		// array of UKFilePathEntry objects for the path components we display.
	NSDictionary*	textAttributes;		// As you'd have them in an NSAttributedString.
	unsigned		selectedPathEntry;	// Entry to highlight during mouse tracking.
}

-(NSString *)		filePath;
-(void)				setFilePath: (NSString *)newFilePath;

-(id)				target;
-(void)				setTarget: (id) theTarget;

-(SEL)				action;
-(void)				setAction: (SEL) theAction;

-(void)				revealInFinder: (id)sender;
-(void)				showRealNames: (id)sender;
-(void)				toggleShowRealNames: (id)sender;

-(NSString *)		stringValue;					// same as filePath.
-(void)				setStringValue: (NSString*)s;	// same as setFilePath.

-(void)				setPlaceholderString: (NSString*)string;
-(NSString*)		placeholderString;

-(void)				setBorderType: (NSBorderType)aType;	// Only NSBezelBorder and NSNoBorder so far.
-(NSBorderType)		borderType;

-(NSString*)		fullPathAsDisplayString;

-(void)				setAcceptDrops: (BOOL)doAccept;
-(BOOL)				acceptDrops;

-(void)				setAllowContextMenu: (BOOL)doCMM;
-(BOOL)				allowContextMenu;

-(NSDictionary*)	textAttributes;
-(void)				setTextAttributes: (NSDictionary*)dict;

// UI for changing value:
-(IBAction)			pickFile: (id)sender;			// NSOpenPanel. Chooses existing files.
-(IBAction)			pickNewFile: (id)sender;		// NSSavePanel. Lets the user specify name and location for new files.
-(IBAction)			pickNoFile: (id)sender;			// Sets the file path to NIL.

// Getters/setters for the NSOpenPanel properties:
-(BOOL)				canChooseFiles;
-(void)				setCanChooseFiles: (BOOL)flag;

-(BOOL)				canChooseDirectories;
-(void)				setCanChooseDirectories: (BOOL)flag;

-(NSArray*)			types;
-(void)				setTypes: (NSArray*)theTypes;

// Getters/setters for NSOpenPanel/NSSavePanel properties:
-(BOOL)				treatsFilePackagesAsDirectories;
-(void)				setTreatsFilePackagesAsDirectories: (BOOL)flag;

// private:
-(NSImage*)			pathArrowImage;
-(void)				rebuildPathComponentArray;
-(void)				relayoutPathComponents;
-(unsigned)			indexOfPathEntryAtPoint: (NSPoint)pos;
-(UKFilePathEntry*)	lastVisiblePathEntry;

@end


// Some constants we use for this view's metrics:
#define UK_PATH_NAME_LEFT_MARGIN	4
#define UK_PATH_NAME_RIGHT_MARGIN	4
#define UK_PATH_NAME_TOP_MARGIN		2
#define UK_PATH_NAME_BOTTOM_MARGIN  2
#define UK_PATH_NAME_TOTAL_VMARGIN  (UK_PATH_NAME_TOP_MARGIN +UK_PATH_NAME_BOTTOM_MARGIN)
#define UK_PATH_NAME_TOTAL_HMARGIN  (UK_PATH_NAME_LEFT_MARGIN +UK_PATH_NAME_RIGHT_MARGIN)
#define UK_PATH_ARROW_IMG_WIDTH		16
#define UK_PATH_ICON_IMG_WIDTH		16
#define UK_PATH_ICON_NAME_HDISTANCE 2
#define UK_MIN_TEXT_WIDTH			6




