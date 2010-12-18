//
//	UKDebugNames.h
//	filebrowser
//
//	Created by Uli Kusterer on 2005-05-01
//	Copyright 2005 Uli Kusterer.
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
	Generate unique, human-readable names for pointers as a
	debugging aid. It remembers if it's already seen an address,
	and in that case returns the same name it generated before
	(at least during one session - but not across re-launches).
	
	REQUIREMENTS: English.lproj/UKDebugNames.plist
	
	NOT THREAD SAFE
*/

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>

/*
    This is a handy debugging aid for printf-style debugging (i.e. if you're
    using NSLog statements to track down bugs). This assigns each object a
    human-readable name (from a list of predefined names it has) which are much
    easier to distinguish than 0x00488010-style numbers.
*/

NSString*   UKDebugNameFor( id obj );
