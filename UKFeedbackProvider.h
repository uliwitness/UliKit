//
//  UKFeedbackProvider.h
//  NiftyFeatures
//
//  Created by Uli Kusterer on Mon Nov 24 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>


// -----------------------------------------------------------------------------
//	Class Declarations:
// -----------------------------------------------------------------------------

@interface UKFeedbackProvider : NSObject
{
	IBOutlet NSWindow*		feedbackWindow;			// Will automatically be hooked up. Don't do this yourself.
	IBOutlet NSComboBox*	subjectField;			// Will automatically be hooked up. Don't do this yourself.
	IBOutlet NSTextView*	messageText;			// Will automatically be hooked up. Don't do this yourself.
	IBOutlet NSTextField*	myEmailField;			// Will automatically be hooked up. Don't do this yourself.
}

// Action for the "send feedback" menu item:
-(IBAction) orderFrontFeedbackWindow: (id)sender;   // "Send Feedback..." menu item action method.
-(IBAction) orderFrontBugReportWindow: (id)sender;  // "Report bug..." menu item action method.
-(IBAction) sendFeedback: (id)sender;				// Old name, just for compatibility.

// Actions for the three buttons in the window:
-(IBAction) sendFeedbackButtonAction: (id)sender;
-(IBAction) closeFeedbackWindow: (id)sender;
-(IBAction) openURL: (id)sender;


// Override these if you need to send along additional info:
-(NSAttributedString*)	emailMessageFromUserText: (NSAttributedString*)userText;
-(NSString*)			windowNibName;

// Private:
-(void)	orderFrontEMailWindowWithPreselectedSubject: (int)num;

@end
