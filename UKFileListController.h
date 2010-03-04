//
//  UKFileListController.h
//  TalkingMoose (XC2)
//
//  Created by Uli Kusterer on 2005-12-07.
//  Copyright 2005 Uli Kusterer.
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

#import <Cocoa/Cocoa.h>


/*
	Class that lets the user select files/folders and keeps a list of them in
	the user defaults, where you can access them.
*/


@interface UKFileListController : NSObject
{
	IBOutlet NSTableView*		fileListView;			// Table to display the files in.
	IBOutlet NSButton*			addFileButton;			// Add a new file to the list.
	IBOutlet NSButton*			removeFileButton;		// Remove selected file from the list.
	NSMutableArray*				listOfFiles;			// List of NSDictionaries with entries for each file.
	NSString*					autosaveName;			// Name to save this list under in prefs.
	BOOL						canChooseDirectories;	// User may add folders to this list? (default NO)
	BOOL						canChooseFiles;			// User may add files to this list? (default YES)
	BOOL						inited;					// Has this object loaded its contents yet?
}

// Button actions:
-(void)			addFile: (id)sender;
-(void)			removeSelectedFile: (id)sender;

// Name to save list of files in user defaults:
- (NSString*)	autosaveName;
- (void)		setAutosaveName: (NSString*)anAutosaveName;

// What kinds of files can users pick?
-(BOOL)			canChooseDirectories;
-(void)			setCanChooseDirectories: (BOOL)state;

-(BOOL)			canChooseFiles;
-(void)			setCanChooseFiles: (BOOL)state;

// private:
-(NSString*)	userDefaultsKey;

@end
