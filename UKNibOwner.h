//
//	UKNibOwner.h
//	CocoaTADS
//
//	Created by Uli Kusterer on 13.11.2004.
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
	UKNibOwner is a little base class for your classes. It automatically loads
	a NIB file with the same name as your class (e.g. "UKNibOwnerSubClass.nib")
	and takes care of releasing all top-level objects in the NIB when it is
	released. All you have to do is hook up the outlets in the NIB.
*/

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Classes:
// -----------------------------------------------------------------------------

@interface UKNibOwner : NSResponder
{
    NSMutableArray*					topLevelObjects;
	IBOutlet NSObjectController*	proxyController;	// Hook this up to this object and back, and bind to the object controller. -releaseTopLevelObjects will do a setContents:nil on it to release all bindings correctly.
}

-(id)	init;
-(id)	initWithNibName: (NSString*)nibName;
-(id)	initWithNibName: (NSString*)nibName owner: (id)owner;

-(NSString*)    nibFilename;    // Defaults to name of the class.

-(void)	releaseTopLevelObjects;	// If you have bindings, call this when you want to go away so the views can unbind and release you.

@end
