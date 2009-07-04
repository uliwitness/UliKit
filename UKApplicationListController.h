//
//  UKApplicationListController.h
//  TalkingMoose (XC2)
//
//  Created by Uli Kusterer on 2005-12-07.
//  Copyright 2005 M. Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/*
	Class that lets the user select applications and keeps a list of them,
	allowing you to query whether any of those apps is running at the moment,
	or even frontmost.
*/


@interface UKApplicationListController : NSObject
{
	IBOutlet NSTableView*		applicationListView;	// Table to display the apps in.
	IBOutlet NSButton*			addAppButton;			// Add a new app to the list.
	IBOutlet NSButton*			removeAppButton;		// Delete selected app from the list.
	NSMutableArray*				listOfApplications;		// List of NSDictionaries with entries for each app.
	NSString*					autosaveName;			// Name to save this list under in prefs.
}

-(BOOL)			appInListIsRunning;			// If any of the apps in the list are running, returns YES. Ignores mustBeFrontmost flag.
-(BOOL)			appInListIsFrontmost;		// If one of the apps in the list is currently the frontmost app, returns YES. Ignores mustBeFrontmost flag.
-(BOOL)			appInListMatches;			// If a mustBeFrontmost-app is frontmost, or a non-mustBeFrontmost is currently running, returns YES.
-(BOOL)			screenSaverRunning;

// Button actions:
-(void)			addApp: (id)sender;
-(void)			removeSelectedApp: (id)sender;

// Name to save list of apps in user defaults:
- (NSString*)	autosaveName;
- (void)		setAutosaveName: (NSString*)anAutosaveName;

// private:
-(NSString*)	userDefaultsKey;
-(void)			applicationWillQuit: (NSNotification*)notif;

@end
