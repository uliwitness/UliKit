//
//  UKFileListController.m
//  TalkingMoose (XC2)
//
//  Created by Uli Kusterer on 2005-12-07.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import "UKFileListController.h"
#import "NSAttributedString+AppendImage.h"


@implementation UKFileListController

-(id)	init
{
	if( (self = [super init]) )
	{
		listOfFiles = [[NSMutableArray alloc] init];
		
		canChooseDirectories = NO;
		canChooseFiles = YES;
	}
	
	return self;
}

-(void)	dealloc
{
	[listOfFiles release];
	listOfFiles = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[super dealloc];
}


-(void)	loadFilesList
{
	if( !inited )
	{
		NSLog( @"loadFilesList \"%@\"", [self userDefaultsKey] );
		inited = YES;
		
		// Load list of files from prefs here!
		NSArray*	dict = [[NSUserDefaults standardUserDefaults] objectForKey: [self userDefaultsKey]];
		if( dict )	// Have a list in prefs?
		{
			// Get rid of old one, add the one from prefs:
			[listOfFiles autorelease];
			listOfFiles = [dict mutableCopy];
		}
		
		[fileListView reloadData];
		[removeFileButton setEnabled: ([fileListView selectedRow] >= 0) ];
	}
}


-(NSString*)	userDefaultsKey
{
	if( autosaveName )
		return autosaveName;
	else
		return @"UKFileListController-Files";
}


-(int)	numberOfRowsInTableView: (NSTableView*)tableView
{
	[self loadFilesList];
	return [listOfFiles count];
}


-(id)	tableView: (NSTableView*)tableView objectValueForTableColumn: (NSTableColumn*)tableColumn row: (int)row
{
	[self loadFilesList];
	NSString*		path = [listOfFiles objectAtIndex: row];
	NSArray*		comps = [[NSFileManager defaultManager] componentsToDisplayForPath: path];
	int				numComps = [comps count];
	NSString*		str = nil;
	
	if( numComps > 2 )
		str = [NSString stringWithFormat: @" '%@' in '%@' on '%@'",
					[comps objectAtIndex: numComps -1], [comps objectAtIndex: numComps -2], [comps objectAtIndex: 0]];
	else if( numComps > 1 )
		str = [NSString stringWithFormat: @" '%@' on '%@'", [comps objectAtIndex: numComps -1], [comps objectAtIndex: 0]];
	else
		str = [NSString stringWithFormat: @" %@", [comps objectAtIndex: 0]];
	
	NSMutableAttributedString*	finalString = [[[NSMutableAttributedString alloc] init] autorelease];
	NSMutableAttributedString*	attrStr = [[[NSMutableAttributedString alloc] initWithString: str] autorelease];
	NSImage*					icon = [[NSWorkspace sharedWorkspace] iconForFile: path];
	
	[icon setSize: NSMakeSize(16,16)];
	
	[finalString appendImage: icon];
	[finalString appendAttributedString: attrStr];
	
	return finalString;
}


-(void)	tableViewSelectionDidChange: (NSNotification*)notification
{
	[removeFileButton setEnabled: ([fileListView selectedRow] >= 0) ];
}


-(void)	removeSelectedFile: (id)sender
{
	int		selRow = [fileListView selectedRow];
	
	if( selRow < 0 )
		return;
	
	[listOfFiles removeObjectAtIndex: selRow];
	[fileListView noteNumberOfRowsChanged];
	[[NSUserDefaults standardUserDefaults] setObject: listOfFiles forKey: [self userDefaultsKey]];
}


-(void)	addFile: (id)sender
{
	NSOpenPanel*		filePicker = [NSOpenPanel openPanel];
	
	[filePicker setCanChooseDirectories: canChooseDirectories];
	[filePicker setAllowsMultipleSelection: YES];
	[filePicker setCanChooseFiles: canChooseFiles];
	[filePicker setTreatsFilePackagesAsDirectories: NO];
	
	[filePicker beginSheetForDirectory: [@"~/Documents" stringByExpandingTildeInPath] file: @"" types: [NSArray array]
					modalForWindow: [fileListView window] modalDelegate: self
					didEndSelector: @selector(filePickerPanelEnded:returnCode:contextInfo:) contextInfo: nil];
}

-(void)	filePickerPanelEnded: (NSOpenPanel*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInf
{
	if( returnCode == NSOKButton )
	{
		[listOfFiles addObjectsFromArray: [sheet filenames]];
		[fileListView noteNumberOfRowsChanged];
		[[NSUserDefaults standardUserDefaults] setObject: listOfFiles forKey: [self userDefaultsKey]];
	}
}


-(NSString*)	autosaveName
{
    return [[autosaveName retain] autorelease]; 
}

-(void)	setAutosaveName: (NSString*)anAutosaveName
{
    if( autosaveName != anAutosaveName )
	{
        [autosaveName release];
        autosaveName = [anAutosaveName copy];
		inited = NO;
		[fileListView setNeedsDisplay: YES];
    }
}


//=========================================================== 
//  canChooseDirectories 
//=========================================================== 
- (BOOL)canChooseDirectories
{
    return canChooseDirectories;
}
- (void)setCanChooseDirectories:(BOOL)flag
{
    canChooseDirectories = flag;
}

//=========================================================== 
//  canChooseFiles 
//=========================================================== 
- (BOOL)canChooseFiles
{
    return canChooseFiles;
}
- (void)setCanChooseFiles:(BOOL)flag
{
    canChooseFiles = flag;
}


@end
