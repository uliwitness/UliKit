//
//  UKApplicationListController.m
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

#import "UKApplicationListController.h"


@implementation ULIApplicationList

-(id)	init
{
	if( (self = [super init]) )
	{
		listOfApplications = [[NSMutableArray alloc] init];
		
		// Instead of on dealloc (which isn't called when we're in MainMenu.nib), we listen for app will quit notifications to save our prefs:
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationWillQuit:) name: NSApplicationWillTerminateNotification object: NSApp];
	}
	
	return self;
}

-(void)	dealloc
{
	[listOfApplications release];
	listOfApplications = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[super dealloc];
}


-(void)	awakeFromNib
{
	// Load list of apps from prefs here!
	NSDictionary*	dict = [[NSUserDefaults standardUserDefaults] objectForKey: [self userDefaultsKey]];
	if( dict )	// Have a list in prefs?
	{
		// Get rid of old one, add the one from prefs:
		[listOfApplications autorelease];
		listOfApplications = [dict mutableCopy];
		
		// Make all entries in the array mutable:
		NSEnumerator*	appEntryEnny = [dict objectEnumerator];
		NSDictionary*	currAppEntry = nil;
		int				x = 0;
		
		while( (currAppEntry = [appEntryEnny nextObject]) )
			[listOfApplications replaceObjectAtIndex: x++ withObject: [[currAppEntry mutableCopy] autorelease] ];
	}
}


-(void)	applicationWillQuit: (NSNotification*)notif
{
	// Save list of app dictionaries to prefs:
	[[NSUserDefaults standardUserDefaults] setObject: listOfApplications forKey: [self userDefaultsKey]];
}


-(NSString*)	userDefaultsKey
{
	if( autosaveName ) {
		return autosaveName;
	} else {
		return @"UKApplicationListController-Apps";
	}
}


-(BOOL)	appInListIsRunning
{
	NSArray<NSRunningApplication *> *runningApps = [[NSWorkspace.sharedWorkspace.runningApplications retain] autorelease];
	
	for (NSDictionary *currApp in listOfApplications) {
		for (NSRunningApplication *currRunningApp in runningApps) {
			if ([[currApp objectForKey: @"applicationPath"] isEqualToString: currRunningApp.bundleURL.path]) {
				return YES;
			}
		}
	}
	
	return NO;
}


-(BOOL)	appInListIsFrontmost
{
	NSRunningApplication *currRunningApp = [[NSWorkspace.sharedWorkspace.frontmostApplication retain] autorelease];
	
	//UKLog(@"currRunningApp: %@", currRunningApp);
	
	for (NSDictionary *currApp in listOfApplications) {
		if( [[currApp objectForKey: @"applicationPath"] isEqualToString: currRunningApp.bundleURL.path] ) {
			return YES;
		}
	}
	
	return NO;
}


-(BOOL)	screenSaverRunning
{
	NSRunningApplication *activeApp = NSWorkspace.sharedWorkspace.frontmostApplication;
	BOOL saverOrFullScreen = activeApp == nil;
	if( activeApp && !saverOrFullScreen )
		saverOrFullScreen = [activeApp.bundleIdentifier isEqualToString: @"com.apple.ScreenSaver.Engine"];
	//UKLog(@"Screen Saver: %s, %@",(saverOrFullScreen?"YES":"NO"),activeApp);
	return( saverOrFullScreen );
}


-(BOOL)	appInListMatches
{
	NSRunningApplication *frontmostApp = NSWorkspace.sharedWorkspace.frontmostApplication;
	NSArray<NSRunningApplication *> *runningApps = [[NSWorkspace.sharedWorkspace.runningApplications retain] autorelease];
	NSString *frontmostAppPath = frontmostApp.bundleURL.path;
	
	for (NSDictionary *currApp in listOfApplications) {
		NSString*	currAppPath = [currApp objectForKey: @"applicationPath"];
		
		if( [[currApp objectForKey: @"mustBeFrontmost"] boolValue] ) {	// Must be frontmost? Just compare against frontmost app:
			if( [currAppPath isEqualToString: frontmostAppPath] ) {
				return YES;
			}
		} else {	// Matches when running, even if in back? Check all running apps whether they're this one:
			for (NSRunningApplication *currRunningApp in runningApps) {
				NSString*	currRunningAppPath = currRunningApp.bundleURL.path;
				
				if( [currAppPath isEqualToString: currRunningAppPath] )
					return YES;
			}
		}
	}
	
	return NO;
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
	}
}

@end


@implementation UKApplicationListController

-(void)	awakeFromNib
{
	[super awakeFromNib];
	
	[addAppButton setBezelStyle: NSBezelStyleSmallSquare];
	[removeAppButton setBezelStyle: NSBezelStyleSmallSquare];
	
	[applicationListView reloadData];
	[removeAppButton setEnabled: ([applicationListView selectedRow] >= 0) ];
}

-(NSInteger)	numberOfRowsInTableView: (NSTableView*)tableView
{
	return [listOfApplications count];
}


-(id)	tableView: (NSTableView*)tableView objectValueForTableColumn: (NSTableColumn*)tableColumn row: (NSInteger)row
{
	NSMutableDictionary*		dict = [listOfApplications objectAtIndex: row];
	
	if( [[tableColumn identifier] isEqualToString: @"mustBeRunning"] )
		return [NSNumber numberWithBool: ![[dict objectForKey: @"mustBeFrontmost"] boolValue]];
	else
		return [dict objectForKey: [tableColumn identifier]];
}


-(void)	tableView: (NSTableView*)tableView setObjectValue: (id)object forTableColumn: (NSTableColumn*)tableColumn row: (NSInteger)row
{
	NSMutableDictionary*		dict = [listOfApplications objectAtIndex: row];
	
	if( [[tableColumn identifier] isEqualToString: @"mustBeRunning"] )
		[dict setObject: [NSNumber numberWithBool: ![object boolValue]] forKey: @"mustBeFrontmost"];
	else
		[dict setObject: object forKey: [tableColumn identifier]];
	[tableView setNeedsDisplay: YES];
}


-(void)	tableViewSelectionDidChange: (NSNotification*)notification
{
	[removeAppButton setEnabled: ([applicationListView selectedRow] >= 0) ];
}


-(void)	removeSelectedApp: (id)sender
{
	NSInteger		selRow = [applicationListView selectedRow];
	
	if( selRow < 0 )
		return;
	
	[listOfApplications removeObjectAtIndex: selRow];
	[applicationListView noteNumberOfRowsChanged];
}


-(void)	addApp: (id)sender
{
	NSOpenPanel*		appPicker = [NSOpenPanel openPanel];
	
	[appPicker setCanChooseDirectories: NO];
	[appPicker setAllowsMultipleSelection: YES];
	[appPicker setCanChooseFiles: YES];
	[appPicker setTreatsFilePackagesAsDirectories: NO];
	[appPicker setAllowedFileTypes: @[ @"app" ]];
	[appPicker setDirectoryURL: [NSURL fileURLWithPath: @"/Applications" isDirectory: YES]];
	
	[appPicker beginSheetModalForWindow: applicationListView.window completionHandler:^(NSModalResponse returnCode) {
		if( returnCode == NSModalResponseOK ) {
			for( NSURL *currFileURL in appPicker.URLs.objectEnumerator ) {
				NSBundle*	currAppBundle = [NSBundle bundleWithURL: currFileURL];
				
				[listOfApplications addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
												[NSNumber numberWithBool: YES], @"mustBeFrontmost",
												currFileURL.path, @"applicationPath",
												currFileURL, @"applicationURL",
												[[NSFileManager defaultManager] displayNameAtPath: currFileURL.path], @"applicationDisplayName",
												[currAppBundle bundleIdentifier], @"bundleIdentifier",
												nil]];
			}
			[applicationListView noteNumberOfRowsChanged];
		}
	}];
}

@end
