//
//  UKListSheet.h
//  Shovel
//
//  Created by Uli Kusterer on Tue Mar 23 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
	This is a controller for a window containing an NSTableView with one (or more?)
	column(s?) of checkboxes or radio buttons. It takes an array of objects (usually
	that'll be NSDictionaries) and calls objectValueForKey: and setObjectValue:forKey:
	on them to select/unselect items.
	
	The column's identifier is used as the key for a column, and you have to set up
	the NSTableView in IB accordingly. It will simply perform key-value-coding on
	the dictionaries.
	
	I.e. your dictionaries must contain one object for each column, and the column(s?)
	for checkboxes/radio buttons must contain booleans (NSNumber objects) which will
	be changed depending on which one the user clicks.
*/


@interface UKListSheet : NSObject
{
	IBOutlet NSTableView*   listView;			// Hook up to a list view in the window to become the sheet.
	NSArray*				list;				// Internal storage for remembering your list.
	BOOL					singleSelection;	// Allow only one selection (radio buttons), or several (check boxes)?
}

-(int)		runList: (NSArray*)l modalForWindow: (NSWindow*)owner;

-(BOOL)		singleSelection;
-(void)		setSingleSelection: (BOOL)n;

// Private (hook up in IB):
-(IBAction) sheetButtonClicked: (id)sender;		// The sender's tag indicates what button was clicked.

@end
