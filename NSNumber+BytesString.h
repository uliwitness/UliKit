//
//	NSNumber+BytesString.h
//	Filie
//
//	Created by Uli Kusterer on 3.7.2005
//	Copyright 2005 by Uli Kusterer.
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
	Take a number of bytes and format it for display as a string in a sensible
	way, picking an appropriate unit like bytes, kb, etc. and appending that
	unit to the string along with the number.
*/

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------
 
#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Extend NSNumber:
// -----------------------------------------------------------------------------
 
@interface NSNumber (UKBytesString)

+(NSString*)    bytesStringForInt: (int)bytes;

-(NSString*)    bytesString;

@end
