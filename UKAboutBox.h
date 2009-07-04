/* =============================================================================
	FILE:		UKAboutBox.h
	PROJECT:	Filie
    
    COPYRIGHT:  (c) 2003 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   GPL, Modified BSD

	REVISIONS:
		2003-12-29	UK	Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Constants:
// -----------------------------------------------------------------------------

#ifndef ABOUT_DAYTIME_IMAGE
#define ABOUT_DAYTIME_IMAGE     @"MountainView_Day"
#define ABOUT_DUSKDAWN_IMAGE    @"MountainView_Sunset"
#define ABOUT_NIGHTTIME_IMAGE   @"MountainView_Night"
#endif /*ABOUT_DAYTIME_IMAGE*/


// -----------------------------------------------------------------------------
//  Classes:
// -----------------------------------------------------------------------------

@interface UKAboutBox : NSObject
{
    IBOutlet NSTextView*    creditsTextView;
    IBOutlet NSImageView*   aboutImageView;
    IBOutlet NSTextField*   versionTextField;
	IBOutlet NSWindow*		alternateAboutWindow;
}

-(void) orderFront: (id)sender;
-(void)	orderFrontAlternate: (id)sender;

@end
