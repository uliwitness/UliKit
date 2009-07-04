/* =============================================================================
	FILE:		UKThreadMessenger.h
	PROJECT:	Shovel
    
    COPYRIGHT:  (c) 2004 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   GPL, Modified BSD

	REVISIONS:
		2004-10-14	UK	Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

/*
	UKThreadMessenger is a proxy object that executes all messages you send to
    it in a second thread. You can do this to easily queue up messages you want
    to happen transparently in the background.
*/


@interface UKThreadMessenger : NSObject
{
	IBOutlet id		target;
	NSMutableArray*	messages;
    BOOL            threadRunning;
    BOOL            newestFirst;        // Execute newest messages first, instead of executing them in order?
}

-(id)   initWithTarget: (id)trg newestFirst: (BOOL)nwf;

@end
