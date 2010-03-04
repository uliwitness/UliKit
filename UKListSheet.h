//
//  UKListSheet.h
//  Shovel
//
//  Created by Uli Kusterer on Tue Mar 23 2004.
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

#import <Foundation/Foundation.h>



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
