//
//  UKUpdateChecker.h
//  NiftyFeatures
//
//  Created by Uli Kusterer on Sun Nov 23 2003.
//  Copyright (c) 2003 Uli Kusterer.
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
	Directions: Instantiate one of these in your MainMenu.nib. Hook up your
				"Check for updates..." menu item (should be the second in your
				<application name> menu, immediately after the "About" item) to
				the checkForUpdates: action.
				
				At first startup, this will ask the user whether she wants it
				to check for updates at each startup. It will remember that
				choice in the standard user defaults, and if it was yes, it
				will check at each startup, displaying a message whenever
				a newer version becomes available.
				
				Also note that the URL where this expects the version info file
				to be is in the Localizable.strings file, as are all messages
				this class displays.
*/

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>


// -----------------------------------------------------------------------------
//	Constants:
// -----------------------------------------------------------------------------

// New (MacPad-compatible) Plist keys:
#define UKUpdateCheckerURLFilename			@"MacPAD"				// MacPAD.url file in your bundle's "Resources" folder with URL of .plist file listing the updates.
#define UKUpdateCheckerVersionPlistKey		@"productVersion"		// String holding newest version number.
#define UKUpdateCheckerURLPlistKey			@"productPageURL"		// String with product web page URL.
#define UKUpdateCheckerReleaseNotesPlistKey	@"productReleaseNotes"	// String with list of new stuff in this version.

// Old Plist keys: (legacy, do not use these, only so you can keep your old
//  files until you have time to update them)
#define UKUpdateCheckerOldVersionPlistKey   @"version"				// String holding newest version number.
#define UKUpdateCheckerOldURLPlistKey		@"url"					// String with download web page URL.

// Only check at startup every N days. Since checking every time at startup
//  can cause huge bandwidth problems, you can use this number to adjust the
//  frequency. It won't check more often than once per day, anyway.
#ifndef DAYS_BETWEEN_CHECKS
#define DAYS_BETWEEN_CHECKS					7						// Default: 7, you may change this.
#endif


// -----------------------------------------------------------------------------
//	UKUpdateChecker class:
// -----------------------------------------------------------------------------

@interface UKUpdateChecker : NSObject
{
	IBOutlet NSButton*		prefsButton;		// Optional button in the preferences window for turning "check at startup" on/off.
	NSTimer*				periodicCheckTimer;	// Timer to check periodically if this is a long-running app.
}

// Action for the "check for updates" menu item:
-(IBAction)		checkForUpdates: (id)sender;


// Use this as the action of any "Preferences" button for setting checkAtStartup you may have:
-(IBAction)		takeBoolFromObject: (id)sender;


// This object handles it all for you, but if you need to, use this to turn on/off checking at startup:
-(void)			setCheckAtStartup: (BOOL)shouldCheck;
-(BOOL)			checkAtStartup;


// Private:
-(void)		checkForUpdatesAndNotify: (NSNumber*)doNotifyBool;
-(void)		notifyAboutUpdateToNewVersion: (NSDictionary*)info;

@end
