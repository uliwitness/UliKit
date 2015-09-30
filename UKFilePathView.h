//
//  UKFilePathView.h
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
		- UKFadedDrawing.h/.m (for drawing the shortened path components)
*/

@class UKFilePathEntry;	// Private, internal class.


IB_DESIGNABLE
@interface UKFilePathView : NSView
{
	NSString*		filePath;			// The path to be displayed.
	BOOL			noDisplayNames;		// Show actual names, not display names.
	BOOL			canChooseFiles;						// Handed on directly to the open panel.
	BOOL			canChooseDirectories;				// Handed on directly to the open panel.
	BOOL			treatsFilePackagesAsDirectories;	// Handed on directly to the open/save panels.
	BOOL			allowsMultipleSelection;			// Handed on directly to the open/save panels.
	NSURL*			directoryURL;						// Handed on directly to the open/save panels.
	NSString*		message;							// Handed on directly to the open/save panels.
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
	NSUInteger		selectedPathEntry;	// Entry to highlight during mouse tracking.
}

@property (copy) IBInspectable NSString*			filePath;
@property (weak) IBOutlet id						target;
@property (assign) SEL								action;
@property (copy) NSString*							stringValue;        // same as filePath.
@property (copy) IBInspectable NSString*			placeholderString;
@property (assign) IBInspectable NSBorderType		borderType;
@property (assign) IBInspectable BOOL				acceptDrops;
@property (assign) IBInspectable BOOL				allowContextMenu;
@property (copy) NSDictionary*						textAttributes;

// Getters/setters for the NSOpenPanel properties:
@property (assign) IBInspectable BOOL				canChooseFiles;
@property (assign) IBInspectable BOOL				canChooseDirectories;
@property (assign) IBInspectable BOOL				treatsFilePackagesAsDirectories;
@property (assign) IBInspectable BOOL				allowsMultipleSelection;
@property (copy) NSArray*							types;
@property (retain) NSURL*							directoryURL;
@property (copy) IBInspectable NSString*			message;

-(void)				revealInFinder: (id)sender;
-(void)				showRealNames: (id)sender;
-(void)				toggleShowRealNames: (id)sender;

-(NSString*)		fullPathAsDisplayString;

// UI for changing value:
-(IBAction)			pickFile: (id)sender;			// NSOpenPanel. Chooses existing files.
-(IBAction)			pickNewFile: (id)sender;		// NSSavePanel. Lets the user specify name and location for new files.
-(IBAction)			pickNoFile: (id)sender;			// Sets the file path to NIL.

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




