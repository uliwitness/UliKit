/* =============================================================================
	FILE:		UKNibOwner.h
	PROJECT:	CocoaTADS

    COPYRIGHT:  (c) 2004 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   GPL, Modified BSD

	REVISIONS:
		2004-11-13	UK	Created.
   ========================================================================== */

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
