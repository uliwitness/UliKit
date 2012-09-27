//
//  UKCarbonEventHandler.m
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

#import	<Carbon/Carbon.h>
#import "UKCarbonEventHandler.h"

// kEventClassApplication / kEventAppFrontSwitched

NSString*	UKCarbonEventHandlerEventReceived = @"UKCarbonEventHandlerEventReceived";

OSStatus UKCarbonEventHandlerFunc( EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData );

@implementation UKCarbonEventHandler

-(id)	initWithEventClass: (UInt32)eclass kind: (UInt32)ekind
{
	self = [super init];
	if( self )
	{
		static EventHandlerUPP		eventHandlerUPP = NULL;	// Singleton used by all instances. Intentional "leak".
		EventTypeSpec				type;
		
		if( !eventHandlerUPP )
			eventHandlerUPP = NewEventHandlerUPP(UKCarbonEventHandlerFunc);
		
		type.eventClass = eclass;
		type.eventKind = ekind;
		
		OSStatus	err = InstallApplicationEventHandler( eventHandlerUPP, GetEventTypeCount(type), &type, self, &evtHandler );
		if( err != noErr )
		{
			//UKLog( @"UKCarbonEventHandler: Couldn't install application event handler (Error No. %ld)", err );
			[self autorelease];
			return nil;
		}
	}
	
	return self;
}

-(void)	dealloc
{
	RemoveEventHandler( evtHandler );
	
	[super dealloc];
}

-(OSStatus)	handleEvent: (EventRef)inEvent call: (EventHandlerCallRef)inHandlerCallRef
{
	currCall = inHandlerCallRef;
	currEvent = inEvent;
	
	if( [self performEventActionAndPassOn] )
		return eventNotHandledErr;
	else
		return noErr;
}

-(BOOL)	callNextHandler
{
	return( CallNextEventHandler( currCall, currEvent ) == noErr );
}

-(EventHandlerCallRef)	currentCallRef
{
	return currCall;
}


-(EventRef)				currentEventRef
{
	return currEvent;
}


-(BOOL)	performEventActionAndPassOn
{
	//UKLog(@"performEventActionAndPassOn self = %lx", (unsigned int)self);
	[[NSNotificationCenter defaultCenter] postNotificationName: UKCarbonEventHandlerEventReceived object: self];
	
	return YES;
}

@end


OSStatus UKCarbonEventHandlerFunc( EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData )
{
	UKCarbonEventHandler*	myself = (UKCarbonEventHandler*) inUserData;
	OSStatus				err = eventNotHandledErr;
	
	NS_DURING
		err = [myself handleEvent: inEvent call: inHandlerCallRef];
	NS_HANDLER
		NSLog( @"UKCarbonEventHandler: Error handling event: %@", localException );
	NS_ENDHANDLER
	
	return err;
}
