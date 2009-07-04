//
//  UKFileListController.h
//  TalkingMoose (XC2)
//
//  Created by Uli Kusterer on 2005-12-07.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
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
