//
//  UKApplicationListController.h
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
