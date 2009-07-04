/* =============================================================================
	FILE:		UKPushbackMessenger.h
	PROJECT:	Shovel
    
    COPYRIGHT:  (c) 2004 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   GPL, Modified BSD

	REVISIONS:
		2004-10-14	UK	Created.
   ========================================================================== */

/*
	Sometimes you have an action that should be performed as soon as the user
	has changed the text in a text field. However, it is an expensive action,
	and doing it on every keypress is not desirable.
	
	UKPushbackMessenger acts as a proxy object. Send the message to a
	UKPushbackMessenger instance, and it will pass the message on to the object
	connected to its "target" outlet with a one second delay. If the message is
	sent again before the second has elapsed, the timer will be reset to 1.0
	seconds again, and the message won't be forwarded to the target until
	another second has elapsed without the same message having been sent again.
	
	Thus, the time at which the message is sent may be "pushed back".
	
	Note:	To use this in IB, drag this header into IB's window to add it to
			the NIB file's list of classes, then select the class and add the
			desired actions to it. If you don't add the action, IB will not
			let you hook up the action to the messenger.
	
	Note:	UKPushbackMessenger can also be used as a proxy for a delegate.
			You can even have a messenger stand in and apply the delay to several
			messages.
*/

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@interface UKPushbackMessenger : NSObject
{
	IBOutlet id             target;
	NSMutableDictionary*	timers;
	NSMutableDictionary*	pushes;
	double                  delay;
    NSTimeInterval          maxPushTime;   // Maximum time we may push back a message. 0 is no maximum.
}

-(id)   initWithTarget: (id)targ;

-(void) setDelay: (NSTimeInterval)n;
-(void) setMaxPushTime: (NSTimeInterval)n;

@end
