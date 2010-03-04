//
//	UKMainThreadProxy.h
//	UKMainThreadProxy
//
//	Created by Uli Kusterer on 14.10.2004.
//	Copyright 2004 Uli Kusterer.
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
	Send a message for object theObject to [theObject mainThreadProxy]
    instead and the message will be received on the main thread by
    theObject.
*/

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Categories:
// -----------------------------------------------------------------------------

@interface NSObject (UKMainThreadProxy)

-(id)	mainThreadProxy;		// You can't init or release this object.
-(id)	copyMainThreadProxy;	// Gives you a retained version.

@end


// -----------------------------------------------------------------------------
//  Classes:
// -----------------------------------------------------------------------------

/*
	This object is created as a proxy in a second thread for an existing object.
	All messages you send to this object will automatically be sent to the other
	object on the main thread, except NSObject methods like retain/release etc.
*/

@interface UKMainThreadProxy : NSObject
{
	IBOutlet id		target;
	BOOL			waitForCompletion;
}

-(id)	initWithTarget: (id)targ;

-(void)	setWaitForCompletion: (BOOL)state;

@end
