//
//  MyWindowDelegate.h
//  UKToolbarFactory
//
//  Created by Uli Kusterer on Sun Jan 18 2004.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>


// -----------------------------------------------------------------------------
//	Window delegate:
// -----------------------------------------------------------------------------

/* This is just necessary for this example so we have someone who is a first
	responder and handles our toolbar items. Most of the time you'll have an
	NSDocument etc. that would do this in your app already. */

@interface MyWindowDelegate : NSObject
{
	IBOutlet NSTextField*	status;		// Text field in which we show a little message in response to toolbar item clicks.
}

-(IBAction) doToolbarItem: (id)sender;  // Action we've made some of our toolbar items send.

@end





