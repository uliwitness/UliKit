//
//  UKCarbonEventHandler.h
//  TalkingMoose (XC2)
//
//  Created by Uli Kusterer on 26.03.06.
//  Copyright 2006 Uli Kusterer.
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

#import <Cocoa/Cocoa.h>

#ifndef __CARBON__
// Avoid pulling in all of Carbon.h into files that use an object of this kind (you'll still need it for creating one, though):
typedef void*	EventHandlerRef;
typedef void*	EventHandlerCallRef;
typedef void*	EventRef;
#endif

extern NSString*	UKCarbonEventHandlerEventReceived;

@interface UKCarbonEventHandler : NSObject
{
	EventHandlerRef		evtHandler;		// Reference to our event handler to pass to Carbon.
	EventHandlerCallRef	currCall;		// Allows us to forward the event. Only valid while we're handling an event.
	EventRef			currEvent;		// The event we're currently handling.
}

-(id)	initWithEventClass: (UInt32)eclass kind: (UInt32)ekind;

-(BOOL)	performEventActionAndPassOn;	// Override this to perform your action. By default sends a UKCarbonEventHandlerEventReceived notification with this object as the notification object.
-(BOOL)	callNextHandler;				// Returns YES when the other handler handled the event, NO on error or eventNotHandledErr.

// For you Carbon afficionados:
-(EventHandlerCallRef)	currentCallRef;
-(EventRef)				currentEventRef;

// Private:
-(OSStatus)	handleEvent: (EventRef)inEvent call: (EventHandlerCallRef)inHandlerCallRef;

@end
