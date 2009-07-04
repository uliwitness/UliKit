/* =============================================================================
	PROJECT:	ToolParams
	FILE:		ToolParams.c
	
    COPYRIGHT:	Copyright (c) 2001 M. Uli Kusterer. All rights reserved.
    
    REVISIONS:
        Wed Sep 05 2001	witness	Created.
   ========================================================================== */

/* -----------------------------------------------------------------------------
    Headers:
   -------------------------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include "ToolParams.h"


/* -----------------------------------------------------------------------------
    ParseParamArray:
        Call this function to take care of stashing all parameters, no matter
        what order they have, in your variables.
    
    TAKES:
        argc, argv	-	The same as your main() function gets from the OS.
        pMap		-	An array of ToolParamEntries. Set the last entry's
                        mDest to NULL to indicate the array's end.
    
    REVISIONS:
        Wed Sep 05 2001	witness	Created.
   -------------------------------------------------------------------------- */

void	ParseParamArray( int argc, const char* argv[], ToolParamEntry* pMap )
{
    int					x = 0,
						y = 0,
						lastUnlabeled = -1;
    const char**		lastDest;
    
    // Clear array so unset params are guaranteed to be NULL:
    while( pMap[x].mDest != NULL )
        (*pMap[x++].mDest) = NULL;
    
    lastDest = (const char**) &(pMap[x].mDest);
    
    for( x = 1; x < argc; x++ )		// Loop over all params:
    {
		const char* currArg = argv[x];
		
        if( (currArg[0] == '-') && (currArg[1] != 0) && (currArg[2] == 0) )	// It's a switch! of form "-X", where X can be any single character.
        {
            for( y = 0; pMap[y].mDest != NULL; y++ )	// Loop over our map...
            {
                if( strcmp( pMap[y].mSwitch, currArg ) == 0 ) // ... looking for the matching entry.
                {
                    const char* nextArg = argv[x+1];
					
					if( argc > (x+1)	// If there is a param after the switch ...
                        && !((nextArg[0] == '-') && (nextArg[1] != 0) && (nextArg[2] == 0)) )	// ... and it's not another switch ...
                    {
					    (*pMap[y].mDest) = nextArg; // ... set it.
						x++;	// Skip nextArg so it isn't processed as an unlabeled param.
					}
                    else
                        (*pMap[y].mDest) = (char*) lastDest;	// Set it to point at our NULL entry, which looks like an empty string.
                    break;
                }
            }
        }
        else	// Unlabeled param?
        {
            if( lastUnlabeled == -1 )
                y = 0;
            else
                y = lastUnlabeled +1;
            
            // Find an unused unlabeled entry in our map: 
            for( ; pMap[y].mDest != NULL; y++ )
            {
                if( pMap[y].mSwitch[0] == 0 )	// Unlabeled!
                {
                    lastUnlabeled = y;	// Make sure it isn't set twice!
                    (*pMap[y].mDest) = argv[x];	// ... and set it.
                    break;
                }
            }
        }
    }
}