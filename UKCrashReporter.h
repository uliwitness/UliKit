//
//  UKCrashReporter.h
//  NiftyFeatures
//
//  Created by Uli Kusterer on Sat Feb 04 2006.
//  Copyright (c) 2006 Uli Kusterer.
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

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "UKNibOwner.h"


// -----------------------------------------------------------------------------
//	Prototypes:
// -----------------------------------------------------------------------------

/* Call this sometime during startup (e.g. in applicationDidLaunch) and it'll
	check for a new crash log and offer to the user to send it.
	
	The crash log is sent to a CGI script whose URL you specify in the
	UKUpdateChecker.strings file. If you want, you can even have different
	URLs for different locales that way, in case a crash is caused by an error
	in a localized file.
*/
void	UKCrashReporterCheckForCrash();


// -----------------------------------------------------------------------------
//	Classes:
// -----------------------------------------------------------------------------

@interface UKCrashReporter : UKNibOwner
{
	IBOutlet NSWindow*				reportWindow;
	IBOutlet NSTextView*			informationField;
	IBOutlet NSTextView*			crashLogField;
	IBOutlet NSTextField*			explanationField;
	IBOutlet NSProgressIndicator*	progressIndicator;
	IBOutlet NSButton*				sendButton;
	IBOutlet NSButton*				remindButton;
	IBOutlet NSButton*				discardButton;
	IBOutlet NSTabView*				switchTabView;
	NSURLConnection*				connection;
	BOOL							feedbackMode;
}

-(id)		initWithLogString: (NSString*)theLog;
-(id)		init;									// This gives you a feedback window instead of a crash reporter.

-(IBAction)	sendCrashReport: (id)sender;
-(IBAction)	remindMeLater: (id)sender;
-(IBAction)	discardCrashReport: (id)sender;

@end


@interface UKFeedbackProvider : NSObject
{
	
}

-(IBAction) orderFrontFeedbackWindow: (id)sender;
-(IBAction) orderFrontBugReportWindow: (id)sender;

@end
