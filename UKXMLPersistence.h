//
//  UKXMLPersistence.h
//  
//
//  Created by Uli Kusterer on 07.10.04.
//  Copyright 2004 M. Uli Kusterer.
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

#include <CoreFoundation/CoreFoundation.h>


// arrayKeys is an array (with the last entry set to NULL) of CFStringRefs that
// specify the names of tags whose contents are to be loaded as arrays, not as
// NSDictionaries.

CFDictionaryRef	UKCreateDictionaryFromXML( CFStringRef padStr, CFStringRef* arrayKeys,	// may be NULL
											unsigned int flags );
CFStringRef		UKCreateXMLFromDictionary( CFDictionaryRef ref, unsigned int flags );


// Flags for UKCreateDictionaryFromXML and UKCreateXMLFromDictionary
#define	kUKXMLNoXMLHeadTag		(1 << 0)		// Means you don't want an "?xml" entry added to the dictionary, or you don't want an automatically generated <?xml ...?> tag added to the top of the file when it's missing.
#define	kUKXMLNoEmptyTags		(1 << 1)		// XML output only: If a tag contains an empty string, omit the tag instead of generating an empty tag for it (<foo />).
#define	kUKXMLDontIndent		(1 << 2)		// XML output only: Do not indent the tags according to their nesting depth. This saves a couple of bytes during transfer of the files on the net, but makes them unreadable for humans.

#define kUKXMLCreateDictionaryDefaultFlags	(kUKXMLNoXMLHeadTag)
#define kUKXMLCreateXMLDefaultFlags			(kUKXMLNoEmptyTags)