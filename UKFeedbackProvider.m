//
//  UKFeedbackProvider.m
//  NiftyFeatures
//
//  Created by Uli Kusterer on Mon Nov 24 2003.
//  Copyright (c) Uli Kusterer.
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

#import "UKFeedbackProvider.h"
#import <Message/NSMailDelivery.h>


@implementation UKFeedbackProvider

// -----------------------------------------------------------------------------
//	* DESTRUCTOR:
//		Usually isn't called since this object is typically instantiated in
//		MainMenu.nib, and MainMenu.nib relies on the OS just disposing of all
//		memory the app occupied when it quits.
// -----------------------------------------------------------------------------

-(void) dealloc
{
	// Release all top-level objects from our NIB:
	[feedbackWindow release];
	
	[super dealloc];
}


// -----------------------------------------------------------------------------
//	orderFrontFeedbackWindow:
//		Menu item action for "Send Feedback..." menu item. Shows the window, or
//		if the user hasn't set up an e-mail address, this directly opens the
//		mailto: URL so the user can use the local e-mail app.
// -----------------------------------------------------------------------------

-(IBAction) orderFrontFeedbackWindow: (id)sender
{
	[self orderFrontEMailWindowWithPreselectedSubject: 0];
}


-(IBAction) orderFrontBugReportWindow: (id)sender
{
	[self orderFrontEMailWindowWithPreselectedSubject: 2];
}


-(void)	orderFrontEMailWindowWithPreselectedSubject: (int)desiredItemIndex
{
	if( !feedbackWindow )
		[NSBundle loadNibNamed: [self windowNibName] owner: self];
	
	if( [NSMailDelivery hasDeliveryClassBeenConfigured] )
	{
		[feedbackWindow makeKeyAndOrderFront: self];
		
		NSString*		myEmail = [[[NSUserDefaults standardUserDefaults] persistentDomainForName: @"AddressBookMe"] objectForKey: @"ExistingEmailAddress"];
		if( myEmail == nil )
			myEmail = @"<Unknown>";
		
		[myEmailField setStringValue: myEmail];
		[subjectField selectItemAtIndex: desiredItemIndex];
	}
	else	// Mail delivery not set up?
		[self openURL: self];	// Directly bring up e-mail app.
}


// -----------------------------------------------------------------------------
//	sendFeedbackButtonAction:
//		Action for the "send" button in the mail window. Sends out the message,
//		after prefixing the title with the desired prefix etc.
// -----------------------------------------------------------------------------

-(IBAction) sendFeedbackButtonAction: (id)sender
{
	NSAttributedString*	msgText = [self emailMessageFromUserText: [messageText textStorage]];
	NSString*			msgSubjPre = NSLocalizedString(@"FEEDBACK_SUBJECT_PREFIX", @"Prefix to use in front of subject so you can filter by it.");
	NSString*			msgSubj = [msgSubjPre stringByAppendingString: [subjectField stringValue]];
	NSString*			msgDest = NSLocalizedString(@"FEEDBACK_EMAIL", @"E-Mail address user's feedack should be sent to.");
	NSDictionary*		hdrs = [NSDictionary dictionaryWithObjectsAndKeys:
									msgSubj, @"Subject",
									msgDest, @"To",
									[myEmailField stringValue], @"Reply-To",
									[myEmailField stringValue], @"From",
									@"UKFeedbackProvider", @"X-Mailer",
									nil];
	
	//if( ![NSMailDelivery deliverMessage: msgText subject: msgSubj to: msgDest] )
	if( ![NSMailDelivery deliverMessage: msgText headers: hdrs format: NSMIMEMailFormat protocol: nil] )
	{
		NSBeginAlertSheet( NSLocalizedString(@"Couldn't send message", @"FEEDBACK_ERROR_TITLE"),
							NSLocalizedString(@"OK",@"FEEDBACK_ERROR_BUTTON"), nil, nil,
							feedbackWindow, self, @selector(errorSheetDidEnd:returnCode:contextInfo:), 0, nil,
							NSLocalizedString(@"An error occurred while trying to send off your bug report, try using your e-mail client instead.", @"FEEDBACK_ERROR_MESSAGE"));
	}
	else
		[self closeFeedbackWindow: sender];
}


// -----------------------------------------------------------------------------
//	emailMessageFromUserText:
//		If you want to append System Profiler info to the message, or whatever,
//		override this method and return the modified text before it is
//		sent. Obviously only works if the user uses our mail window.
//
//		userText - The message the user typed into the edit field.
// -----------------------------------------------------------------------------

-(NSAttributedString*)    emailMessageFromUserText: (NSAttributedString*)userText
{
	/* You could run /System/Library/Frameworks/SystemConfiguration.framework/Versions/A/Resources/get-mobility-info
		using NSTask and take the generated file and attach it to the message
		somehow. That would get you oodles of system setup info. */
	
    return userText;
}


// -----------------------------------------------------------------------------
//	errorSheetDidEnd:returnCode:contextInfo:
//		Dummy method that's called by our error message sheet after the user
//		acknowledged we failed to send. Called indirectly by
//		sendFeedbackButtonAction:
// -----------------------------------------------------------------------------

-(void) errorSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	
}


// -----------------------------------------------------------------------------
//	closeFeedbackWindow:
//		Closes the feedback window and clears all fields. Called when a message
//		could be sent successfully.
// -----------------------------------------------------------------------------

-(IBAction) closeFeedbackWindow: (id)sender
{
	[messageText setString: @""];
	[subjectField selectItemAtIndex: 0];
	[feedbackWindow orderOut: sender];
}


// -----------------------------------------------------------------------------
//	openURL:
//		Action of the "Open in my e-mail app" button. Simply opens the mailto:
//		URL specified in Localizable.strings.
// -----------------------------------------------------------------------------

-(IBAction) openURL: (id)sender
{
	// This URL may be a "mailto:user@domain.net?subject=Feedback%20about%20NiftyFeatures" URL as well:
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: NSLocalizedString(@"FEEDBACK_URL", @"URL where the user can provide feedback.")]];
}


// -----------------------------------------------------------------------------
//	windowNibName:
//		Returns the name (w/o suffix) of our NIB file containing the feedback
//		window.
// -----------------------------------------------------------------------------

-(NSString*)    windowNibName
{
    return @"UKFeedbackProvider";
}


// -----------------------------------------------------------------------------
//	sendFeedback:
//		Compatibility method. * DEPRECATED *
// -----------------------------------------------------------------------------

-(IBAction) sendFeedback: (id)sender
{
	[self orderFrontFeedbackWindow: sender];
}


@end
