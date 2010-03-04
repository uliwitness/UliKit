//
//  UKFeedbackProvider.h
//  NiftyFeatures
//
//  Created by Uli Kusterer on Mon Nov 24 2003.
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
