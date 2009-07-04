//
//  UKUpdateChecker.m
//  NiftyFeatures
//
//  Created by Uli Kusterer on Sun Nov 23 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import "UKUpdateChecker.h"
#import "NSData+URLUserAgent.h"


@implementation UKUpdateChecker


// -----------------------------------------------------------------------------
//	awakeFromNib:
//		This object has been created and loaded at startup. If this is first
//		launch, ask user whether we should check for updates periodically at
//		startup and adjust the prefs accurately.
//
//		If the user wants us to check for updates periodically, check whether
//		it is time and if so, initiate the check.
//
//	REVISIONS:
//		2004-03-19	witness	Documented.
// -----------------------------------------------------------------------------

-(void) awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationDidLaunch:) name: NSApplicationDidFinishLaunchingNotification object: NSApp];
}


-(void)	dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[super dealloc];
}


// -----------------------------------------------------------------------------
//	applicationDidLaunch:
//		Application finished launching. Let's check for updates.
//
//	REVISIONS:
//		2005-07-16	witness	Created.
// -----------------------------------------------------------------------------

-(void)	applicationDidLaunch: (NSNotification*)notif
{	
	//UKLog(@"Just checking...");
	
	NSNumber	*   doCheck = [[NSUserDefaults standardUserDefaults] objectForKey: @"UKUpdateChecker:CheckAtStartup"];
	NSString	*   appName = [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]]; 
	NSNumber	*   lastCheckDateNum = [[NSUserDefaults standardUserDefaults] objectForKey: @"UKUpdateChecker:LastCheckDate"];
	NSDate		*   lastCheckDate = nil;
	
	if( doCheck == nil )		// No setting in prefs yet? First launch! Ask!
	{
		if( NSRunAlertPanel( NSLocalizedStringFromTable(@"Check for updates?", @"UKUpdateChecker", @"Asking whether to check for updates at startup - dialog title"),
							NSLocalizedStringFromTable(@"Do you want to be notified when new versions of %@ become available?", @"UKUpdateChecker", @"Asking whether to check for updates at startup - dialog text"),
							NSLocalizedString(@"Yes",nil), NSLocalizedString(@"No",nil), nil, appName ) == NSAlertDefaultReturn )
			doCheck = [NSNumber numberWithBool:YES];
		else
			doCheck = [NSNumber numberWithBool:NO];
		
		// Save user's preference to prefs file:
		[[NSUserDefaults standardUserDefaults] setObject: doCheck forKey: @"UKUpdateChecker:CheckAtStartup"];
	}
	
	[prefsButton setState: [doCheck boolValue]];	// Update prefs button, if we have one.
	
	// If user wants us to check for updates at startup, do so:
	if( [doCheck boolValue] )
	{
		NSTimeInterval  timeSinceLastCheck;
		
		// Determine how long since last check:
		if( lastCheckDateNum == nil )
			lastCheckDate = [NSDate distantPast];  // If there's no date in prefs, use something guaranteed to be past.
		else
			lastCheckDate = [NSDate dateWithTimeIntervalSinceReferenceDate: [lastCheckDateNum doubleValue]];
		timeSinceLastCheck = -[lastCheckDate timeIntervalSinceNow];
		
		// If last check was more than DAYS_BETWEEN_CHECKS days ago, check again now:
		if( timeSinceLastCheck > (3600 *24 *DAYS_BETWEEN_CHECKS) )
		{
			[NSThread detachNewThreadSelector: @selector(checkForUpdatesAndNotify:) toTarget: self withObject: [NSNumber numberWithBool: NO]];
			[[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithDouble: [NSDate timeIntervalSinceReferenceDate]] forKey: @"UKUpdateChecker:LastCheckDate"];
		}
		
		if( periodicCheckTimer )
		{
			[periodicCheckTimer invalidate];
			[periodicCheckTimer release];
		}
		periodicCheckTimer = [[NSTimer scheduledTimerWithTimeInterval: 3600 *24 *DAYS_BETWEEN_CHECKS target: self selector:@selector(checkForUpdates:) userInfo: [NSDictionary dictionary] repeats: YES] retain];
	}
}


// -----------------------------------------------------------------------------
//	checkForUpdates:
//		IBAction to hook up to the "check for updates" menu item.
//
//	REVISIONS:
//		2004-03-19	witness	Documented.
// -----------------------------------------------------------------------------

-(IBAction) checkForUpdates: (id)sender
{
	[NSThread detachNewThreadSelector: @selector(checkForUpdatesAndNotify:) toTarget: self withObject: [NSNumber numberWithBool: YES]];
	// YES means we *also* tell the user about failure, since this is in response to a menu item.
}


// -----------------------------------------------------------------------------
//	latestVersionsDictionary:
//		Load a dictionary containing info on the latest versions of this app.
//
//		This first tries to get MacPAD-compatible version information. If the
//		developer didn't provide that, it will try the old UKUpdateChecker
//		scheme instead.
//
//	REVISIONS:
//		2004-03-19	witness	Documented.
// -----------------------------------------------------------------------------

-(NSDictionary*)	latestVersionsDictionary
{
	NSString*   fpath = [[NSBundle mainBundle] pathForResource: UKUpdateCheckerURLFilename ofType: @"url"];
	
	// Do we have a MacPAD.url file?
	if( [[NSFileManager defaultManager] fileExistsAtPath: fpath] )  // MacPAD-compatible!
	{
		NSString*		urlfile = [NSString stringWithContentsOfFile: fpath];
		NSArray*		lines = [urlfile componentsSeparatedByString: @"\n"];
		NSString*		urlString = [lines lastObject];   // Either this is the only line, or the line following [InternetShortcut]
		
		if( [urlString characterAtIndex: [urlString length] -1] == '/'		// Directory path? Append bundle identifier and .plist to get an actual file path to download.
			|| [urlString characterAtIndex: [urlString length] -1] == '=' ) // CGI parameter?
			urlString = [[urlString stringByAppendingString: [[NSBundle mainBundle] bundleIdentifier]] stringByAppendingString: @".plist"];
	
		return [NSDictionary dictionaryWithContentsOfURL: [NSURL URLWithString: urlString]];	// Download info from that URL.
	}
	else	// Old-style UKUpdateChecker stuff:
	{
		NSURL*			versDictURL = [NSURL URLWithString: NSLocalizedString(@"UPDATE_PLIST_URL", @"URL where the plist with the latest version numbers is.")];
		NSDictionary*   allVersionsDict = [NSDictionary dictionaryWithContentsOfURL: versDictURL];
		return [allVersionsDict objectForKey: [[NSBundle mainBundle] bundleIdentifier]];
	}
}


// -----------------------------------------------------------------------------
//	checkForUpdatesAndNotify:
//		This does the actual update checking. This is called in a new thread
//		usually to make sure the user doesn't have to wait to work with their
//		app until this has succeeded or even worse timed out with an error.
//
//	REVISIONS:
//		2004-10-19	witness	Documented, made to run in another thread,
//							extracted actual notification into method
//							notifyAboutUpdateToNewVersion:.
// -----------------------------------------------------------------------------

-(void)		checkForUpdatesAndNotify: (NSNumber*)doNotifyBool
{
	NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
	BOOL			doNotify = [doNotifyBool boolValue];
	// Load a .plist of application version info from a web URL:
    NSDictionary *  appVersionDict = [self latestVersionsDictionary];
	BOOL			succeeded = NO;
    
    if( appVersionDict != nil )		// We were able to download a dictionary?
	{
		// Extract version number and URL from dictionary:
		NSString *newVersion = [appVersionDict valueForKey: UKUpdateCheckerVersionPlistKey];
        NSString *newUrl = [appVersionDict valueForKey: UKUpdateCheckerURLPlistKey];
        NSString *newReleaseNotes = [appVersionDict valueForKey: UKUpdateCheckerReleaseNotesPlistKey];
        
		if( !newVersion || !newUrl )	// Dictionary doesn't contain new MacPAD stuff? Use old UKUpdateChecker stuff instead.
		{
			newVersion = [appVersionDict valueForKey:UKUpdateCheckerOldVersionPlistKey];
			newUrl = [appVersionDict valueForKey:UKUpdateCheckerOldURLPlistKey];
		}
		
		if( !newReleaseNotes )
			newReleaseNotes = @"";
		
		// Is it current? Then tell the user, or just quietly go on, depending on doNotify:
        if( [newVersion isEqualToString: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] )
		{
            if( doNotify )
				[self performSelectorOnMainThread: @selector(notifyAboutUpdateToNewVersion:)
							withObject:[NSDictionary dictionaryWithObjectsAndKeys: nil] waitUntilDone: YES];
			succeeded = YES;
        }
		else if( newVersion != nil )	// If there's an entry for this app:
		{
			// Ask user whether they'd like to open the URL for the new version:
			[self performSelectorOnMainThread: @selector(notifyAboutUpdateToNewVersion:)
						 withObject: [NSDictionary dictionaryWithObjectsAndKeys:
															newVersion, UKUpdateCheckerVersionPlistKey,
															newUrl, UKUpdateCheckerURLPlistKey,
															newReleaseNotes, UKUpdateCheckerReleaseNotesPlistKey,
															nil] waitUntilDone: YES];

            succeeded = YES;	// Otherwise, it's still a success.
        }
    }
	
	// Failed? File not found, no internet, there is no entry for our app?
	if( !succeeded && doNotify )
		[self performSelectorOnMainThread: @selector(notifyAboutUpdateToNewVersion:)
			withObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool: YES], @"isError", nil] waitUntilDone: YES];

	[pool release];
}


// -----------------------------------------------------------------------------
//	notifyAboutUpdateToNewVersion:
//		This actually tells the user about new updates, and is therefore called
//		on the main thread.
//
//	REVISIONS:
//		2004-10-19	witness	Documented, extracted from checkForUpdatesAndNotify:.
// -----------------------------------------------------------------------------

-(void)	notifyAboutUpdateToNewVersion: (NSDictionary*)info
{
	NSString*	appName = [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]];
	NSString*	newVersion = [info objectForKey: UKUpdateCheckerVersionPlistKey];
	NSString*	newUrl = [info objectForKey: UKUpdateCheckerURLPlistKey];
	NSString*	newReleaseNotes = [info objectForKey: UKUpdateCheckerReleaseNotesPlistKey];
	NSNumber*	errBoolObj = [info objectForKey: @"isError"];
	BOOL		isError = errBoolObj ? [errBoolObj boolValue] : NO;
	
	if( newVersion == nil && !isError )
		NSRunAlertPanel(NSLocalizedStringFromTable(@"Up to date", @"UKUpdateChecker", @"When soft is up-to-date - dialog title"),
				NSLocalizedStringFromTable(@"There are no updates for %@ available.", @"UKUpdateChecker", @"When soft is up-to-date - dialog text"),
				NSLocalizedStringFromTable(@"OK", @"UKUpdateChecker", @""), nil, nil, appName );
	else if( newVersion != nil && !isError )
	{
		int button = NSRunAlertPanel(
				NSLocalizedStringFromTable(@"New Version Available", @"UKUpdateChecker", @"A New Version is Available - dialog title"),
				NSLocalizedStringFromTable(@"A new version of %@ (%@) is available:\n\n%@\n\nDownload now?", @"UKUpdateChecker", @"A New Version is Available - dialog text"),
				NSLocalizedStringFromTable(@"OK", @"UKUpdateChecker", @""), NSLocalizedStringFromTable(@"Cancel", @"UKUpdateChecker", @""), nil,
				appName, newVersion, newReleaseNotes );
		if( NSOKButton == button )	// Yes?
			[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:newUrl]];   //Open!
	}
	else
	{
		NSRunAlertPanel( NSLocalizedStringFromTable(@"Error", @"UKUpdateChecker", @"When update test failed - dialog title"),
						 NSLocalizedStringFromTable(@"%@ encountered an unknown error.", @"UKUpdateChecker", @"When update test failed - dialog text"),
						 @"OK", nil, nil, appName );
	}
}


// -----------------------------------------------------------------------------
//	takeBoolFromObject:
//		Action for the "check at startup" checkbox in your preferences.
//
//	REVISIONS:
//		2004-10-19	witness	Documented.
// -----------------------------------------------------------------------------

-(IBAction)		takeBoolFromObject: (id)sender
{
	BOOL		newState = NO;
	if( [sender respondsToSelector: @selector(boolValue)] )
		newState = [sender boolValue];
	else
		newState = [sender state];
	
	[self setCheckAtStartup: newState];
}


// -----------------------------------------------------------------------------
//	setCheckAtStartup:
//		Mutator for startup check (de)activation.
//
//	REVISIONS:
//		2004-10-19	witness	Documented.
// -----------------------------------------------------------------------------

-(void)			setCheckAtStartup: (BOOL)shouldCheck
{
	NSNumber*		doCheck = [NSNumber numberWithBool: shouldCheck];
	[[NSUserDefaults standardUserDefaults] setObject: doCheck forKey: @"UKUpdateChecker:CheckAtStartup"];
	
	[prefsButton setState: shouldCheck];
	[[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithDouble: 0] forKey: @"UKUpdateChecker:LastCheckDate"];
	
	if( periodicCheckTimer )
	{
		[periodicCheckTimer invalidate];
		[periodicCheckTimer release];
	}
	
	if( shouldCheck )
		periodicCheckTimer = [[NSTimer scheduledTimerWithTimeInterval: 3600 *24 *DAYS_BETWEEN_CHECKS target: self selector:@selector(checkForUpdates:) userInfo: [NSDictionary dictionary] repeats: YES] retain];
}


// -----------------------------------------------------------------------------
//	checkAtStartup:
//		Accessor for finding out whether this will check at startup.
//
//	REVISIONS:
//		2004-10-19	witness	Documented.
// -----------------------------------------------------------------------------

-(BOOL)			checkAtStartup
{
	NSNumber	*   doCheck = [[NSUserDefaults standardUserDefaults] objectForKey: @"UKUpdateChecker:CheckAtStartup"];
	
	if( doCheck )
		return [doCheck boolValue];
	else
		return YES;
}


// -----------------------------------------------------------------------------
//	dictionaryFromNSURLConnectionWithURL:
//		Download a dictionary, if possible using an NSURLRequest and user agent.
//
//	REVISIONS:
//      2005-06-21  witness Copied over from Peter's submitted code and changed
//                          to use NSData+URLUserAgent, documented.
//		2004-11-23	pm      Created.
// -----------------------------------------------------------------------------

-(NSDictionary*)    dictionaryFromNSURLConnectionWithURL: (NSURL*)theURL
{
	NSData	*	theData;
	if( theData = [NSData dataWithContentsOfURL: theURL userAgent: nil] )
		return [(NSDictionary*)CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)theData, kCFPropertyListImmutable, NULL) autorelease];

	return nil;
}


@end
