//
//  UKIsDragStart.h
//  Propaganda
//
//  Created by Uli Kusterer on 01.05.10.
//  Copyright 2010 Uli Kusterer.
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
	Some objects can be both clicked and dragged. In this case it helps to have
	a smart heuristic to detect each situation. This function is it.
	
	There are three possible return values at the moment:
	
		*	The user moved the mouse more than 2 pixels from the original
			position while the mouse is still held down.
			(it's a drag)
		
		*	The user held the mouse down for longer than 1.5 seconds.
			(it's a drag)
		
		*	The user released the mouse within the 1.5 second wait time.
			(it's a click)
	
	The 1.5 second time-out can be configured if desired.
	
	This function is essentially a Cocoa replacement of Carbon's WaitMouseMoved()
	function.
*/

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//	Constants:
// -----------------------------------------------------------------------------

// Possible return values from UKIsDragStart:
enum
{
	UKIsDragStartMouseReleased = 0,
	UKIsDragStartTimedOut,
	UKIsDragStartMouseMoved
};
typedef NSInteger UKIsDragStartResult;


// -----------------------------------------------------------------------------
//	Prototypes:
// -----------------------------------------------------------------------------

UKIsDragStartResult	UKIsDragStart( NSEvent *startEvent, NSTimeInterval theTimeout );	// 0.0 timeout means default (currently 1.5 secs)






