/* =============================================================================
    PROJECT:	TalkingMoose
	FILE:       UKTiledImageView.h
    
    COPYRIGHT:  (c) 2005-2008 by M. Uli Kusterer, all rights reserved.
    
    AUTHORS:    M. Uli Kusterer - UK
    
    LICENSES:   GNU GPL, Modified BSD
	
	PURPOSE:	Like an NSImageView, but repeats its image horizontally. Useful
				e.g. to have an image or pattern in a window that can be resized
				to be very wide.
    
    REVISIONS:
        2005-02-03  UK  Created.
   ========================================================================== */
 
// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


@interface UKTiledImageView : NSImageView
{
	BOOL	scaleVertically;
}

-(BOOL)	scaleVertically;
-(void)	setScaleVertically: (BOOL)doScale;

@end
