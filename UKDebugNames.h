/* =============================================================================
    PROJECT:	filebrowser
	FILE:       UKDebugNames.h
    
    COPYRIGHT:  (c) 2005-2008 by M. Uli Kusterer, all rights reserved.
    
    AUTHORS:    M. Uli Kusterer - UK
    
    LICENSES:   GNU GPL, Modified BSD
	
	PURPOSE:	Generate unique, human-readable names for pointers as a
				debugging aid. It remembers if it's already seen an address,
				and in that case returns the same name it generated before
				(at least during one session - but not across re-launches).
    
    REVISIONS:
        2005-05-01  UK  Created.
   ========================================================================== */
 
// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

/*
    This is a handy debugging aid for printf-style debugging (i.e. if you're
    using NSLog statements to track down bugs). This assigns each object a
    human-readable name (from a list of predefined names it has) which are much
    easier to distinguish than 0x00488010-style numbers.
*/

NSString*   UKDebugNameFor( id obj );
